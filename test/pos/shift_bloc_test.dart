import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/features/shift/domain/entities/shift.dart';
import 'package:billing_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:billing_app/features/shift/domain/usecases/shift_usecases.dart';
import 'package:billing_app/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:billing_app/features/shift/presentation/bloc/shift_event.dart';
import 'package:billing_app/features/shift/presentation/bloc/shift_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';

class _FakeShiftRepository implements ShiftRepository {
  Shift? current;

  @override
  Future<Either<Failure, Shift>> closeShift({
    required String shiftId,
    required double endBalance,
  }) async {
    final open = current;
    if (open == null) {
      return const Left(CacheFailure('No open shift to close'));
    }

    final closed = open.copyWith(
      closedAt: DateTime.now(),
      endBalance: endBalance,
      status: 1,
    );
    current = null;
    return Right(closed);
  }

  @override
  Future<Either<Failure, List<Shift>>> getAllShifts() async {
    return Right(current == null ? [] : [current!]);
  }

  @override
  Future<Either<Failure, Shift?>> getCurrentShift() async {
    return Right(current);
  }

  @override
  Future<Either<Failure, Shift>> openShift({
    required double startBalance,
    required String openedBy,
  }) async {
    if (current != null) {
      return const Left(CacheFailure('A shift is already open'));
    }

    final shift = Shift(
      id: 'shift-1',
      openedAt: DateTime.now(),
      openedBy: openedBy,
      startBalance: startBalance,
      status: 0,
    );
    current = shift;
    return Right(shift);
  }
}

void main() {
  group('ShiftBloc POS flow', () {
    late _FakeShiftRepository repo;
    late ShiftBloc bloc;

    setUp(() {
      repo = _FakeShiftRepository();
      bloc = ShiftBloc(
        openShiftUseCase: OpenShiftUseCase(repo),
        closeShiftUseCase: CloseShiftUseCase(repo),
        getCurrentShiftUseCase: GetCurrentShiftUseCase(repo),
      );
    });

    tearDown(() async {
      await bloc.close();
    });

    test('opens shift with provided start balance', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5));

      bloc.add(const OpenShiftEvent(startBalance: 250, openedBy: 'cashier'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.currentShift, isNotNull);
      expect(bloc.currentShift!.startBalance, 250);
      expect(bloc.currentShift!.openedBy, 'cashier');
      expect(bloc.currentShift!.isOpen, true);
      expect(bloc.state is ShiftLoaded, true);
    });

    test('closes existing shift and clears current shift', () async {
      await Future<void>.delayed(const Duration(milliseconds: 5));
      bloc.add(const OpenShiftEvent(startBalance: 100, openedBy: 'cashier'));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(const CloseShiftEvent(endBalance: 180));
      await Future<void>.delayed(const Duration(milliseconds: 10));

      expect(bloc.currentShift, isNull);
      expect(bloc.state is ShiftLoaded, true);
      final state = bloc.state as ShiftLoaded;
      expect(state.currentShift, isNull);
    });
  });
}
