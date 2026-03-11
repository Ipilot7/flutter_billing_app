import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/category_usecases.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryBloc({
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(const CategoryState()) {
    on<GetCategoriesEvent>(_onGetCategories);
    on<AddCategoryEvent>(_onAddCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
  }

  Future<void> _onGetCategories(
      GetCategoriesEvent event, Emitter<CategoryState> emit) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await getCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, errorMessage: failure.message)),
      (categories) => emit(state.copyWith(
          status: CategoryStatus.loaded, categories: categories)),
    );
  }

  Future<void> _onAddCategory(
      AddCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await addCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, errorMessage: failure.message)),
      (_) => add(GetCategoriesEvent()),
    );
  }

  Future<void> _onUpdateCategory(
      UpdateCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await updateCategoryUseCase(event.category);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, errorMessage: failure.message)),
      (_) => add(GetCategoriesEvent()),
    );
  }

  Future<void> _onDeleteCategory(
      DeleteCategoryEvent event, Emitter<CategoryState> emit) async {
    final result = await deleteCategoryUseCase(event.id);
    result.fold(
      (failure) => emit(state.copyWith(
          status: CategoryStatus.error, errorMessage: failure.message)),
      (_) => add(GetCategoriesEvent()),
    );
  }
}
