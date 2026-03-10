import 'package:equatable/equatable.dart';

abstract class ShiftEvent extends Equatable {
  const ShiftEvent();

  @override
  List<Object?> get props => [];
}

class CheckCurrentShiftEvent extends ShiftEvent {}

class OpenShiftEvent extends ShiftEvent {
  final double startBalance;
  final String openedBy;

  const OpenShiftEvent({required this.startBalance, required this.openedBy});

  @override
  List<Object?> get props => [startBalance, openedBy];
}

class CloseShiftEvent extends ShiftEvent {
  final double endBalance;

  const CloseShiftEvent({required this.endBalance});

  @override
  List<Object?> get props => [endBalance];
}
