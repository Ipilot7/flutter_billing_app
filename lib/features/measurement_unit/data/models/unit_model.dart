// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/unit.dart';

part 'unit_model.g.dart';

@HiveType(typeId: 4)
class UnitModel extends Unit {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final String name;

  @override
  @HiveField(2)
  final String shortName;

  const UnitModel({
    required this.id,
    required this.name,
    required this.shortName,
  }) : super(id: id, name: name, shortName: shortName);

  factory UnitModel.fromEntity(Unit unit) {
    return UnitModel(
      id: unit.id,
      name: unit.name,
      shortName: unit.shortName,
    );
  }

  Unit toEntity() {
    return Unit(id: id, name: name, shortName: shortName);
  }
}
