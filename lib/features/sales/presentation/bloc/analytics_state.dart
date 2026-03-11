part of 'analytics_bloc.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();
  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {}

class AnalyticsLoading extends AnalyticsState {}

class AnalyticsLoaded extends AnalyticsState {
  final List<Sale> sales;
  final double totalRevenue;
  final double totalProfit;
  final Map<String, double> topProducts; // name -> revenue
  final Map<int, double> salesByPayment; // type -> revenue

  const AnalyticsLoaded({
    required this.sales,
    required this.totalRevenue,
    required this.totalProfit,
    required this.topProducts,
    required this.salesByPayment,
  });

  @override
  List<Object?> get props =>
      [sales, totalRevenue, totalProfit, topProducts, salesByPayment];
}

class AnalyticsError extends AnalyticsState {
  final String message;
  const AnalyticsError(this.message);
  @override
  List<Object?> get props => [message];
}
