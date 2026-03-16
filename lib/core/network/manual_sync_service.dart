import 'package:billing_app/core/data/app_database.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import 'backend_session.dart';
import 'backend_v1_client.dart';

const _syncCursorKey = 'backend.sync_cursor';
const _syncedSalePrefix = 'backend.sync.sale.';

class ManualSyncResult {
  final int preparedCategoryOperations;
  final int preparedProductOperations;
  final int preparedSaleOperations;
  final int skippedSales;
  final int appliedOperations;
  final int duplicateOperations;
  final int failedOperations;
  final int pulledCategories;
  final int insertedCategories;
  final int updatedCategories;
  final int pulledProducts;
  final int insertedProducts;
  final int updatedProducts;
  final bool terminalMissing;
  final bool backendShiftMissing;
  final List<String> failureReasons;

  const ManualSyncResult({
    required this.preparedCategoryOperations,
    required this.preparedProductOperations,
    required this.preparedSaleOperations,
    required this.skippedSales,
    required this.appliedOperations,
    required this.duplicateOperations,
    required this.failedOperations,
    required this.pulledCategories,
    required this.insertedCategories,
    required this.updatedCategories,
    required this.pulledProducts,
    required this.insertedProducts,
    required this.updatedProducts,
    required this.terminalMissing,
    required this.backendShiftMissing,
    required this.failureReasons,
  });

  String get summary {
    final lines = <String>[
      'sync/push: категорий $preparedCategoryOperations, товаров $preparedProductOperations, чеков $preparedSaleOperations',
      'push результат: applied $appliedOperations, duplicates $duplicateOperations, failed $failedOperations',
      'sync/pull: категорий $pulledCategories, добавлено $insertedCategories, обновлено $updatedCategories',
      'sync/pull: получено товаров $pulledProducts, добавлено $insertedProducts, обновлено $updatedProducts',
    ];

    if (skippedSales > 0) {
      lines.add('Чеки пропущены: $skippedSales');
    }
    if (terminalMissing) {
      lines.add('Push пропущен: касса не имеет terminal_id');
    }
    if (backendShiftMissing) {
      lines.add('Чеки не отправлены: на сервере нет открытой смены');
    }

    if (failureReasons.isNotEmpty) {
      lines.add('Ошибки при отправке:');
      for (final reason in failureReasons.take(5)) {
        lines.add('  - $reason');
      }
      if (failureReasons.length > 5) {
        lines.add('  ... и еще ${failureReasons.length - 5} ошибок');
      }
    }

    return lines.join('\n');
  }
}

class ManualSyncService {
  static const _uuid = Uuid();

  final AppDatabase _db;
  final BackendSession _session;
  final BackendV1Client _client;

  ManualSyncService(this._db, this._session, this._client);

  Future<ManualSyncResult> syncProducts() async {
    final token = await _session.getAccessToken();
    final baseUrl = await _session.getBaseUrl();

    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw BackendApiException('Backend URL is not configured.');
    }
    if (token == null || token.trim().isEmpty) {
      throw BackendApiException('Login is required to sync data.');
    }

    var preparedProductOperations = 0;
    var preparedCategoryOperations = 0;
    var preparedSaleOperations = 0;
    var skippedSales = 0;
    var appliedOperations = 0;
    var duplicateOperations = 0;
    var failedOperations = 0;
    var terminalMissing = false;
    var backendShiftMissing = false;
    final failureReasons = <String>[];

    final organizationId = await _session.getOrganizationId();
    var terminalId = await _session.getTerminalId();
    terminalId ??= await _resolveTerminalIdForSync();
    final operations = <Map<String, dynamic>>[];
    final saleOperationIds = <String, String>{};

    final localCategories = await _db.getAllCategories();
    final localCategoryById = {
      for (final category in localCategories) category.id: category,
    };

