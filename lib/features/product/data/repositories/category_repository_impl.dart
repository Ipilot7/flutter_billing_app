import 'package:fpdart/fpdart.dart';
import '../../../../core/data/app_database.dart';
import '../../../../core/error/failure.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final AppDatabase _db;

  CategoryRepositoryImpl(this._db);

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    try {
      final rows = await _db.getAllCategories();
      return Right(rows.map((row) => _mapToEntity(row)).toList());
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addCategory(Category category) async {
    try {
      await _db.addCategory(_mapToTable(category));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateCategory(Category category) async {
    try {
      await _db.update(_db.categories).replace(_mapToTable(category));
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCategory(String id) async {
    try {
      await (_db.delete(_db.categories)..where((t) => t.id.equals(id))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }

  Category _mapToEntity(CategoryTable table) {
    return Category(
      id: table.id,
      name: table.name,
      icon: table.icon,
      colorCode: table.colorCode,
    );
  }

  CategoryTable _mapToTable(Category category) {
    return CategoryTable(
      id: category.id,
      name: category.name,
      icon: category.icon,
      colorCode: category.colorCode,
    );
  }
}
