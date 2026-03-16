import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';

extension ProductTableX on ProductTable {
  Product toDomain() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      costPrice: costPrice,
      stock: stock,
      unit: unit,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }
}

extension ProductX on Product {
  ProductTable toTable() {
    return ProductTable(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      costPrice: costPrice,
      stock: stock,
      unit: unit,
      categoryId: categoryId,
      categoryName: categoryName,
    );
  }
}
