import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/features/shift/domain/entities/shift.dart';

extension ShiftTableX on ShiftTable {
  Shift toDomain() {
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

extension ShiftX on Shift {
  ShiftTable toTable() {
    return ShiftTable(
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
