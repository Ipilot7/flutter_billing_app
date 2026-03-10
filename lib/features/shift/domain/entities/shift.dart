import 'package:equatable/equatable.dart';

class Shift extends Equatable {
  final String id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedBy;
  final double startBalance;
  final double? endBalance;
  final int status; // 0 = open, 1 = closed

  const Shift({
    required this.id,
    required this.openedAt,
    this.closedAt,
    required this.openedBy,
    required this.startBalance,
    this.endBalance,
    required this.status,
  });

  bool get isOpen => status == 0;

  Shift copyWith({
    String? id,
    DateTime? openedAt,
    DateTime? closedAt,
    String? openedBy,
    double? startBalance,
    double? endBalance,
    int? status,
  }) {
    return Shift(
      id: id ?? this.id,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openedBy: openedBy ?? this.openedBy,
      startBalance: startBalance ?? this.startBalance,
      endBalance: endBalance ?? this.endBalance,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props =>
      [id, openedAt, closedAt, openedBy, startBalance, endBalance, status];
}
