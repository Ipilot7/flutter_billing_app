import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import '../models/sale_model.dart';
import 'package:billing_app/core/data/hive_database.dart';

abstract class SalesRepository {
  Future<Either<Failure, Sale>> createSale(Sale sale);
  Future<Either<Failure, List<Sale>>> getSalesHistory(
      {DateTime? from, DateTime? to, String? shiftId});
  Future<Either<Failure, Sale>> getSaleById(String id);
  Future<Either<Failure, Sale>> returnSale(String saleId);
}

class SalesRepositoryImpl implements SalesRepository {
  Box<SaleModel> get _box => HiveDatabase.salesBox;

  @override
  Future<Either<Failure, Sale>> createSale(Sale sale) async {
    try {
      final model = SaleModel.fromEntity(sale);
      await _box.put(sale.id, model);
      return Right(sale);
    } catch (e) {
      return Left(CacheFailure('Failed to create sale: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Sale>>> getSalesHistory(
      {DateTime? from, DateTime? to, String? shiftId}) async {
    try {
      var sales = _box.values.map((s) => s.toEntity()).toList();

      if (from != null) {
        sales = sales.where((s) => s.createdAt.isAfter(from)).toList();
      }
      if (to != null) {
        sales = sales.where((s) => s.createdAt.isBefore(to)).toList();
      }
      if (shiftId != null) {
        sales = sales.where((s) => s.shiftId == shiftId).toList();
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
      final sale = _box.get(id);
      if (sale == null) {
        return const Left(CacheFailure('Sale not found'));
      }
      return Right(sale.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get sale: $e'));
    }
  }

  @override
  Future<Either<Failure, Sale>> returnSale(String saleId) async {
    try {
      final existingSale = _box.get(saleId);
      if (existingSale == null) {
        return const Left(CacheFailure('Sale not found'));
      }

      final returnedSale = SaleModel(
        id: '${saleId}_return',
        createdAt: DateTime.now(),
        shiftId: existingSale.shiftId,
        openedBy: existingSale.openedBy,
        items: existingSale.items,
        totalAmount: -existingSale.totalAmount,
        paymentType: existingSale.paymentType,
        isReturned: true,
        returnedSaleId: saleId,
      );

      await _box.put(returnedSale.id, returnedSale);
      return Right(returnedSale.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to return sale: $e'));
    }
  }
}
