import 'package:fpdart/fpdart.dart';
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';
import 'package:billing_app/features/sales/data/repositories/sales_repository_impl.dart';

class CreateSaleUseCase implements UseCase<Sale, Sale> {
  final SalesRepository repository;

  CreateSaleUseCase(this.repository);

  @override
  Future<Either<Failure, Sale>> call(Sale params) {
    return repository.createSale(params);
  }
}

class GetSalesHistoryUseCase
    implements UseCase<List<Sale>, SalesHistoryParams> {
  final SalesRepository repository;

  GetSalesHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<Sale>>> call(SalesHistoryParams params) {
    return repository.getSalesHistory(
      from: params.from,
      to: params.to,
      shiftId: params.shiftId,
    );
  }
}

class SalesHistoryParams {
  final DateTime? from;
  final DateTime? to;
  final String? shiftId;

  SalesHistoryParams({this.from, this.to, this.shiftId});
}

class GetSaleByIdUseCase implements UseCase<Sale, String> {
  final SalesRepository repository;

  GetSaleByIdUseCase(this.repository);

  @override
  Future<Either<Failure, Sale>> call(String params) {
    return repository.getSaleById(params);
  }
}

class ReturnSaleUseCase implements UseCase<Sale, String> {
  final SalesRepository repository;

  ReturnSaleUseCase(this.repository);

  @override
  Future<Either<Failure, Sale>> call(String params) {
    return repository.returnSale(params);
  }
}
