import 'package:equatable/equatable.dart';

class Unit extends Equatable {
  final String id;
  final String name;
  final String shortName;

  const Unit({
    required this.id,
    required this.name,
    required this.shortName,
  });

  Unit copyWith({
    String? id,
    String? name,
    String? shortName,
  }) {
    return Unit(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
    );
  }

  @override
  List<Object?> get props => [id, name, shortName];
}
