import 'package:drift/drift.dart';
import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/features/sales/domain/entities/sale.dart';

extension SaleTableX on SaleTable {
  Sale toDomain(List<SaleItem> items) {
    return Sale(
      id: id,
      createdAt: createdAt,
      shiftId: shiftId,
      openedBy: openedBy,
      items: items,
      totalAmount: totalAmount,
      paymentType: paymentType,
      isReturned: isReturned,
      returnedSaleId: returnedSaleId,
      globalDiscount: globalDiscount,
    );
  }
}

extension SaleX on Sale {
  SaleTable toTable() {
    return SaleTable(
      id: id,
      createdAt: createdAt,
      shiftId: shiftId,
      openedBy: openedBy,
      totalAmount: totalAmount,
      paymentType: paymentType,
      isReturned: isReturned,
      returnedSaleId: returnedSaleId,
      globalDiscount: globalDiscount,
    );
  }
}

extension SaleItemTableX on SaleItemTable {
  SaleItem toDomain() {
    return SaleItem(
      productId: productId,
      productName: productName,
      categoryId: categoryId,
      categoryName: categoryName,
      price: price,
      quantity: quantity,
      discount: discount,
      costPrice: costPrice,
    );
  }
}

extension SaleItemX on SaleItem {
  SaleItemsCompanion toCompanion(String saleId) {
    return SaleItemsCompanion.insert(
      saleId: saleId,
      productId: productId,
      productName: productName,
      categoryId: Value(categoryId),
      categoryName: Value(categoryName),
      price: price,
      quantity: quantity,
      discount: Value(discount),
      costPrice: Value(costPrice),
    );
  }
}
