class SyncProductDto {
  final String id;
  final String barcode;
  final String name;
  final double price;
  final double cost;
  final double stock;
  final String? categoryId;
  final String? categoryName;

  SyncProductDto({
    required this.id,
    required this.barcode,
    required this.name,
    required this.price,
    required this.cost,
    required this.stock,
    this.categoryId,
    this.categoryName,
  });

  factory SyncProductDto.fromJson(Map<String, dynamic> json) {
    return SyncProductDto(
      id: json['id']?.toString() ?? json['sku']?.toString() ?? '',
      barcode: json['barcode']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      cost: double.tryParse(json['cost'].toString()) ?? 0.0,
      stock: double.tryParse(json['stock'].toString()) ?? 0.0,
      categoryId: json['category']?.toString(),
      categoryName: json['category_name']?.toString(),
    );
  }

  Map<String, dynamic> toUpsertPayload() {
    final payload = {
      'sku': id,
      'barcode': barcode,
      'name': name,
      'price': price.toStringAsFixed(2),
      'cost': cost.toStringAsFixed(2),
      'stock': stock.toStringAsFixed(3),
      'min_stock': '0.000',
      'is_active': true,
    };
    if (categoryName != null) {
      payload['category_name'] = categoryName!;
    }
    return payload;
  }
}

class SyncCategoryDto {
  final String id;
  final String name;

  SyncCategoryDto({required this.id, required this.name});

  factory SyncCategoryDto.fromJson(Map<String, dynamic> json) {
    return SyncCategoryDto(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toUpsertPayload() {
    return {
      'name': name,
      'local_id': id,
    };
  }
}

class SyncOperationDto {
  final String operationId;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> payload;

  SyncOperationDto({
    required this.operationId,
    required this.entityType,
    required this.entityId,
    required this.payload,
  });

  Map<String, dynamic> toJson() {
    return {
      'operation_id': operationId,
      'entity_type': entityType,
      'entity_id': entityId,
      'payload': payload,
    };
  }
}

class SyncSaleItemDto {
  final String barcode;
  final String productName;
  final double quantity;
  final double price;
  final double discount;

  SyncSaleItemDto({
    required this.barcode,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'product_name': productName,
      'quantity': quantity.toStringAsFixed(3),
      'price': price.toStringAsFixed(2),
      'discount': discount.toStringAsFixed(2),
      'line_total': ((price * quantity) - discount).toStringAsFixed(2),
    };
  }
}

class SyncSaleDto {
  final String shiftId;
  final String receiptNumber;
  final String paymentType;
  final double subtotal;
  final double discountTotal;
  final double total;
  final List<SyncSaleItemDto> items;

  SyncSaleDto({
    required this.shiftId,
    required this.receiptNumber,
    required this.paymentType,
    required this.subtotal,
    required this.discountTotal,
    required this.total,
    required this.items,
  });

  Map<String, dynamic> toJson() {
    return {
      'shift_id': shiftId,
      'receipt_number': receiptNumber,
      'payment_type': paymentType,
      'subtotal': subtotal.toStringAsFixed(2),
      'discount_total': discountTotal.toStringAsFixed(2),
      'total': total.toStringAsFixed(2),
      'items': items.map((i) => i.toJson()).toList(),
    };
  }
}