    for (final local in localCategories) {
      final name = local.name.trim();
      if (name.isEmpty) {
        continue;
      }

      final checksum =
          Object.hash(name, local.icon, local.colorCode).toUnsigned(
        32,
      );
      final payload = <String, dynamic>{
        'name': name,
        'local_id': local.id,
      };

      operations.add({
        'operation_id': _buildOperationId(
          entityType: 'category.upsert',
          entityId: local.id,
          signature: checksum,
        ),
        'entity_type': 'category.upsert',
        'entity_id': local.id,
        'payload': payload,
      });
      preparedCategoryOperations++;
    }

    final localProducts = await _db.getAllProducts();
    for (final local in localProducts) {
      final barcode = local.barcode.trim();
      if (barcode.isEmpty) {
        continue;
      }

      final categoryName = local.categoryId == null
          ? null
          : localCategoryById[local.categoryId!]?.name;
      final checksum = Object.hash(
        local.name,
        barcode,
        local.price,
        local.costPrice,
        local.stock,
        local.categoryId,
      ).toUnsigned(32);
      final payload = <String, dynamic>{
        'sku': local.id,
        'barcode': barcode,
        'name': local.name,
        'price': local.price.toStringAsFixed(2),
        'cost': local.costPrice.toStringAsFixed(2),
        'stock': local.stock.toStringAsFixed(3),
        'min_stock': '0.000',
        'is_active': true,
      };

      if (categoryName != null && categoryName.trim().isNotEmpty) {
        payload['category_name'] = categoryName.trim();
      }

      operations.add({
        'operation_id': _buildOperationId(
          entityType: 'product.upsert',
          entityId: local.id,
          signature: checksum,
        ),
        'entity_type': 'product.upsert',
        'entity_id': local.id,
        'payload': payload,
      });
      preparedProductOperations++;
    }

    final backendShiftId =
        terminalId == null ? null : await _resolveBackendShiftId();

    final localSales = await (_db.select(_db.sales)
          ..where((t) => t.isReturned.equals(false)))
        .get();
    for (final sale in localSales) {
      final syncKey = '$_syncedSalePrefix${sale.id}';
      final alreadySynced = await _db.getSetting(syncKey);
      if (alreadySynced == '1') {
        continue;
      }

      if (backendShiftId == null) {
        skippedSales++;
        continue;
      }

      final items = await (_db.select(_db.saleItems)
            ..where((t) => t.saleId.equals(sale.id)))
          .get();
      if (items.isEmpty) {
        skippedSales++;
        continue;
      }

      final mappedItems = <Map<String, dynamic>>[];
      var hasInvalidItem = false;
      for (final item in items) {
        final barcode = await _resolveProductBarcode(item.productId);
        if (barcode == null || barcode.trim().isEmpty) {
          hasInvalidItem = true;
          break;
        }

        mappedItems.add({
          'barcode': barcode,
          'product_name': item.productName,
          'quantity': item.quantity.toStringAsFixed(3),
          'price': item.price.toStringAsFixed(2),
          'discount': item.discount.toStringAsFixed(2),
          'line_total':
              ((item.price * item.quantity) - item.discount).toStringAsFixed(2),
        });
      }

      if (hasInvalidItem) {
        skippedSales++;
        continue;
      }

      final operationId = _buildOperationId(
        entityType: 'sale.create',
        entityId: sale.id,
        signature: null,
      );
      saleOperationIds[operationId] = sale.id;
      operations.add({
        'operation_id': operationId,
        'entity_type': 'sale.create',
        'entity_id': sale.id,
        'payload': {
          'shift_id': backendShiftId,
          'receipt_number': sale.id,
          'payment_type': _mapPaymentType(sale.paymentType),
          'subtotal':
              (sale.totalAmount + sale.globalDiscount).toStringAsFixed(2),
          'discount_total': sale.globalDiscount.toStringAsFixed(2),
          'total': sale.totalAmount.toStringAsFixed(2),
          'items': mappedItems,
        },
      });
      preparedSaleOperations++;
    }

    if (terminalId == null) {
      terminalMissing = true;
    } else if (backendShiftId == null && skippedSales > 0) {
      backendShiftMissing = true;
    }

