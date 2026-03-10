import 'package:equatable/equatable.dart';
import '../../domain/entities/shift.dart';

abstract class ShiftState extends Equatable {
  const ShiftState();

  @override
  List<Object?> get props => [];
}

class ShiftInitial extends ShiftState {}

class ShiftLoading extends ShiftState {}

class ShiftLoaded extends ShiftState {
  final Shift? currentShift;

  const ShiftLoaded({this.currentShift});

  bool get hasOpenShift => currentShift != null;

  @override
  List<Object?> get props => [currentShift];
}

class ShiftOperationSuccess extends ShiftState {
  final String message;
  final Shift? shift;

  const ShiftOperationSuccess({required this.message, this.shift});

  @override
  List<Object?> get props => [message, shift];
}

class ShiftError extends ShiftState {
  final String message;

  const ShiftError({required this.message});

  @override
  List<Object?> get props => [message];
}
