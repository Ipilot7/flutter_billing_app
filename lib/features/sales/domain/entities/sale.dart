import 'package:equatable/equatable.dart';

class Sale extends Equatable {
  final String id;
  final DateTime createdAt;
  final String shiftId;
  final String openedBy;
  final List<SaleItem> items;
  final double totalAmount;
  final int paymentType; // 0 = cash, 1 = card, 2 = terminal
  final bool isReturned;
  final String? returnedSaleId;

  const Sale({
    required this.id,
    required this.createdAt,
    required this.shiftId,
    required this.openedBy,
    required this.items,
    required this.totalAmount,
    required this.paymentType,
    this.isReturned = false,
    this.returnedSaleId,
  });

  Sale copyWith({
    String? id,
    DateTime? createdAt,
    String? shiftId,
    String? openedBy,
    List<SaleItem>? items,
    double? totalAmount,
    int? paymentType,
    bool? isReturned,
    String? returnedSaleId,
  }) {
    return Sale(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      shiftId: shiftId ?? this.shiftId,
      openedBy: openedBy ?? this.openedBy,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentType: paymentType ?? this.paymentType,
      isReturned: isReturned ?? this.isReturned,
      returnedSaleId: returnedSaleId ?? this.returnedSaleId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        createdAt,
        shiftId,
        openedBy,
        items,
        totalAmount,
        paymentType,
        isReturned,
        returnedSaleId
      ];
}

class SaleItem extends Equatable {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const SaleItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get total => price * quantity;

  @override
  List<Object?> get props => [productId, productName, price, quantity];
}
