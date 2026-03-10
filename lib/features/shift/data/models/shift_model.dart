// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/shift.dart';

part 'shift_model.g.dart';

@HiveType(typeId: 5)
class ShiftModel extends Shift {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final DateTime openedAt;

  @override
  @HiveField(2)
  final DateTime? closedAt;

  @override
  @HiveField(3)
  final String openedBy;

  @override
  @HiveField(4)
  final double startBalance;

  @override
  @HiveField(5)
  final double? endBalance;

  @override
  @HiveField(6)
  final int status;

  const ShiftModel({
    required this.id,
    required this.openedAt,
    this.closedAt,
    required this.openedBy,
    required this.startBalance,
    this.endBalance,
    required this.status,
  }) : super(
          id: id,
          openedAt: openedAt,
          closedAt: closedAt,
          openedBy: openedBy,
          startBalance: startBalance,
          endBalance: endBalance,
          status: status,
        );

  factory ShiftModel.fromEntity(Shift shift) {
    return ShiftModel(
      id: shift.id,
      openedAt: shift.openedAt,
      closedAt: shift.closedAt,
      openedBy: shift.openedBy,
      startBalance: shift.startBalance,
      endBalance: shift.endBalance,
      status: shift.status,
    );
  }

  Shift toEntity() {
    return Shift(
      id: id,
      openedAt: openedAt,
      closedAt: closedAt,
      openedBy: openedBy,
      startBalance: startBalance,
      endBalance: endBalance,
      status: status,
    );
  }
}
