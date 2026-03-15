import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/core/network/backend_session.dart';
import 'package:billing_app/core/network/backend_v1_client.dart';

abstract class SalesRepository {
  Future<Either<Failure, Sale>> createSale(Sale sale);
  Future<Either<Failure, List<Sale>>> getSalesHistory(
      {DateTime? from, DateTime? to, String? shiftId});
  Future<Either<Failure, Sale>> getSaleById(String id);
  Future<Either<Failure, Sale>> returnSale(String saleId);
}

class SalesRepositoryImpl implements SalesRepository {
  final AppDatabase _db;
  final BackendSession _backendSession;
  final BackendV1Client _backendClient;

  SalesRepositoryImpl(this._db, this._backendSession, this._backendClient);

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    try {
      final backendBaseUrl = await _backendSession.getBaseUrl();
      final backendToken = await _backendSession.getAccessToken();
      final backendShiftId = await _backendSession.getCurrentShiftId();

      final shouldUseBackend = backendBaseUrl != null &&
          backendBaseUrl.isNotEmpty &&
          backendToken != null &&
          backendToken.isNotEmpty &&
          backendShiftId != null;

      if (shouldUseBackend) {
        final backendProducts = await _backendClient.fetchProducts();
        final backendIdByBarcode = <String, int>{};
        for (final product in backendProducts) {
          final barcode = product['barcode']?.toString();
          final id = _asInt(product['id']);
          if (barcode == null || barcode.isEmpty || id == null) continue;
          backendIdByBarcode[barcode] = id;
        }

        final backendItems = <Map<String, dynamic>>[];
        for (final item in sale.items) {
          var productId = int.tryParse(item.productId);

          if (productId == null) {
            final localProduct = await (_db.select(_db.products)
                  ..where((t) => t.id.equals(item.productId)))
                .getSingleOrNull();

            final barcode = localProduct?.barcode;
            if (barcode != null && barcode.isNotEmpty) {
              productId = backendIdByBarcode[barcode];
            }
          }

          if (productId == null) {
            return Left(CacheFailure(
                'Product `${item.productName}` is not synced with backend yet. Sync products first.'));
          }
          backendItems.add({
            'product_id': productId,
            'quantity': item.quantity.toStringAsFixed(3),
            'price': item.price.toStringAsFixed(2),
            'discount': item.discount.toStringAsFixed(2),
          });
        }

        await _backendClient.createSale(
          receiptNumber: sale.id,
          paymentType: _mapPaymentTypeToBackend(sale.paymentType),
          items: backendItems,
        );

        await _saveSaleLocallyWithoutStockAdjustments(sale);
        return Right(sale);
      }

      await _db.transaction(() async {
        // Validate and atomically update stock as part of sale creation.
        // This prevents data drift between saved sales and inventory levels.
        for (final item in sale.items) {
          final product = await (_db.select(_db.products)
                ..where((t) => t.id.equals(item.productId)))
              .getSingleOrNull();

          if (product == null) {
            throw Exception('Product not found: ${item.productName}');
          }

          final newStock = product.stock - item.quantity;
          if (newStock < 0) {
            throw Exception('Insufficient stock for ${item.productName}');
          }

          await _db
              .update(_db.products)
              .replace(product.copyWith(stock: newStock));
        }

        await _db.into(_db.sales).insert(_mapToTable(sale));
        for (var item in sale.items) {
          await _db
              .into(_db.saleItems)
              .insert(_mapItemToCompanion(sale.id, item));
        }
      });
      return Right(sale);
    } catch (e) {
      return Left(CacheFailure('Failed to create sale: $e'));
    }
  }

  Future<void> _saveSaleLocallyWithoutStockAdjustments(Sale sale) async {
    await _db.transaction(() async {
      await _db.into(_db.sales).insert(_mapToTable(sale));
      for (final item in sale.items) {
        await _db
            .into(_db.saleItems)
            .insert(_mapItemToCompanion(sale.id, item));
      }
    });
  }

  String _mapPaymentTypeToBackend(int paymentType) {
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

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesHistory(
      {DateTime? from, DateTime? to, String? shiftId}) async {
    try {
      final query = _db.select(_db.sales);

      if (shiftId != null) {
        query.where((t) => t.shiftId.equals(shiftId));
      }

      final saleRows = await query.get();
      List<Sale> sales = [];

      for (var row in saleRows) {
        final itemRows = await (_db.select(_db.saleItems)
              ..where((t) => t.saleId.equals(row.id)))
            .get();
        sales.add(_mapToEntity(row, itemRows));
      }

      if (from != null) {
        sales = sales.where((s) => s.createdAt.isAfter(from)).toList();
      }
      if (to != null) {
        sales = sales.where((s) => s.createdAt.isBefore(to)).toList();
      }

      sales.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return Right(sales);
    } catch (e) {
      return Left(CacheFailure('Failed to get sales history: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> getSaleById(String id) async {
    try {
      final row = await (_db.select(_db.sales)..where((t) => t.id.equals(id)))
          .getSingleOrNull();
      if (row == null) {
        return const Left(CacheFailure('Sale not found'));
      }
      final itemRows = await (_db.select(_db.saleItems)
            ..where((t) => t.saleId.equals(id)))
          .get();
      return Right(_mapToEntity(row, itemRows));
    } catch (e) {
      return Left(CacheFailure('Failed to get sale: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> returnSale(String saleId) async {
    try {
      final existingSaleResult = await getSaleById(saleId);
      final existingSale = existingSaleResult.fold(
          (l) => throw Exception(l.toString()), (s) => s);

      if (existingSale.isReturned) {
        return const Left(
            CacheFailure('Cannot return an already returned sale'));
      }

      final duplicateReturn = await (_db.select(_db.sales)
            ..where((t) =>
                t.returnedSaleId.equals(saleId) & t.isReturned.equals(true)))
          .getSingleOrNull();
      if (duplicateReturn != null) {
        return const Left(CacheFailure('Sale has already been returned'));
      }

      final returnedSale = Sale(
        id: '${saleId}_return_${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        shiftId: existingSale.shiftId,
        openedBy: existingSale.openedBy,
        items: existingSale.items,
        totalAmount: -existingSale.totalAmount,
        paymentType: existingSale.paymentType,
        isReturned: true,
        returnedSaleId: saleId,
        globalDiscount: existingSale.globalDiscount,
      );

      await _db.transaction(() async {
        await _db.into(_db.sales).insert(_mapToTable(returnedSale));

        for (final item in existingSale.items) {
          await _db
              .into(_db.saleItems)
              .insert(_mapItemToCompanion(returnedSale.id, item));

          final productRow = await (_db.select(_db.products)
                ..where((t) => t.id.equals(item.productId)))
              .getSingleOrNull();
          if (productRow != null) {
            await _db.update(_db.products).replace(
                productRow.copyWith(stock: productRow.stock + item.quantity));
          }
        }
      });

      return Right(returnedSale);
    } catch (e) {
      return Left(CacheFailure('Failed to return sale: $e'));
    }
  }

  Sale _mapToEntity(SaleTable table, List<SaleItemTable> items) {
    return Sale(
      id: table.id,
      createdAt: table.createdAt,
      shiftId: table.shiftId,
      openedBy: table.openedBy,
      items: items.map((i) => _mapItemToEntity(i)).toList(),
      totalAmount: table.totalAmount,
      paymentType: table.paymentType,
      isReturned: table.isReturned,
      returnedSaleId: table.returnedSaleId,
      globalDiscount: table.globalDiscount,
    );
  }

  SaleTable _mapToTable(Sale sale) {
    return SaleTable(
      id: sale.id,
      createdAt: sale.createdAt,
      shiftId: sale.shiftId,
      openedBy: sale.openedBy,
      totalAmount: sale.totalAmount,
      paymentType: sale.paymentType,
      isReturned: sale.isReturned,
      returnedSaleId: sale.returnedSaleId,
      globalDiscount: sale.globalDiscount,
    );
  }

  SaleItem _mapItemToEntity(SaleItemTable table) {
    return SaleItem(
      productId: table.productId,
      productName: table.productName,
      price: table.price,
      quantity: table.quantity,
      discount: table.discount,
      costPrice: table.costPrice,
    );
  }

  SaleItemsCompanion _mapItemToCompanion(String saleId, SaleItem item) {
    return SaleItemsCompanion.insert(
      saleId: saleId,
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      discount: Value(item.discount),
      costPrice: Value(item.costPrice),
    );
  }
}
