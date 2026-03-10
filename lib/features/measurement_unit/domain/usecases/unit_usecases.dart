import 'package:fpdart/fpdart.dart' hide Unit;
import 'package:billing_app/core/error/failure.dart';
import 'package:billing_app/core/usecase/usecase.dart';
import 'package:billing_app/features/measurement_unit/domain/entities/unit.dart';
import 'package:billing_app/features/measurement_unit/data/repositories/unit_repository_impl.dart';

class AddUnitUseCase implements UseCase<Unit, AddUnitParams> {
  final UnitRepository repository;

  AddUnitUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(AddUnitParams params) {
    return repository.addUnit(params.name, params.shortName);
  }
}

class AddUnitParams {
  final String name;
  final String shortName;

  AddUnitParams({required this.name, required this.shortName});
}

class UpdateUnitUseCase implements UseCase<Unit, Unit> {
  final UnitRepository repository;

  UpdateUnitUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(Unit params) {
    return repository.updateUnit(params);
  }
}

class DeleteUnitUseCase implements UseCase<void, String> {
  final UnitRepository repository;

  DeleteUnitUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String params) {
    return repository.deleteUnit(params);
  }
}

class GetAllUnitsUseCase implements UseCase<List<Unit>, NoParams> {
  final UnitRepository repository;

  GetAllUnitsUseCase(this.repository);

  @override
  Future<Either<Failure, List<Unit>>> call(NoParams params) {
    return repository.getAllUnits();
  }
}
