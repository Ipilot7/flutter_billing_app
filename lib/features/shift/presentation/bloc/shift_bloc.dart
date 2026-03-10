import 'package:bloc/bloc.dart';

import 'package:billing_app/features/shift/domain/entities/shift.dart';
import 'package:billing_app/features/shift/domain/usecases/shift_usecases.dart';
import 'package:billing_app/core/usecase/usecase.dart';

import 'shift_event.dart';
import 'shift_state.dart';

class ShiftBloc extends Bloc<ShiftEvent, ShiftState> {
  final OpenShiftUseCase openShiftUseCase;
  final CloseShiftUseCase closeShiftUseCase;
  final GetCurrentShiftUseCase getCurrentShiftUseCase;

  Shift? _currentShift;

  ShiftBloc({
    required this.openShiftUseCase,
    required this.closeShiftUseCase,
    required this.getCurrentShiftUseCase,
  }) : super(ShiftInitial()) {
    on<CheckCurrentShiftEvent>(_onCheckCurrentShift);
    on<OpenShiftEvent>(_onOpenShift);
    on<CloseShiftEvent>(_onCloseShift);

    // Auto-check current shift
    add(CheckCurrentShiftEvent());
  }

  Shift? get currentShift => _currentShift;
  bool get hasOpenShift => _currentShift != null;

  Future<void> _onCheckCurrentShift(
    CheckCurrentShiftEvent event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());
    final result = await getCurrentShiftUseCase(NoParams());
    result.fold(
      (failure) => emit(ShiftError(message: failure.message)),
      (shift) {
        _currentShift = shift;
        emit(ShiftLoaded(currentShift: shift));
      },
    );
  }

  Future<void> _onOpenShift(
    OpenShiftEvent event,
    Emitter<ShiftState> emit,
  ) async {
    emit(ShiftLoading());
    final result = await openShiftUseCase(OpenShiftParams(
      startBalance: event.startBalance,
      openedBy: event.openedBy,
    ));
    result.fold(
      (failure) => emit(ShiftError(message: failure.message)),
      (shift) {
        _currentShift = shift;
        emit(ShiftOperationSuccess(
          message: 'Shift opened successfully',
          shift: shift,
        ));
        emit(ShiftLoaded(currentShift: shift));
      },
    );
  }

  Future<void> _onCloseShift(
    CloseShiftEvent event,
    Emitter<ShiftState> emit,
  ) async {
    if (_currentShift == null) {
      emit(const ShiftError(message: 'No open shift to close'));
      return;
    }
    emit(ShiftLoading());
    final result = await closeShiftUseCase(CloseShiftParams(
      shiftId: _currentShift!.id,
      endBalance: event.endBalance,
    ));
    result.fold(
      (failure) => emit(ShiftError(message: failure.message)),
      (shift) {
        _currentShift = null;
        emit(ShiftOperationSuccess(
          message: 'Shift closed successfully',
          shift: shift,
        ));
        emit(const ShiftLoaded(currentShift: null));
      },
    );
  }
}