    if (terminalId != null && operations.isNotEmpty) {
      final response = await _client.pushSyncOperations(
        terminalId: terminalId,
        operations: operations,
      );
      final applied = response['applied'];
      if (applied is List) {
        appliedOperations = applied.length;
        for (final operationId in applied.whereType<String>()) {
          final saleId = saleOperationIds[operationId];
          if (saleId != null) {
            await _db.saveSetting('$_syncedSalePrefix$saleId', '1');
          }
        }
      }

      final duplicates = response['duplicates'];
      if (duplicates is List) {
        duplicateOperations = duplicates.length;
        for (final operationId in duplicates.whereType<String>()) {
          final saleId = saleOperationIds[operationId];
          if (saleId != null) {
            await _db.saveSetting('$_syncedSalePrefix$saleId', '1');
          }
        }
      }

      final failed = response['failed'];
      if (failed is List) {
        for (final failedItem in failed) {
          failedOperations++;
          if (failedItem is Map<String, dynamic>) {
            final error = failedItem['error']?.toString();
            if (error != null && error.isNotEmpty) {
              failureReasons.add(error);
            }
          }
        }
      }
    }

    final lastCursor = await _db.getSetting(_syncCursorKey);
    final syncPull = await _client.pullSyncData(
      since: lastCursor,
      organizationId: organizationId,
    );

    final data = syncPull['data'];
    if (data is! Map<String, dynamic>) {
      throw BackendApiException('Sync pull payload is missing data section.');
    }

    final remoteCategoriesRaw = data['categories'];
    if (remoteCategoriesRaw is! List) {
      throw BackendApiException(
          'Sync pull payload has invalid categories list.');
    }

    final remoteCategories =
        remoteCategoriesRaw.whereType<Map<String, dynamic>>();
    var insertedCategories = 0;
    var updatedCategories = 0;
    final pulledCategories = remoteCategories.length;

    for (final remote in remoteCategories) {
      final id = remote['id']?.toString();
      final name = remote['name']?.toString();
      if (id == null || name == null || name.trim().isEmpty) {
        continue;
      }

      final existing = await (_db.select(_db.categories)
            ..where((t) => t.id.equals(id)))
          .getSingleOrNull();

      if (existing != null) {
        await _db.update(_db.categories).replace(
              existing.copyWith(
                name: name,
              ),
            );
        updatedCategories++;
        continue;
      }

      await _db.addCategory(
        CategoryTable(
          id: id,
          name: name,
          icon: null,
          colorCode: null,
        ),
      );
      insertedCategories++;
    }

    final remoteProductsRaw = data['products'];
    if (remoteProductsRaw is! List) {
      throw BackendApiException('Sync pull payload has invalid products list.');
    }

    final remoteProducts = remoteProductsRaw.whereType<Map<String, dynamic>>();

    var insertedToLocal = 0;
    var updatedLocal = 0;
    final pulledProducts = remoteProducts.length;

    for (final remote in remoteProducts) {
      final id = remote['id']?.toString();
      final name = remote['name']?.toString();
      final barcode = remote['barcode']?.toString();
      if (id == null || name == null || barcode == null) {
        continue;
      }

      final price = double.tryParse(remote['price'].toString()) ?? 0.0;
      final cost = double.tryParse(remote['cost'].toString()) ?? 0.0;
      final stock = double.tryParse(remote['stock'].toString()) ?? 0.0;
      final remoteCategoryId = remote['category']?.toString();

      final existingByBarcode = await (_db.select(_db.products)
            ..where((t) => t.barcode.equals(barcode)))
          .getSingleOrNull();

      if (existingByBarcode != null) {
        await _db.update(_db.products).replace(
              existingByBarcode.copyWith(
                name: name,
                price: price,
                costPrice: cost,
                stock: stock,
                categoryId: Value(remoteCategoryId),
              ),
            );
        updatedLocal++;
        continue;
      }

      await _db.upsertProduct(
        ProductTable(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          costPrice: cost,
          stock: stock,
          unit: 'шт',
          categoryId: remoteCategoryId,
        ),
      );
      insertedToLocal++;
    }

