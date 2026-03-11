import 'package:fpdart/fpdart.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/shift/domain/entities/shift.dart';
import 'package:billing_app/features/shift/data/models/shift_model.dart';
import 'package:billing_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:billing_app/core/data/hive_database.dart';

class ShiftRepositoryImpl implements ShiftRepository {
  Box<ShiftModel> get _box => HiveDatabase.shiftsBox;

  @override
  Future<Either<Failure, Shift>> openShift({
    required double startBalance,
    required String openedBy,
  }) async {
    try {
      final currentShift = await getCurrentShift();
      if (currentShift.isRight() &&
          currentShift.fold((l) => null, (s) => s) != null) {
        return const Left(CacheFailure('A shift is already open'));
      }

      final shift = ShiftModel(
        id: const Uuid().v4(),
        openedAt: DateTime.now(),
        openedBy: openedBy,
        startBalance: startBalance,
        status: 0,
      );

      await _box.put(shift.id, shift);
      return Right(shift.toEntity());
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
      final existingShift = _box.get(shiftId);
      if (existingShift == null) {
        return const Left(CacheFailure('Shift not found'));
      }

      final updatedShift = ShiftModel(
        id: existingShift.id,
        openedAt: existingShift.openedAt,
        closedAt: DateTime.now(),
        openedBy: existingShift.openedBy,
        startBalance: existingShift.startBalance,
        endBalance: endBalance,
        status: 1,
      );

      await _box.put(shiftId, updatedShift);
      return Right(updatedShift.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to close shift: $e'));
    }
  }

  @override
  Future<Either<Failure, Shift?>> getCurrentShift() async {
    try {
      final shifts = _box.values.where((s) => s.status == 0).toList();
      if (shifts.isEmpty) {
        return const Right(null);
      }
      return Right(shifts.first.toEntity());
    } catch (e) {
      return Left(CacheFailure('Failed to get current shift: $e'));
    }
  }

  @override
  Future<Either<Failure, List<Shift>>> getAllShifts() async {
    try {
      final shifts = _box.values.map((s) => s.toEntity()).toList();
      shifts.sort((a, b) => b.openedAt.compareTo(a.openedAt));
      return Right(shifts);
    } catch (e) {
      return Left(CacheFailure('Failed to get shifts: $e'));
    }
  }
}
