// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UnitModelAdapter extends TypeAdapter<UnitModel> {
  @override
  final int typeId = 4;

  @override
  UnitModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UnitModel(
      id: fields[0] as String,
      name: fields[1] as String,
      shortName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UnitModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.shortName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnitModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
