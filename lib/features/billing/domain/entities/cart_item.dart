import 'package:equatable/equatable.dart';
import 'package:billing_app/features/product/domain/entities/product.dart';

class CartItem extends Equatable {
  final Product product;
  final double quantity;
  final double? priceOverride;
  final double discount; // Fixed amount discount per item total

  const CartItem({
    required this.product,
    this.quantity = 1,
    this.priceOverride,
    this.discount = 0.0,
  });

  double get price => priceOverride ?? product.price;
  double get total => (price * quantity) - discount;

  CartItem copyWith({
    Product? product,
    double? quantity,
    double? priceOverride,
    double? discount,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      priceOverride: priceOverride ?? this.priceOverride,
      discount: discount ?? this.discount,
    );
  }

  @override
  List<Object?> get props => [product, quantity, priceOverride, discount];
}
