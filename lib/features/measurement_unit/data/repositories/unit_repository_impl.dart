import 'package:fpdart/fpdart.dart' hide Unit;
import 'package:uuid/uuid.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/measurement_unit/domain/entities/unit.dart';
import 'package:billing_app/core/data/app_database.dart';

abstract class UnitRepository {
  Future<Either<Failure, Unit>> addUnit(String name, String shortName);
  Future<Either<Failure, Unit>> updateUnit(Unit unit);
  Future<Either<Failure, void>> deleteUnit(String id);
  Future<Either<Failure, List<Unit>>> getAllUnits();
}

class UnitRepositoryImpl implements UnitRepository {
  final AppDatabase _db;

  UnitRepositoryImpl(this._db);

  @override
  Future<Either<Failure, Unit>> addUnit(String name, String shortName) async {
    try {
      final unit = Unit(
        id: const Uuid().v4(),
        name: name,
        shortName: shortName,
      );
      await _db.into(_db.units).insert(_mapToTable(unit));
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to add unit: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUnit(Unit unit) async {
    try {
      await _db.update(_db.units).replace(_mapToTable(unit));
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update unit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnit(String id) async {
    try {
      await (_db.delete(_db.units)..where((t) => t.id.equals(id))).go();
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete unit: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Unit>>> getAllUnits() async {
    try {
      final rows = await _db.select(_db.units).get();
      final units = rows.map((row) => _mapToEntity(row)).toList();
      units.sort((a, b) => a.name.compareTo(b.name));
      return Right(units);
    } catch (e) {
      return Left(CacheFailure('Failed to get units: $e'));
    }
  }

  Unit _mapToEntity(UnitTable table) {
    return Unit(
      id: table.id,
      name: table.name,
      shortName: table.shortName,
    );
  }

  UnitTable _mapToTable(Unit unit) {
    return UnitTable(
      id: unit.id,
      name: unit.name,
      shortName: unit.shortName,
    );
  }
}
