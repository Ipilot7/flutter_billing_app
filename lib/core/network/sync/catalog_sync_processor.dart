import 'package:billing_app/core/data/app_database.dart';
import 'package:drift/drift.dart';
import 'sync_models.dart';
import 'sync_dtos.dart';

class CatalogSyncProcessor {
  final AppDatabase _db;

  CatalogSyncProcessor(this._db);

  Future<void> prepareOperations({
    required List<Map<String, dynamic>> operations,
    required SyncProgress progress,
    required String Function({
      required String entityType,
      required String entityId,
      required int signature,
    }) buildOperationId,
  }) async {
    // 1. Categories
    final localCategories = await _db.getAllCategories();
    final localCategoryById = {
      for (final category in localCategories) category.id: category,
    };

    for (final local in localCategories) {
      final name = local.name.trim();
      if (name.isEmpty) continue;

      final checksum = Object.hash(name, local.icon, local.colorCode).toUnsigned(32);
      
      final dto = SyncCategoryDto(id: local.id, name: name);
      
      operations.add(SyncOperationDto(
        operationId: buildOperationId(
          entityType: 'category.upsert',
          entityId: local.id,
          signature: checksum,
        ),
        entityType: 'category.upsert',
        entityId: local.id,
        payload: dto.toUpsertPayload(),
      ).toJson());
      
      progress.preparedCategories++;
    }

    // 2. Products
    final localProducts = await _db.getAllProducts();
    for (final local in localProducts) {
      final barcode = local.barcode.trim();
      if (barcode.isEmpty) continue;

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

      final dto = SyncProductDto(
        id: local.id,
        barcode: barcode,
        name: local.name,
        price: local.price,
        cost: local.costPrice,
        stock: local.stock,
        categoryId: local.categoryId,
        categoryName: categoryName,
      );

      operations.add(SyncOperationDto(
        operationId: buildOperationId(
          entityType: 'product.upsert',
          entityId: local.id,
          signature: checksum,
        ),
        entityType: 'product.upsert',
        entityId: local.id,
        payload: dto.toUpsertPayload(),
      ).toJson());
      
      progress.preparedProducts++;
    }
  }

  Future<void> pullDataFromSyncPayload(Map<String, dynamic> data, SyncProgress progress) async {
    // 1. Pull Categories
    final remoteCategoriesRaw = data['categories'];
    if (remoteCategoriesRaw is List) {
      final remoteCategories = remoteCategoriesRaw.whereType<Map<String, dynamic>>().map(SyncCategoryDto.fromJson).toList();
      progress.pulledCategories = remoteCategories.length;

      if (remoteCategories.isNotEmpty) {
        final localCategories = await _db.getAllCategories();
        final localCatById = {for (final c in localCategories) c.id: c};

        await _db.batch((batch) {
          for (final remote in remoteCategories) {
            final existing = localCatById[remote.id];
            if (existing != null) {
              if (existing.name != remote.name) {
                batch.update(_db.categories, existing.copyWith(name: remote.name));
                progress.updatedCategories++;
              }
            } else {
              batch.insert(
                _db.categories,
                CategoriesCompanion.insert(id: remote.id, name: remote.name),
                mode: InsertMode.insertOrReplace,
              );
              progress.insertedCategories++;
            }
          }
        });
      }
    }

    // 2. Pull Products
    final remoteProductsRaw = data['products'];
    if (remoteProductsRaw is List) {
      final remoteProducts = remoteProductsRaw.whereType<Map<String, dynamic>>().map(SyncProductDto.fromJson).toList();
      progress.pulledProducts = remoteProducts.length;

      if (remoteProducts.isNotEmpty) {
        final localProducts = await _db.getAllProducts();
        final localProdByBarcode = {for (final p in localProducts) p.barcode: p};
        
        // Map to quickly get category name from ID if provided in remote
        final remoteCategories = (data['categories'] as List?)?.whereType<Map<String, dynamic>>().map(SyncCategoryDto.fromJson).toList() ?? [];
        final remoteCatNameById = {
          for (final c in remoteCategories) c.id: c.name
        };

        await _db.batch((batch) {
          for (final remote in remoteProducts) {
            if (remote.id.isEmpty || remote.barcode.isEmpty) continue;

            final catName = remote.categoryName ?? 
                           (remote.categoryId != null ? remoteCatNameById[remote.categoryId] : null);

            final existing = localProdByBarcode[remote.barcode];
            if (existing != null) {
              batch.update(
                _db.products,
                existing.copyWith(
                  name: remote.name,
                  price: remote.price,
                  costPrice: remote.cost,
                  stock: remote.stock,
                  categoryId: Value(remote.categoryId),
                  categoryName: Value(catName),
                ),
              );
              progress.updatedProducts++;
            } else {
              batch.insert(
                _db.products,
                ProductsCompanion.insert(
                  id: remote.id,
                  barcode: remote.barcode,
                  name: remote.name,
                  price: remote.price,
                  costPrice: Value(remote.cost),
                  stock: Value(remote.stock),
                  categoryId: Value(remote.categoryId),
                  categoryName: Value(catName),
                ),
                mode: InsertMode.insertOrReplace,
              );
              progress.insertedProducts++;
            }
          }
        });
      }
    }
  }
}
