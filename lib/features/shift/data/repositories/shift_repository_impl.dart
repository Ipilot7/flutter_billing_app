import 'package:fpdart/fpdart.dart';
import 'package:uuid/uuid.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/shift/domain/entities/shift.dart';
import 'package:billing_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:billing_app/core/data/app_database.dart';
import '../mappers/shift_mapper.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  final AppDatabase _db;

  ShiftRepositoryImpl(this._db);

  @override
  Future<Either<Failure, Shift>> openShift({
    required double startBalance,
    required String openedBy,
  }) async {
    try {
      final currentShiftResult = await getCurrentShift();
      final currentShift = currentShiftResult.fold((l) => null, (s) => s);

      if (currentShift != null) {
        return const Left(CacheFailure('A shift is already open'));
      }

      final shift = Shift(
        id: const Uuid().v4(),
        openedAt: DateTime.now(),
        openedBy: openedBy,
        startBalance: startBalance,
        status: 0,
      );

      await _db.into(_db.shifts).insert(shift.toTable());
      return Right(shift);
    } catch (e) {
      return Left(CacheFailure('Failed to open shift: $e'));
    }
  }

  @override
  Future<Either<Failure, Shift>> closeShift({
    required String shiftId,
    required double endBalance,
  }) async {
    try {
      final query = _db.select(_db.shifts)..where((t) => t.id.equals(shiftId));
      final existingShiftRow = await query.getSingleOrNull();

      if (existingShiftRow == null) {
        return const Left(CacheFailure('Shift not found'));
      }

      final updatedShift = Shift(
        id: existingShiftRow.id,
        openedAt: existingShiftRow.openedAt,
        closedAt: DateTime.now(),
        openedBy: existingShiftRow.openedBy,
        startBalance: existingShiftRow.startBalance,
        endBalance: endBalance,
        status: 1,
      );

      await _db.update(_db.shifts).replace(updatedShift.toTable());
      return Right(updatedShift);
    } catch (e) {
      return Left(CacheFailure('Failed to close shift: $e'));
    }
  }

  @override
  Future<Either<Failure, Shift?>> getCurrentShift() async {
    try {
      final query = _db.select(_db.shifts)..where((t) => t.status.equals(0));
      final rows = await query.get();
      final row = rows.firstOrNull;

      if (row == null) {
        return const Right(null);
      }
      return Right(row.toDomain());
    } catch (e) {
      return Left(CacheFailure('Failed to get current shift: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Shift>>> getAllShifts() async {
    try {
      final rows = await _db.select(_db.shifts).get();
      final shifts = rows.map((row) => row.toDomain()).toList();
      shifts.sort((a, b) => b.openedAt.compareTo(a.openedAt));
      return Right(shifts);
    } catch (e) {
      return Left(CacheFailure('Failed to get shifts: $e'));
    }
  }
}
