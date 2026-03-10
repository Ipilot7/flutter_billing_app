import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../entities/shift.dart';

abstract class ShiftRepository {
  Future<Either<Failure, Shift>> openShift({
    required double startBalance,
    required String openedBy,
  });
  Future<Either<Failure, Shift>> closeShift({
    required String shiftId,
    required double endBalance,
  });
  Future<Either<Failure, Shift?>> getCurrentShift();
  Future<Either<Failure, List<Shift>>> getAllShifts();
}
