import 'package:bloc/bloc.dart';
import 'package:billing_app/features/sales/domain/usecases/sales_usecases.dart';
import 'sales_event.dart';
import 'sales_state.dart';

class SalesBloc extends Bloc<SalesEvent, SalesState> {
  final GetSalesHistoryUseCase getSalesHistoryUseCase;
  final ReturnSaleUseCase returnSaleUseCase;

  SalesBloc({
    required this.getSalesHistoryUseCase,
    required this.returnSaleUseCase,
  }) : super(SalesInitial()) {
    on<LoadSalesHistoryEvent>(_onLoadSalesHistory);
    on<ReturnSaleEvent>(_onReturnSale);

    // Auto-load sales history
    add(const LoadSalesHistoryEvent());
  }

  Future<void> _onLoadSalesHistory(
    LoadSalesHistoryEvent event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());
    final result = await getSalesHistoryUseCase(SalesHistoryParams(
      from: event.from,
      to: event.to,
      shiftId: event.shiftId,
    ));
    result.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (sales) => emit(SalesLoaded(sales: sales)),
    );
  }

  Future<void> _onReturnSale(
    ReturnSaleEvent event,
    Emitter<SalesState> emit,
  ) async {
    emit(SalesLoading());
    final result = await returnSaleUseCase(event.saleId);
    result.fold(
      (failure) => emit(SalesError(message: failure.message)),
      (sale) => add(const LoadSalesHistoryEvent()),
    );
  }
}
