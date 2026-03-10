import 'package:equatable/equatable.dart';

abstract class UnitEvent extends Equatable {
  const UnitEvent();

  @override
  List<Object?> get props => [];
}

class LoadUnitsEvent extends UnitEvent {}

class AddUnitEvent extends UnitEvent {
  final String name;
  final String shortName;

  const AddUnitEvent({required this.name, required this.shortName});

  @override
  List<Object?> get props => [name, shortName];
}

class UpdateUnitEvent extends UnitEvent {
  final String id;
  final String name;
  final String shortName;

  const UpdateUnitEvent(
      {required this.id, required this.name, required this.shortName});

  @override
  List<Object?> get props => [id, name, shortName];
}

class DeleteUnitEvent extends UnitEvent {
  final String id;

  const DeleteUnitEvent({required this.id});

  @override
  List<Object?> get props => [id];
}
