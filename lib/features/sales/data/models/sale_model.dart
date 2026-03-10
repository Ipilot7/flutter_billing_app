// ignore_for_file: overridden_fields
import 'package:hive/hive.dart';
import '../../domain/entities/sale.dart';

part 'sale_model.g.dart';

@HiveType(typeId: 2)
class SaleModel extends Sale {
  @override
  @HiveField(0)
  final String id;

  @override
  @HiveField(1)
  final DateTime createdAt;

  @override
  @HiveField(2)
  final String shiftId;

  @override
  @HiveField(3)
  final String openedBy;

  @override
  @HiveField(4)
  final List<SaleItemModel> items;

  @override
  @HiveField(5)
  final double totalAmount;

  @override
  @HiveField(6)
  final int paymentType;

  @override
  @HiveField(7)
  final bool isReturned;

  @override
  @HiveField(8)
  final String? returnedSaleId;

  const SaleModel({
    required this.id,
    required this.createdAt,
    required this.shiftId,
    required this.openedBy,
    required this.items,
    required this.totalAmount,
    required this.paymentType,
    this.isReturned = false,
    this.returnedSaleId,
  }) : super(
          id: id,
          createdAt: createdAt,
          shiftId: shiftId,
          openedBy: openedBy,
          items: items,
          totalAmount: totalAmount,
          paymentType: paymentType,
          isReturned: isReturned,
          returnedSaleId: returnedSaleId,
        );

  factory SaleModel.fromEntity(Sale sale) {
    return SaleModel(
      id: sale.id,
      createdAt: sale.createdAt,
      shiftId: sale.shiftId,
      openedBy: sale.openedBy,
      items: sale.items.map((e) => SaleItemModel.fromEntity(e)).toList(),
      totalAmount: sale.totalAmount,
      paymentType: sale.paymentType,
      isReturned: sale.isReturned,
      returnedSaleId: sale.returnedSaleId,
    );
  }

  Sale toEntity() {
    return Sale(
      id: id,
      createdAt: createdAt,
      shiftId: shiftId,
      openedBy: openedBy,
      items: items.map((e) => e.toEntity()).toList(),
      totalAmount: totalAmount,
      paymentType: paymentType,
      isReturned: isReturned,
      returnedSaleId: returnedSaleId,
    );
  }
}

@HiveType(typeId: 3)
class SaleItemModel extends SaleItem {
  @override
  @HiveField(0)
  final String productId;

  @override
  @HiveField(1)
  final String productName;

  @override
  @HiveField(2)
  final double price;

  @override
  @HiveField(3)
  final int quantity;

  const SaleItemModel({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  }) : super(
          productId: productId,
          productName: productName,
          price: price,
          quantity: quantity,
        );

  factory SaleItemModel.fromEntity(SaleItem item) {
    return SaleItemModel(
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
    );
  }

  SaleItem toEntity() {
    return SaleItem(
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
    );
  }
}