    final nextCursor = syncPull['next_cursor']?.toString();
    if (nextCursor != null && nextCursor.isNotEmpty) {
      await _db.saveSetting(_syncCursorKey, nextCursor);
    }

    return ManualSyncResult(
      preparedCategoryOperations: preparedCategoryOperations,
      preparedProductOperations: preparedProductOperations,
      preparedSaleOperations: preparedSaleOperations,
      skippedSales: skippedSales,
      appliedOperations: appliedOperations,
      duplicateOperations: duplicateOperations,
      failedOperations: failedOperations,
      pulledCategories: pulledCategories,
      insertedCategories: insertedCategories,
      updatedCategories: updatedCategories,
      pulledProducts: pulledProducts,
      insertedProducts: insertedToLocal,
      updatedProducts: updatedLocal,
      terminalMissing: terminalMissing,
      backendShiftMissing: backendShiftMissing,
      failureReasons: failureReasons,
    );
  }

  Future<String?> _resolveProductBarcode(String productId) async {
    final product = await (_db.select(_db.products)
          ..where((t) => t.id.equals(productId)))
        .getSingleOrNull();
    return product?.barcode;
  }

  Future<String?> _resolveBackendShiftId() async {
    // First, try to find an existing open shift on the backend
    final restoredShiftId =
        await _client.restoreOpenShiftIdForCurrentTerminal();
    if (restoredShiftId != null) {
      return restoredShiftId.toString();
    }

    // If no open shift on backend, check if there's a local open shift
    // and try to create it on the backend
    try {
      final localShiftQuery = _db.select(_db.shifts)
        ..where((t) => t.status.equals(0));
      final localShift = await localShiftQuery.getSingleOrNull();

      if (localShift != null) {
        // Try to create the shift on the backend
        final response = await _client.openShift(
          startBalance: localShift.startBalance.toDouble(),
        );
        final backendShiftId = response['id'];
        if (backendShiftId != null) {
          return backendShiftId.toString();
        }
      }
    } catch (e) {
      // If shift creation fails, continue without it
      // (might fail due to permissions or shift already exists)
    }

    return null;
  }

  Future<int?> _resolveTerminalIdForSync() async {
    final role = await _session.getSessionRole();
    if (role != BackendSession.roleOwner) {
      return null;
    }

    List<Map<String, dynamic>> terminals;
    try {
      terminals = await _client.fetchTerminalsFromSyncPull();
    } catch (_) {
      try {
        terminals = await _client.fetchTerminals();
      } catch (_) {
        return null;
      }
    }

    if (terminals.isEmpty) {
      return null;
    }

    final preferredStoreId = await _session.getStoreId();
    final organizationId = await _session.getOrganizationId();

    Map<String, dynamic>? pick;
    if (preferredStoreId != null) {
      for (final terminal in terminals) {
        final storeId = _toInt(terminal['store']);
        final isActive = terminal['is_active'] != false;
        if (storeId == preferredStoreId && isActive) {
          pick = terminal;
          break;
        }
      }

      if (pick == null) {
        return null;
      }
    }

    pick ??= terminals.cast<Map<String, dynamic>?>().firstWhere(
          (terminal) => terminal?['is_active'] != false,
          orElse: () => null,
        );

    if (pick == null) {
      return null;
    }

    final terminalId = _toInt(pick['id']);
    if (terminalId == null) {
      return null;
    }

    final storeId = _toInt(pick['store']);
    if (storeId != null && organizationId != null) {
      await _session.saveTerminalContext(
        terminalId: terminalId,
        storeId: storeId,
        organizationId: organizationId,
      );
    }

    return terminalId;
  }

  int? _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  String _buildOperationId({
    required String entityType,
    required String entityId,
    required int? signature,
  }) {
    final seed = signature == null
        ? '$entityType:$entityId'
        : '$entityType:$entityId:$signature';
    return _uuid.v5(Namespace.url.value, seed);
  }

  String _mapPaymentType(int paymentType) {
    switch (paymentType) {
      case 1:
        return 'card';
      case 2:
        return 'terminal';
      case 0:
      default:
        return 'cash';
    }
  }
}
