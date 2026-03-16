import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/features/product/domain/entities/category.dart';

extension CategoryTableX on CategoryTable {
  Category toDomain() {
    return Category(
      id: id,
      name: name,
      icon: icon,
      colorCode: colorCode,
    );
  }
}

extension CategoryX on Category {
  CategoryTable toTable() {
    return CategoryTable(
      id: id,
      name: name,
      icon: icon,
      colorCode: colorCode,
    );
  }
}
