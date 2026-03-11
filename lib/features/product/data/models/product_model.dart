// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart'; // Hive generator

@HiveType(typeId: 0)
class ProductModel extends Product {
  @override
  @HiveField(0)
  final String id;
  @override
  @HiveField(1)
  final String name;
  @override
  @HiveField(2)
  final String barcode;
  @override
  @HiveField(3)
  final double price;
  @override
  @HiveField(4)
  final double stock;
  @override
  @HiveField(5)
  final String unit;

  @override
  @HiveField(6)
  final String? categoryId;

  @override
  @HiveField(7)
  final double costPrice;

  const ProductModel({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    required this.stock,
    this.costPrice = 0.0,
    this.unit = 'шт',
    this.categoryId,
  }) : super(
          id: id,
          name: name,
          barcode: barcode,
          price: price,
          costPrice: costPrice,
          stock: stock,
          unit: unit,
          categoryId: categoryId,
        );

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      barcode: product.barcode,
      price: product.price,
      costPrice: product.costPrice,
      stock: product.stock,
      unit: product.unit,
      categoryId: product.categoryId,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      barcode: barcode,
      price: price,
      costPrice: costPrice,
      stock: stock,
      unit: unit,
      categoryId: categoryId,
    );
  }
}
