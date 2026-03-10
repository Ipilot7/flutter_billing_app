import 'package:fpdart/fpdart.dart' hide Unit;
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/measurement_unit/domain/entities/unit.dart';
import 'package:billing_app/features/measurement_unit/data/models/unit_model.dart';
import 'package:billing_app/core/data/hive_database.dart';

abstract class UnitRepository {
  Future<Either<Failure, Unit>> addUnit(String name, String shortName);
  Future<Either<Failure, Unit>> updateUnit(Unit unit);
  Future<Either<Failure, void>> deleteUnit(String id);
  Future<Either<Failure, List<Unit>>> getAllUnits();
}

class UnitRepositoryImpl implements UnitRepository {
  Box<UnitModel> get _box => HiveDatabase.unitsBox;

  @override
  Future<Either<Failure, Unit>> addUnit(String name, String shortName) async {
    try {
      final unit = UnitModel(
        id: const Uuid().v4(),
        name: name,
        shortName: shortName,
      );
      await _box.put(unit.id, unit);
      return Right(unit.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to add unit: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateUnit(Unit unit) async {
    try {
      final model = UnitModel.fromEntity(unit);
      await _box.put(unit.id, model);
      return Right(unit);
    } catch (e) {
      return Left(CacheFailure('Failed to update unit: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteUnit(String id) async {
    try {
      await _box.delete(id);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to delete unit: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Unit>>> getAllUnits() async {
    try {
      final units = _box.values.map((e) => e.toEntity()).toList();
      units.sort((a, b) => a.name.compareTo(b.name));
      return Right(units);
    } catch (e) {
      return Left(CacheFailure('Failed to get units: $e'));
    }
  }
}
