import 'package:equatable/equatable.dart';

abstract class SalesEvent extends Equatable {
  const SalesEvent();

  @override
  List<Object?> get props => [];
}

class LoadSalesHistoryEvent extends SalesEvent {
  final DateTime? from;
  final DateTime? to;
  final String? shiftId;

  const LoadSalesHistoryEvent({this.from, this.to, this.shiftId});

  @override
  List<Object?> get props => [from, to, shiftId];
}

class ReturnSaleEvent extends SalesEvent {
  final String saleId;

  const ReturnSaleEvent({required this.saleId});

  @override
  List<Object?> get props => [saleId];
}
