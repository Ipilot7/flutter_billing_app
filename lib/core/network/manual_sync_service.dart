import 'package:billing_app/core/data/app_database.dart';

import 'backend_session.dart';
import 'backend_v1_client.dart';

const _syncCursorKey = 'backend.sync_cursor';
const _syncedSalePrefix = 'backend.sync.sale.';

class ManualSyncResult {
  final int preparedProductOperations;
  final int preparedSaleOperations;
  final int skippedSales;
  final int appliedOperations;
  final int duplicateOperations;
  final int failedOperations;
  final int pulledProducts;
  final int insertedProducts;
  final int updatedProducts;
  final bool terminalMissing;
  final bool backendShiftMissing;

  const ManualSyncResult({
    required this.preparedProductOperations,
    required this.preparedSaleOperations,
    required this.skippedSales,
    required this.appliedOperations,
    required this.duplicateOperations,
    required this.failedOperations,
    required this.pulledProducts,
    required this.insertedProducts,
    required this.updatedProducts,
    required this.terminalMissing,
    required this.backendShiftMissing,
  });

  String get summary {
    final lines = <String>[
      'sync/push: товаров $preparedProductOperations, чеков $preparedSaleOperations',
      'push результат: applied $appliedOperations, duplicates $duplicateOperations, failed $failedOperations',
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

    return lines.join('\n');
  }
}

class ManualSyncService {
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
    var preparedSaleOperations = 0;
    var skippedSales = 0;
    var appliedOperations = 0;
    var duplicateOperations = 0;
    var failedOperations = 0;
    var terminalMissing = false;
    var backendShiftMissing = false;

    final organizationId = await _session.getOrganizationId();
    final terminalId = await _session.getTerminalId();
    final operations = <Map<String, dynamic>>[];
    final saleOperationIds = <String, String>{};

    final localProducts = await _db.getAllProducts();
    for (final local in localProducts) {
      final barcode = local.barcode.trim();
      if (barcode.isEmpty) {
        continue;
      }

      operations.add({
        'operation_id': 'product_${local.id}',
        'entity_type': 'product.upsert',
        'entity_id': local.id,
        'payload': {
          'sku': local.id,
          'barcode': barcode,
          'name': local.name,
          'price': local.price.toStringAsFixed(2),
          'cost': local.costPrice.toStringAsFixed(2),
          'stock': local.stock.toStringAsFixed(3),
          'min_stock': '0.000',
          'is_active': true,
        },
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

      final operationId = 'sale_create_${sale.id}';
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
        failedOperations = failed.length;
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
          categoryId: null,
        ),
      );
      insertedToLocal++;
    }

    final nextCursor = syncPull['next_cursor']?.toString();
    if (nextCursor != null && nextCursor.isNotEmpty) {
      await _db.saveSetting(_syncCursorKey, nextCursor);
    }

    return ManualSyncResult(
      preparedProductOperations: preparedProductOperations,
      preparedSaleOperations: preparedSaleOperations,
      skippedSales: skippedSales,
      appliedOperations: appliedOperations,
      duplicateOperations: duplicateOperations,
      failedOperations: failedOperations,
      pulledProducts: pulledProducts,
      insertedProducts: insertedToLocal,
      updatedProducts: updatedLocal,
      terminalMissing: terminalMissing,
      backendShiftMissing: backendShiftMissing,
    );
  }

  Future<String?> _resolveProductBarcode(String productId) async {
    final product = await (_db.select(_db.products)
          ..where((t) => t.id.equals(productId)))
        .getSingleOrNull();
    return product?.barcode;
  }

  Future<String?> _resolveBackendShiftId() async {
    final currentShiftId = await _session.getCurrentShiftId();
    if (currentShiftId != null) {
      return currentShiftId.toString();
    }

    final restoredShiftId =
        await _client.restoreOpenShiftIdForCurrentTerminal();
    return restoredShiftId?.toString();
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
