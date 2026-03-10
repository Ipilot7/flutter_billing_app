import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String
      id; // Using barcode as ID usually, but keeping separate ID is safer
  final String name;
  final String barcode;
  final double price;
  final String unit;
  final int stock; // Optional implementation detail

  const Product({
    required this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.unit = 'шт',
    this.stock = 0,
  });

  @override
  List<Object?> get props => [id, name, barcode, price, unit, stock];
}
