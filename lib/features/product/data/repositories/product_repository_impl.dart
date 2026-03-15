import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/network/backend_session.dart';
import '../../../../core/network/backend_v1_client.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final AppDatabase _db;
  final BackendV1Client? _backendClient;
  final BackendSession? _backendSession;

  ProductRepositoryImpl(
    this._db, {
    BackendV1Client? backendClient,
    BackendSession? backendSession,
  })  : _backendClient = backendClient,
        _backendSession = backendSession;

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
      final row = await query.getSingle();
      return Right(_mapToEntity(row));
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addProduct(Product product) async {
    try {
      await _db.addProduct(_mapToTable(product));
      await _trySyncProductToBackend(product);
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

  Future<void> _trySyncProductToBackend(Product product) async {
    final backendClient = _backendClient;
    final backendSession = _backendSession;
    if (backendClient == null || backendSession == null) {
      return;
    }

    final baseUrl = await backendSession.getBaseUrl();
    final accessToken = await backendSession.getAccessToken();
    final organizationId = await backendSession.getOrganizationId();
    if (baseUrl == null ||
        baseUrl.trim().isEmpty ||
        accessToken == null ||
        accessToken.isEmpty ||
        organizationId == null) {
      return;
    }

    try {
      await backendClient.createProduct(
        organizationId: organizationId,
        name: product.name,
        barcode: product.barcode,
        price: product.price,
        cost: product.costPrice,
        stock: product.stock,
        sku: product.id,
      );
    } catch (e) {
      // Local save is primary; backend sync is best effort in current flow.
      debugPrint('Product backend auto-sync skipped: $e');
    }
  }
}
