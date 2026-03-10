import 'package:bloc/bloc.dart';
import 'package:billing_app/features/measurement_unit/domain/entities/unit.dart';
import 'package:billing_app/features/measurement_unit/domain/usecases/unit_usecases.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'unit_event.dart';
import 'unit_state.dart';

class UnitBloc extends Bloc<UnitEvent, UnitState> {
  final AddUnitUseCase addUnitUseCase;
  final UpdateUnitUseCase updateUnitUseCase;
  final DeleteUnitUseCase deleteUnitUseCase;
  final GetAllUnitsUseCase getAllUnitsUseCase;

  UnitBloc({
    required this.addUnitUseCase,
    required this.updateUnitUseCase,
    required this.deleteUnitUseCase,
    required this.getAllUnitsUseCase,
  }) : super(UnitInitial()) {
    on<LoadUnitsEvent>(_onLoadUnits);
    on<AddUnitEvent>(_onAddUnit);
    on<UpdateUnitEvent>(_onUpdateUnit);
    on<DeleteUnitEvent>(_onDeleteUnit);

    // Auto-load units
    add(LoadUnitsEvent());
  }

  Future<void> _onLoadUnits(
      LoadUnitsEvent event, Emitter<UnitState> emit) async {
    emit(UnitLoading());
    final result = await getAllUnitsUseCase(NoParams());
    result.fold(
      (failure) => emit(UnitError(message: failure.message)),
      (units) => emit(UnitLoaded(units: units)),
    );
  }

  Future<void> _onAddUnit(AddUnitEvent event, Emitter<UnitState> emit) async {
    final result = await addUnitUseCase(AddUnitParams(
      name: event.name,
      shortName: event.shortName,
    ));
    result.fold(
      (failure) => emit(UnitError(message: failure.message)),
      (unit) => add(LoadUnitsEvent()),
    );
  }

  Future<void> _onUpdateUnit(
      UpdateUnitEvent event, Emitter<UnitState> emit) async {
    final result = await updateUnitUseCase(Unit(
      id: event.id,
      name: event.name,
      shortName: event.shortName,
    ));
    result.fold(
      (failure) => emit(UnitError(message: failure.message)),
      (unit) => add(LoadUnitsEvent()),
    );
  }

  Future<void> _onDeleteUnit(
      DeleteUnitEvent event, Emitter<UnitState> emit) async {
    final result = await deleteUnitUseCase(event.id);
    result.fold(
      (failure) => emit(UnitError(message: failure.message)),
      (_) => add(LoadUnitsEvent()),
    );
  }
}
