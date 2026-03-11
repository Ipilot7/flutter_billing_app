import 'package:equatable/equatable.dart';
import '../../domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();
  @override
  List<Object?> get props => [];
}

class GetCategoriesEvent extends CategoryEvent {}

class AddCategoryEvent extends CategoryEvent {
  final Category category;
  const AddCategoryEvent(this.category);
  @override
  List<Object?> get props => [category];
}

class UpdateCategoryEvent extends CategoryEvent {
  final Category category;
  const UpdateCategoryEvent(this.category);
  @override
  List<Object?> get props => [category];
}

class DeleteCategoryEvent extends CategoryEvent {
  final String id;
  const DeleteCategoryEvent(this.id);
  @override
  List<Object?> get props => [id];
}
