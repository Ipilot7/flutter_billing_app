import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/features/sales/domain/usecases/sales_usecases.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetSalesHistoryUseCase getSalesHistoryUseCase;

  AnalyticsBloc({required this.getSalesHistoryUseCase})
      : super(AnalyticsInitial()) {
    on<LoadAnalyticsEvent>(_onLoadAnalytics);
  }

  Future<void> _onLoadAnalytics(
    LoadAnalyticsEvent event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading());
    final result = await getSalesHistoryUseCase(SalesHistoryParams(
      from: event.from,
      to: event.to,
    ));

    result.fold(
      (failure) => emit(AnalyticsError(failure.message)),
      (sales) {
        double totalRevenue = 0;
        double totalProfit = 0;
        final Map<String, double> topProducts = {};
        final Map<int, double> salesByPayment = {0: 0, 1: 0, 2: 0};
        final Map<String, double> salesByCategory = {};

        for (final sale in sales) {
          if (sale.isReturned) {
            totalRevenue += sale.totalAmount;
            for (final item in sale.items) {
              totalProfit -= item.profit;
              final catName = item.categoryName ?? 'Uncategorized';
              salesByCategory[catName] =
                  (salesByCategory[catName] ?? 0) + item.total;
            }
            continue;
          }

          totalRevenue += sale.totalAmount;

          for (final item in sale.items) {
            totalProfit += item.profit;
            topProducts[item.productName] =
                (topProducts[item.productName] ?? 0) + item.total;

            final catName = item.categoryName ?? 'Uncategorized';
            salesByCategory[catName] =
                (salesByCategory[catName] ?? 0) + item.total;
          }

          salesByPayment[sale.paymentType] =
              (salesByPayment[sale.paymentType] ?? 0) + sale.totalAmount;
        }

        // Sort top products
        final sortedProducts = Map.fromEntries(topProducts.entries.toList()
          ..sort((e1, e2) => e2.value.compareTo(e1.value)));

        emit(AnalyticsLoaded(
          sales: sales,
          totalRevenue: totalRevenue,
          totalProfit: totalProfit,
          topProducts: sortedProducts,
          salesByPayment: salesByPayment,
          salesByCategory: salesByCategory,
        ));
      },
    );
  }
}
