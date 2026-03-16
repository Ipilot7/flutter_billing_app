import 'package:fpdart/fpdart.dart';
import 'package:drift/drift.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/core/data/app_database.dart';

abstract class SalesRepository {
  Future<Either<Failure, Sale>> createSale(Sale sale);
  Future<Either<Failure, List<Sale>>> getSalesHistory(
      {DateTime? from, DateTime? to, String? shiftId});
  Future<Either<Failure, Sale>> getSaleById(String id);
  Future<Either<Failure, Sale>> returnSale(String saleId);
}

class SalesRepositoryImpl implements SalesRepository {
  final AppDatabase _db;

  SalesRepositoryImpl(this._db);

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    try {
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
