// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shift_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShiftModelAdapter extends TypeAdapter<ShiftModel> {
  @override
  final int typeId = 5;

  @override
  ShiftModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShiftModel(
      id: fields[0] as String,
      openedAt: fields[1] as DateTime,
      closedAt: fields[2] as DateTime?,
      openedBy: fields[3] as String,
      startBalance: fields[4] as double,
      endBalance: fields[5] as double?,
      status: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShiftModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.openedAt)
      ..writeByte(2)
      ..write(obj.closedAt)
      ..writeByte(3)
      ..write(obj.openedBy)
      ..writeByte(4)
      ..write(obj.startBalance)
      ..writeByte(5)
      ..write(obj.endBalance)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShiftModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
