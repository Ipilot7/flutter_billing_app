import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/shift.dart';
import '../repositories/shift_repository.dart';

class OpenShiftUseCase implements UseCase<Shift, OpenShiftParams> {
  final ShiftRepository repository;

  OpenShiftUseCase(this.repository);

  @override
  Future<Either<Failure, Shift>> call(OpenShiftParams params) {
    return repository.openShift(
      startBalance: params.startBalance,
      openedBy: params.openedBy,
    );
  }
}

class OpenShiftParams {
  final double startBalance;
  final String openedBy;

  OpenShiftParams({required this.startBalance, required this.openedBy});
}

class CloseShiftUseCase implements UseCase<Shift, CloseShiftParams> {
  final ShiftRepository repository;

  CloseShiftUseCase(this.repository);

  @override
  Future<Either<Failure, Shift>> call(CloseShiftParams params) {
    return repository.closeShift(
      shiftId: params.shiftId,
      endBalance: params.endBalance,
    );
  }
}

class CloseShiftParams {
  final String shiftId;
  final double endBalance;

  CloseShiftParams({required this.shiftId, required this.endBalance});
}

class GetCurrentShiftUseCase implements UseCase<Shift?, NoParams> {
  final ShiftRepository repository;

  GetCurrentShiftUseCase(this.repository);

  @override
  Future<Either<Failure, Shift?>> call(NoParams params) {
    return repository.getCurrentShift();
  }
}
