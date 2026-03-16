import 'package:fpdart/fpdart.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;

  ProductRepositoryImpl(this._db);

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    try {
      final rows = await _db.getAllProducts();
      return Right(rows.map((row) => _mapToEntity(row)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Product>> getProductByBarcode(String barcode) async {
    try {
      final query = _db.select(_db.products)
        ..where((t) => t.barcode.equals(barcode));
      final rows = await query.get();
      if (rows.isEmpty) {
        return const Left(CacheFailure('Product not found'));
      }
      return Right(_mapToEntity(rows.first));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      await _db.addProduct(_mapToTable(product));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateProduct(Product product) async {
    try {
      await _db.updateProduct(_mapToTable(product));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteProduct(String id) async {
    try {
      await _db.deleteProduct(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Product _mapToEntity(ProductTable table) {
    return Product(
      id: table.id,
      name: table.name,
      barcode: table.barcode,
      price: table.price,
      costPrice: table.costPrice,
      stock: table.stock,
      unit: table.unit,
      categoryId: table.categoryId,
    );
  }

  ProductTable _mapToTable(Product product) {
    return ProductTable(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      costPrice: product.costPrice,
      stock: product.stock,
      unit: product.unit,
      categoryId: product.categoryId,
    );
  }
}
