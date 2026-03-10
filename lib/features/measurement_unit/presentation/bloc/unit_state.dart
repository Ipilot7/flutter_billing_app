import 'package:equatable/equatable.dart';
import 'package:billing_app/features/measurement_unit/domain/entities/unit.dart';

abstract class UnitState extends Equatable {
  const UnitState();

  @override
  List<Object?> get props => [];
}

class UnitInitial extends UnitState {}

class UnitLoading extends UnitState {}

class UnitLoaded extends UnitState {
  final List<Unit> units;

  const UnitLoaded({required this.units});

  @override
  List<Object?> get props => [units];
}

class UnitError extends UnitState {
  final String message;

  const UnitError({required this.message});

  @override
  List<Object?> get props => [message];
}
