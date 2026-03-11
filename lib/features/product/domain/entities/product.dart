import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final double costPrice;
  final String unit;
  final double stock;
  final String? categoryId;

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.costPrice = 0.0,
    this.unit = 'шт',
    this.stock = 0.0,
    this.categoryId,
  });

  Product copyWith({
    String? id,
    String? name,
    String? barcode,
    double? price,
    double? costPrice,
    String? unit,
    double? stock,
    String? categoryId,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
    );
  }

  @override
  List<Object?> get props =>
      [id, name, barcode, price, costPrice, unit, stock, categoryId];
}
