// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/category.dart';

part 'category_model.g.dart';

@HiveType(typeId: 1)
class CategoryModel extends Category {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String? icon;
  @override
  @HiveField(3)
  final int? colorCode;

  const CategoryModel({
    required this.id,
    required this.name,
    this.icon,
    this.colorCode,
  }) : super(
          id: id,
          name: name,
          icon: icon,
          colorCode: colorCode,
        );

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      icon: category.icon,
      colorCode: category.colorCode,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      colorCode: colorCode,
    );
  }
}
