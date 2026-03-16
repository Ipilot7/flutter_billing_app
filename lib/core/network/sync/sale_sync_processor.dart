import 'package:billing_app/core/data/app_database.dart';
import 'sync_models.dart';
import 'sync_dtos.dart';

class SaleSyncProcessor {
  final AppDatabase _db;

  SaleSyncProcessor(this._db);

  Future<void> prepareOperations({
    required List<Map<String, dynamic>> operations,
    required SyncProgress progress,
    required Map<String, String> saleOperationIds,
    required int? backendShiftId,
    required String Function({
      required String entityType,
      required String entityId,
      required int signature,
    }) buildOperationId,
  }) async {
    final unsyncedSales = await (_db.select(_db.sales)
          ..where((t) => t.id.isNotIn(saleOperationIds.keys)))
        .get();

    for (final sale in unsyncedSales) {
      if (backendShiftId == null) {
        progress.skippedSales++;
        continue;
      }

      final items = await (_db.select(_db.saleItems)
            ..where((t) => t.saleId.equals(sale.id)))
          .get();

      final syncItems = <SyncSaleItemDto>[];
      for (final item in items) {
        final barcode = await _resolveProductBarcode(item.productId);
        if (barcode == null) continue;

        syncItems.add(SyncSaleItemDto(
          barcode: barcode,
          productName: item.productName,
          quantity: item.quantity,
          price: item.price,
          discount: item.discount,
        ));
      }

      if (syncItems.isEmpty) {
        progress.skippedSales++;
        continue;
      }

      final checksum = _calculateSaleChecksum(sale, syncItems);
      final operationId = buildOperationId(
        entityType: 'sale.create',
        entityId: sale.id,
        signature: checksum,
      );

      final saleDto = SyncSaleDto(
        shiftId: backendShiftId.toString(),
        receiptNumber: sale.id,
        paymentType: _mapPaymentType(sale.paymentType),
        subtotal: sale.totalAmount + sale.globalDiscount,
        discountTotal: sale.globalDiscount,
        total: sale.totalAmount,
        items: syncItems,
      );

      operations.add(SyncOperationDto(
        operationId: operationId,
        entityType: 'sale.create',
        entityId: sale.id,
        payload: saleDto.toJson(),
      ).toJson());

      saleOperationIds[sale.id] = operationId;
      progress.preparedSales++;
    }
  }

  Future<void> handlePushResults({
    required Map<String, dynamic> response,
    required SyncProgress progress,
    required Map<String, String> saleOperationIds,
  }) async {
    final results = response['results'];
    if (results is! List) return;

    for (var res in results) {
      if (res is! Map<String, dynamic>) continue;
      final opId = res['operation_id']?.toString();
      final status = res['status']?.toString();

      if (status == 'applied') progress.appliedOps++;
      if (status == 'duplicate') progress.duplicateOps++;
      if (status == 'failed') {
        progress.failedOps++;
        progress.addFailure('Op $opId: ${res['error']}');
      }

      final localSaleId = saleOperationIds.entries
          .where((e) => e.value == opId)
          .map((e) => e.key)
          .firstOrNull;

      if (localSaleId != null && (status == 'applied' || status == 'duplicate')) {
// Mark as synced if needed or just track
      }
    }
  }

  Future<String?> _resolveProductBarcode(String productId) async {
    final product = await (_db.select(_db.products)
          ..where((t) => t.id.equals(productId)))
        .getSingleOrNull();
    return product?.barcode;
  }

  int _calculateSaleChecksum(SaleTable sale, List<SyncSaleItemDto> items) {
    return Object.hash(
      sale.id,
      sale.totalAmount,
      sale.paymentType,
      Object.hashAll(items.map((i) => Object.hash(i.barcode, i.quantity, i.price))),
    ).toUnsigned(32);
  }

  String _mapPaymentType(int paymentType) {
    switch (paymentType) {
      case 1: return 'card';
      case 2: return 'terminal';
      case 0:
      default: return 'cash';
    }
  }
}
