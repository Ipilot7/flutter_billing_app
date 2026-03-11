// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorCodeMeta =
      const VerificationMeta('colorCode');
  @override
  late final GeneratedColumn<int> colorCode = GeneratedColumn<int>(
      'color_code', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, icon, colorCode];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('color_code')) {
      context.handle(_colorCodeMeta,
          colorCode.isAcceptableOrUnknown(data['color_code']!, _colorCodeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      colorCode: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_code']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryTable extends DataClass implements Insertable<CategoryTable> {
  final String id;
  final String name;
  final String? icon;
  final int? colorCode;
  const CategoryTable(
      {required this.id, required this.name, this.icon, this.colorCode});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    if (!nullToAbsent || colorCode != null) {
      map['color_code'] = Variable<int>(colorCode);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      colorCode: colorCode == null && nullToAbsent
          ? const Value.absent()
          : Value(colorCode),
    );
  }

  factory CategoryTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTable(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      icon: serializer.fromJson<String?>(json['icon']),
      colorCode: serializer.fromJson<int?>(json['colorCode']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'icon': serializer.toJson<String?>(icon),
      'colorCode': serializer.toJson<int?>(colorCode),
    };
  }

  CategoryTable copyWith(
          {String? id,
          String? name,
          Value<String?> icon = const Value.absent(),
          Value<int?> colorCode = const Value.absent()}) =>
      CategoryTable(
        id: id ?? this.id,
        name: name ?? this.name,
        icon: icon.present ? icon.value : this.icon,
        colorCode: colorCode.present ? colorCode.value : this.colorCode,
      );
  CategoryTable copyWithCompanion(CategoriesCompanion data) {
    return CategoryTable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      icon: data.icon.present ? data.icon.value : this.icon,
      colorCode: data.colorCode.present ? data.colorCode.value : this.colorCode,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorCode: $colorCode')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, icon, colorCode);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTable &&
          other.id == this.id &&
          other.name == this.name &&
          other.icon == this.icon &&
          other.colorCode == this.colorCode);
}

class CategoriesCompanion extends UpdateCompanion<CategoryTable> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> icon;
  final Value<int?> colorCode;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.icon = const Value.absent(),
    this.colorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    required String name,
    this.icon = const Value.absent(),
    this.colorCode = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name);
  static Insertable<CategoryTable> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? icon,
    Expression<int>? colorCode,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (icon != null) 'icon': icon,
      if (colorCode != null) 'color_code': colorCode,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String?>? icon,
      Value<int?>? colorCode,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      colorCode: colorCode ?? this.colorCode,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (colorCode.present) {
      map['color_code'] = Variable<int>(colorCode.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('icon: $icon, ')
          ..write('colorCode: $colorCode, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products
    with TableInfo<$ProductsTable, ProductTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _barcodeMeta =
      const VerificationMeta('barcode');
  @override
  late final GeneratedColumn<String> barcode = GeneratedColumn<String>(
      'barcode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _costPriceMeta =
      const VerificationMeta('costPrice');
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
      'cost_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _stockMeta = const VerificationMeta('stock');
  @override
  late final GeneratedColumn<double> stock = GeneratedColumn<double>(
      'stock', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _unitMeta = const VerificationMeta('unit');
  @override
  late final GeneratedColumn<String> unit = GeneratedColumn<String>(
      'unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('шт'));
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, barcode, price, costPrice, stock, unit, categoryId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<ProductTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('barcode')) {
      context.handle(_barcodeMeta,
          barcode.isAcceptableOrUnknown(data['barcode']!, _barcodeMeta));
    } else if (isInserting) {
      context.missing(_barcodeMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('cost_price')) {
      context.handle(_costPriceMeta,
          costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta));
    }
    if (data.containsKey('stock')) {
      context.handle(
          _stockMeta, stock.isAcceptableOrUnknown(data['stock']!, _stockMeta));
    }
    if (data.containsKey('unit')) {
      context.handle(
          _unitMeta, unit.isAcceptableOrUnknown(data['unit']!, _unitMeta));
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      barcode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}barcode'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      costPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price'])!,
      stock: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}stock'])!,
      unit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}unit'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class ProductTable extends DataClass implements Insertable<ProductTable> {
  final String id;
  final String name;
  final String barcode;
  final double price;
  final double costPrice;
  final double stock;
  final String unit;
  final String? categoryId;
  const ProductTable(
      {required this.id,
      required this.name,
      required this.barcode,
      required this.price,
      required this.costPrice,
      required this.stock,
      required this.unit,
      this.categoryId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['barcode'] = Variable<String>(barcode);
    map['price'] = Variable<double>(price);
    map['cost_price'] = Variable<double>(costPrice);
    map['stock'] = Variable<double>(stock);
    map['unit'] = Variable<String>(unit);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      barcode: Value(barcode),
      price: Value(price),
      costPrice: Value(costPrice),
      stock: Value(stock),
      unit: Value(unit),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
    );
  }

  factory ProductTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductTable(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      barcode: serializer.fromJson<String>(json['barcode']),
      price: serializer.fromJson<double>(json['price']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
      stock: serializer.fromJson<double>(json['stock']),
      unit: serializer.fromJson<String>(json['unit']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'barcode': serializer.toJson<String>(barcode),
      'price': serializer.toJson<double>(price),
      'costPrice': serializer.toJson<double>(costPrice),
      'stock': serializer.toJson<double>(stock),
      'unit': serializer.toJson<String>(unit),
      'categoryId': serializer.toJson<String?>(categoryId),
    };
  }

  ProductTable copyWith(
          {String? id,
          String? name,
          String? barcode,
          double? price,
          double? costPrice,
          double? stock,
          String? unit,
          Value<String?> categoryId = const Value.absent()}) =>
      ProductTable(
        id: id ?? this.id,
        name: name ?? this.name,
        barcode: barcode ?? this.barcode,
        price: price ?? this.price,
        costPrice: costPrice ?? this.costPrice,
        stock: stock ?? this.stock,
        unit: unit ?? this.unit,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
      );
  ProductTable copyWithCompanion(ProductsCompanion data) {
    return ProductTable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      barcode: data.barcode.present ? data.barcode.value : this.barcode,
      price: data.price.present ? data.price.value : this.price,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
      stock: data.stock.present ? data.stock.value : this.stock,
      unit: data.unit.present ? data.unit.value : this.unit,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductTable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('stock: $stock, ')
          ..write('unit: $unit, ')
          ..write('categoryId: $categoryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, barcode, price, costPrice, stock, unit, categoryId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductTable &&
          other.id == this.id &&
          other.name == this.name &&
          other.barcode == this.barcode &&
          other.price == this.price &&
          other.costPrice == this.costPrice &&
          other.stock == this.stock &&
          other.unit == this.unit &&
          other.categoryId == this.categoryId);
}

class ProductsCompanion extends UpdateCompanion<ProductTable> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> barcode;
  final Value<double> price;
  final Value<double> costPrice;
  final Value<double> stock;
  final Value<String> unit;
  final Value<String?> categoryId;
  final Value<int> rowid;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.barcode = const Value.absent(),
    this.price = const Value.absent(),
    this.costPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.unit = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductsCompanion.insert({
    required String id,
    required String name,
    required String barcode,
    required double price,
    this.costPrice = const Value.absent(),
    this.stock = const Value.absent(),
    this.unit = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        barcode = Value(barcode),
        price = Value(price);
  static Insertable<ProductTable> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? barcode,
    Expression<double>? price,
    Expression<double>? costPrice,
    Expression<double>? stock,
    Expression<String>? unit,
    Expression<String>? categoryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (barcode != null) 'barcode': barcode,
      if (price != null) 'price': price,
      if (costPrice != null) 'cost_price': costPrice,
      if (stock != null) 'stock': stock,
      if (unit != null) 'unit': unit,
      if (categoryId != null) 'category_id': categoryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? barcode,
      Value<double>? price,
      Value<double>? costPrice,
      Value<double>? stock,
      Value<String>? unit,
      Value<String?>? categoryId,
      Value<int>? rowid}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      categoryId: categoryId ?? this.categoryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (barcode.present) {
      map['barcode'] = Variable<String>(barcode.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    if (stock.present) {
      map['stock'] = Variable<double>(stock.value);
    }
    if (unit.present) {
      map['unit'] = Variable<String>(unit.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('barcode: $barcode, ')
          ..write('price: $price, ')
          ..write('costPrice: $costPrice, ')
          ..write('stock: $stock, ')
          ..write('unit: $unit, ')
          ..write('categoryId: $categoryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UnitsTable extends Units with TableInfo<$UnitsTable, UnitTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UnitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shortNameMeta =
      const VerificationMeta('shortName');
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
      'short_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [id, name, shortName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'units';
  @override
  VerificationContext validateIntegrity(Insertable<UnitTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('short_name')) {
      context.handle(_shortNameMeta,
          shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta));
    } else if (isInserting) {
      context.missing(_shortNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UnitTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UnitTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shortName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}short_name'])!,
    );
  }

  @override
  $UnitsTable createAlias(String alias) {
    return $UnitsTable(attachedDatabase, alias);
  }
}

class UnitTable extends DataClass implements Insertable<UnitTable> {
  final String id;
  final String name;
  final String shortName;
  const UnitTable(
      {required this.id, required this.name, required this.shortName});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['short_name'] = Variable<String>(shortName);
    return map;
  }

  UnitsCompanion toCompanion(bool nullToAbsent) {
    return UnitsCompanion(
      id: Value(id),
      name: Value(name),
      shortName: Value(shortName),
    );
  }

  factory UnitTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UnitTable(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shortName: serializer.fromJson<String>(json['shortName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'shortName': serializer.toJson<String>(shortName),
    };
  }

  UnitTable copyWith({String? id, String? name, String? shortName}) =>
      UnitTable(
        id: id ?? this.id,
        name: name ?? this.name,
        shortName: shortName ?? this.shortName,
      );
  UnitTable copyWithCompanion(UnitsCompanion data) {
    return UnitTable(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UnitTable(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, shortName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UnitTable &&
          other.id == this.id &&
          other.name == this.name &&
          other.shortName == this.shortName);
}

class UnitsCompanion extends UpdateCompanion<UnitTable> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> shortName;
  final Value<int> rowid;
  const UnitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shortName = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UnitsCompanion.insert({
    required String id,
    required String name,
    required String shortName,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        shortName = Value(shortName);
  static Insertable<UnitTable> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? shortName,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shortName != null) 'short_name': shortName,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UnitsCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? shortName,
      Value<int>? rowid}) {
    return UnitsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shortName: shortName ?? this.shortName,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UnitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shortName: $shortName, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShopDetailsTable extends ShopDetails
    with TableInfo<$ShopDetailsTable, ShopTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressLine1Meta =
      const VerificationMeta('addressLine1');
  @override
  late final GeneratedColumn<String> addressLine1 = GeneratedColumn<String>(
      'address_line1', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _addressLine2Meta =
      const VerificationMeta('addressLine2');
  @override
  late final GeneratedColumn<String> addressLine2 = GeneratedColumn<String>(
      'address_line2', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneNumberMeta =
      const VerificationMeta('phoneNumber');
  @override
  late final GeneratedColumn<String> phoneNumber = GeneratedColumn<String>(
      'phone_number', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _upiIdMeta = const VerificationMeta('upiId');
  @override
  late final GeneratedColumn<String> upiId = GeneratedColumn<String>(
      'upi_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _footerTextMeta =
      const VerificationMeta('footerText');
  @override
  late final GeneratedColumn<String> footerText = GeneratedColumn<String>(
      'footer_text', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [name, addressLine1, addressLine2, phoneNumber, upiId, footerText];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_details';
  @override
  VerificationContext validateIntegrity(Insertable<ShopTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('address_line1')) {
      context.handle(
          _addressLine1Meta,
          addressLine1.isAcceptableOrUnknown(
              data['address_line1']!, _addressLine1Meta));
    } else if (isInserting) {
      context.missing(_addressLine1Meta);
    }
    if (data.containsKey('address_line2')) {
      context.handle(
          _addressLine2Meta,
          addressLine2.isAcceptableOrUnknown(
              data['address_line2']!, _addressLine2Meta));
    } else if (isInserting) {
      context.missing(_addressLine2Meta);
    }
    if (data.containsKey('phone_number')) {
      context.handle(
          _phoneNumberMeta,
          phoneNumber.isAcceptableOrUnknown(
              data['phone_number']!, _phoneNumberMeta));
    } else if (isInserting) {
      context.missing(_phoneNumberMeta);
    }
    if (data.containsKey('upi_id')) {
      context.handle(
          _upiIdMeta, upiId.isAcceptableOrUnknown(data['upi_id']!, _upiIdMeta));
    } else if (isInserting) {
      context.missing(_upiIdMeta);
    }
    if (data.containsKey('footer_text')) {
      context.handle(
          _footerTextMeta,
          footerText.isAcceptableOrUnknown(
              data['footer_text']!, _footerTextMeta));
    } else if (isInserting) {
      context.missing(_footerTextMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ShopTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopTable(
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      addressLine1: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address_line1'])!,
      addressLine2: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}address_line2'])!,
      phoneNumber: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone_number'])!,
      upiId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}upi_id'])!,
      footerText: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}footer_text'])!,
    );
  }

  @override
  $ShopDetailsTable createAlias(String alias) {
    return $ShopDetailsTable(attachedDatabase, alias);
  }
}

class ShopTable extends DataClass implements Insertable<ShopTable> {
  final String name;
  final String addressLine1;
  final String addressLine2;
  final String phoneNumber;
  final String upiId;
  final String footerText;
  const ShopTable(
      {required this.name,
      required this.addressLine1,
      required this.addressLine2,
      required this.phoneNumber,
      required this.upiId,
      required this.footerText});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['name'] = Variable<String>(name);
    map['address_line1'] = Variable<String>(addressLine1);
    map['address_line2'] = Variable<String>(addressLine2);
    map['phone_number'] = Variable<String>(phoneNumber);
    map['upi_id'] = Variable<String>(upiId);
    map['footer_text'] = Variable<String>(footerText);
    return map;
  }

  ShopDetailsCompanion toCompanion(bool nullToAbsent) {
    return ShopDetailsCompanion(
      name: Value(name),
      addressLine1: Value(addressLine1),
      addressLine2: Value(addressLine2),
      phoneNumber: Value(phoneNumber),
      upiId: Value(upiId),
      footerText: Value(footerText),
    );
  }

  factory ShopTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopTable(
      name: serializer.fromJson<String>(json['name']),
      addressLine1: serializer.fromJson<String>(json['addressLine1']),
      addressLine2: serializer.fromJson<String>(json['addressLine2']),
      phoneNumber: serializer.fromJson<String>(json['phoneNumber']),
      upiId: serializer.fromJson<String>(json['upiId']),
      footerText: serializer.fromJson<String>(json['footerText']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'name': serializer.toJson<String>(name),
      'addressLine1': serializer.toJson<String>(addressLine1),
      'addressLine2': serializer.toJson<String>(addressLine2),
      'phoneNumber': serializer.toJson<String>(phoneNumber),
      'upiId': serializer.toJson<String>(upiId),
      'footerText': serializer.toJson<String>(footerText),
    };
  }

  ShopTable copyWith(
          {String? name,
          String? addressLine1,
          String? addressLine2,
          String? phoneNumber,
          String? upiId,
          String? footerText}) =>
      ShopTable(
        name: name ?? this.name,
        addressLine1: addressLine1 ?? this.addressLine1,
        addressLine2: addressLine2 ?? this.addressLine2,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        upiId: upiId ?? this.upiId,
        footerText: footerText ?? this.footerText,
      );
  ShopTable copyWithCompanion(ShopDetailsCompanion data) {
    return ShopTable(
      name: data.name.present ? data.name.value : this.name,
      addressLine1: data.addressLine1.present
          ? data.addressLine1.value
          : this.addressLine1,
      addressLine2: data.addressLine2.present
          ? data.addressLine2.value
          : this.addressLine2,
      phoneNumber:
          data.phoneNumber.present ? data.phoneNumber.value : this.phoneNumber,
      upiId: data.upiId.present ? data.upiId.value : this.upiId,
      footerText:
          data.footerText.present ? data.footerText.value : this.footerText,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopTable(')
          ..write('name: $name, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('upiId: $upiId, ')
          ..write('footerText: $footerText')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      name, addressLine1, addressLine2, phoneNumber, upiId, footerText);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopTable &&
          other.name == this.name &&
          other.addressLine1 == this.addressLine1 &&
          other.addressLine2 == this.addressLine2 &&
          other.phoneNumber == this.phoneNumber &&
          other.upiId == this.upiId &&
          other.footerText == this.footerText);
}

class ShopDetailsCompanion extends UpdateCompanion<ShopTable> {
  final Value<String> name;
  final Value<String> addressLine1;
  final Value<String> addressLine2;
  final Value<String> phoneNumber;
  final Value<String> upiId;
  final Value<String> footerText;
  final Value<int> rowid;
  const ShopDetailsCompanion({
    this.name = const Value.absent(),
    this.addressLine1 = const Value.absent(),
    this.addressLine2 = const Value.absent(),
    this.phoneNumber = const Value.absent(),
    this.upiId = const Value.absent(),
    this.footerText = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShopDetailsCompanion.insert({
    required String name,
    required String addressLine1,
    required String addressLine2,
    required String phoneNumber,
    required String upiId,
    required String footerText,
    this.rowid = const Value.absent(),
  })  : name = Value(name),
        addressLine1 = Value(addressLine1),
        addressLine2 = Value(addressLine2),
        phoneNumber = Value(phoneNumber),
        upiId = Value(upiId),
        footerText = Value(footerText);
  static Insertable<ShopTable> custom({
    Expression<String>? name,
    Expression<String>? addressLine1,
    Expression<String>? addressLine2,
    Expression<String>? phoneNumber,
    Expression<String>? upiId,
    Expression<String>? footerText,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (name != null) 'name': name,
      if (addressLine1 != null) 'address_line1': addressLine1,
      if (addressLine2 != null) 'address_line2': addressLine2,
      if (phoneNumber != null) 'phone_number': phoneNumber,
      if (upiId != null) 'upi_id': upiId,
      if (footerText != null) 'footer_text': footerText,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShopDetailsCompanion copyWith(
      {Value<String>? name,
      Value<String>? addressLine1,
      Value<String>? addressLine2,
      Value<String>? phoneNumber,
      Value<String>? upiId,
      Value<String>? footerText,
      Value<int>? rowid}) {
    return ShopDetailsCompanion(
      name: name ?? this.name,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      upiId: upiId ?? this.upiId,
      footerText: footerText ?? this.footerText,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (addressLine1.present) {
      map['address_line1'] = Variable<String>(addressLine1.value);
    }
    if (addressLine2.present) {
      map['address_line2'] = Variable<String>(addressLine2.value);
    }
    if (phoneNumber.present) {
      map['phone_number'] = Variable<String>(phoneNumber.value);
    }
    if (upiId.present) {
      map['upi_id'] = Variable<String>(upiId.value);
    }
    if (footerText.present) {
      map['footer_text'] = Variable<String>(footerText.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopDetailsCompanion(')
          ..write('name: $name, ')
          ..write('addressLine1: $addressLine1, ')
          ..write('addressLine2: $addressLine2, ')
          ..write('phoneNumber: $phoneNumber, ')
          ..write('upiId: $upiId, ')
          ..write('footerText: $footerText, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ShiftsTable extends Shifts with TableInfo<$ShiftsTable, ShiftTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShiftsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _openedAtMeta =
      const VerificationMeta('openedAt');
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
      'opened_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _openedByMeta =
      const VerificationMeta('openedBy');
  @override
  late final GeneratedColumn<String> openedBy = GeneratedColumn<String>(
      'opened_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startBalanceMeta =
      const VerificationMeta('startBalance');
  @override
  late final GeneratedColumn<double> startBalance = GeneratedColumn<double>(
      'start_balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _endBalanceMeta =
      const VerificationMeta('endBalance');
  @override
  late final GeneratedColumn<double> endBalance = GeneratedColumn<double>(
      'end_balance', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
      'status', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, openedAt, closedAt, openedBy, startBalance, endBalance, status];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shifts';
  @override
  VerificationContext validateIntegrity(Insertable<ShiftTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(_openedAtMeta,
          openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta));
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('opened_by')) {
      context.handle(_openedByMeta,
          openedBy.isAcceptableOrUnknown(data['opened_by']!, _openedByMeta));
    } else if (isInserting) {
      context.missing(_openedByMeta);
    }
    if (data.containsKey('start_balance')) {
      context.handle(
          _startBalanceMeta,
          startBalance.isAcceptableOrUnknown(
              data['start_balance']!, _startBalanceMeta));
    } else if (isInserting) {
      context.missing(_startBalanceMeta);
    }
    if (data.containsKey('end_balance')) {
      context.handle(
          _endBalanceMeta,
          endBalance.isAcceptableOrUnknown(
              data['end_balance']!, _endBalanceMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShiftTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShiftTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      openedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}opened_at'])!,
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at']),
      openedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opened_by'])!,
      startBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}start_balance'])!,
      endBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}end_balance']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}status'])!,
    );
  }

  @override
  $ShiftsTable createAlias(String alias) {
    return $ShiftsTable(attachedDatabase, alias);
  }
}

class ShiftTable extends DataClass implements Insertable<ShiftTable> {
  final String id;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String openedBy;
  final double startBalance;
  final double? endBalance;
  final int status;
  const ShiftTable(
      {required this.id,
      required this.openedAt,
      this.closedAt,
      required this.openedBy,
      required this.startBalance,
      this.endBalance,
      required this.status});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    map['opened_by'] = Variable<String>(openedBy);
    map['start_balance'] = Variable<double>(startBalance);
    if (!nullToAbsent || endBalance != null) {
      map['end_balance'] = Variable<double>(endBalance);
    }
    map['status'] = Variable<int>(status);
    return map;
  }

  ShiftsCompanion toCompanion(bool nullToAbsent) {
    return ShiftsCompanion(
      id: Value(id),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
      openedBy: Value(openedBy),
      startBalance: Value(startBalance),
      endBalance: endBalance == null && nullToAbsent
          ? const Value.absent()
          : Value(endBalance),
      status: Value(status),
    );
  }

  factory ShiftTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShiftTable(
      id: serializer.fromJson<String>(json['id']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
      openedBy: serializer.fromJson<String>(json['openedBy']),
      startBalance: serializer.fromJson<double>(json['startBalance']),
      endBalance: serializer.fromJson<double?>(json['endBalance']),
      status: serializer.fromJson<int>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
      'openedBy': serializer.toJson<String>(openedBy),
      'startBalance': serializer.toJson<double>(startBalance),
      'endBalance': serializer.toJson<double?>(endBalance),
      'status': serializer.toJson<int>(status),
    };
  }

  ShiftTable copyWith(
          {String? id,
          DateTime? openedAt,
          Value<DateTime?> closedAt = const Value.absent(),
          String? openedBy,
          double? startBalance,
          Value<double?> endBalance = const Value.absent(),
          int? status}) =>
      ShiftTable(
        id: id ?? this.id,
        openedAt: openedAt ?? this.openedAt,
        closedAt: closedAt.present ? closedAt.value : this.closedAt,
        openedBy: openedBy ?? this.openedBy,
        startBalance: startBalance ?? this.startBalance,
        endBalance: endBalance.present ? endBalance.value : this.endBalance,
        status: status ?? this.status,
      );
  ShiftTable copyWithCompanion(ShiftsCompanion data) {
    return ShiftTable(
      id: data.id.present ? data.id.value : this.id,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      openedBy: data.openedBy.present ? data.openedBy.value : this.openedBy,
      startBalance: data.startBalance.present
          ? data.startBalance.value
          : this.startBalance,
      endBalance:
          data.endBalance.present ? data.endBalance.value : this.endBalance,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShiftTable(')
          ..write('id: $id, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openedBy: $openedBy, ')
          ..write('startBalance: $startBalance, ')
          ..write('endBalance: $endBalance, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, openedAt, closedAt, openedBy, startBalance, endBalance, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShiftTable &&
          other.id == this.id &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt &&
          other.openedBy == this.openedBy &&
          other.startBalance == this.startBalance &&
          other.endBalance == this.endBalance &&
          other.status == this.status);
}

class ShiftsCompanion extends UpdateCompanion<ShiftTable> {
  final Value<String> id;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<String> openedBy;
  final Value<double> startBalance;
  final Value<double?> endBalance;
  final Value<int> status;
  final Value<int> rowid;
  const ShiftsCompanion({
    this.id = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.openedBy = const Value.absent(),
    this.startBalance = const Value.absent(),
    this.endBalance = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ShiftsCompanion.insert({
    required String id,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    required String openedBy,
    required double startBalance,
    this.endBalance = const Value.absent(),
    required int status,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        openedAt = Value(openedAt),
        openedBy = Value(openedBy),
        startBalance = Value(startBalance),
        status = Value(status);
  static Insertable<ShiftTable> custom({
    Expression<String>? id,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<String>? openedBy,
    Expression<double>? startBalance,
    Expression<double>? endBalance,
    Expression<int>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (openedBy != null) 'opened_by': openedBy,
      if (startBalance != null) 'start_balance': startBalance,
      if (endBalance != null) 'end_balance': endBalance,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ShiftsCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? openedAt,
      Value<DateTime?>? closedAt,
      Value<String>? openedBy,
      Value<double>? startBalance,
      Value<double?>? endBalance,
      Value<int>? status,
      Value<int>? rowid}) {
    return ShiftsCompanion(
      id: id ?? this.id,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      openedBy: openedBy ?? this.openedBy,
      startBalance: startBalance ?? this.startBalance,
      endBalance: endBalance ?? this.endBalance,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (openedBy.present) {
      map['opened_by'] = Variable<String>(openedBy.value);
    }
    if (startBalance.present) {
      map['start_balance'] = Variable<double>(startBalance.value);
    }
    if (endBalance.present) {
      map['end_balance'] = Variable<double>(endBalance.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShiftsCompanion(')
          ..write('id: $id, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('openedBy: $openedBy, ')
          ..write('startBalance: $startBalance, ')
          ..write('endBalance: $endBalance, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, SaleTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _shiftIdMeta =
      const VerificationMeta('shiftId');
  @override
  late final GeneratedColumn<String> shiftId = GeneratedColumn<String>(
      'shift_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES shifts (id)'));
  static const VerificationMeta _openedByMeta =
      const VerificationMeta('openedBy');
  @override
  late final GeneratedColumn<String> openedBy = GeneratedColumn<String>(
      'opened_by', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _paymentTypeMeta =
      const VerificationMeta('paymentType');
  @override
  late final GeneratedColumn<int> paymentType = GeneratedColumn<int>(
      'payment_type', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isReturnedMeta =
      const VerificationMeta('isReturned');
  @override
  late final GeneratedColumn<bool> isReturned = GeneratedColumn<bool>(
      'is_returned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_returned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _returnedSaleIdMeta =
      const VerificationMeta('returnedSaleId');
  @override
  late final GeneratedColumn<String> returnedSaleId = GeneratedColumn<String>(
      'returned_sale_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _globalDiscountMeta =
      const VerificationMeta('globalDiscount');
  @override
  late final GeneratedColumn<double> globalDiscount = GeneratedColumn<double>(
      'global_discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        createdAt,
        shiftId,
        openedBy,
        totalAmount,
        paymentType,
        isReturned,
        returnedSaleId,
        globalDiscount
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<SaleTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('shift_id')) {
      context.handle(_shiftIdMeta,
          shiftId.isAcceptableOrUnknown(data['shift_id']!, _shiftIdMeta));
    } else if (isInserting) {
      context.missing(_shiftIdMeta);
    }
    if (data.containsKey('opened_by')) {
      context.handle(_openedByMeta,
          openedBy.isAcceptableOrUnknown(data['opened_by']!, _openedByMeta));
    } else if (isInserting) {
      context.missing(_openedByMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('payment_type')) {
      context.handle(
          _paymentTypeMeta,
          paymentType.isAcceptableOrUnknown(
              data['payment_type']!, _paymentTypeMeta));
    } else if (isInserting) {
      context.missing(_paymentTypeMeta);
    }
    if (data.containsKey('is_returned')) {
      context.handle(
          _isReturnedMeta,
          isReturned.isAcceptableOrUnknown(
              data['is_returned']!, _isReturnedMeta));
    }
    if (data.containsKey('returned_sale_id')) {
      context.handle(
          _returnedSaleIdMeta,
          returnedSaleId.isAcceptableOrUnknown(
              data['returned_sale_id']!, _returnedSaleIdMeta));
    }
    if (data.containsKey('global_discount')) {
      context.handle(
          _globalDiscountMeta,
          globalDiscount.isAcceptableOrUnknown(
              data['global_discount']!, _globalDiscountMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      shiftId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}shift_id'])!,
      openedBy: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}opened_by'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paymentType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}payment_type'])!,
      isReturned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_returned'])!,
      returnedSaleId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}returned_sale_id']),
      globalDiscount: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}global_discount'])!,
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class SaleTable extends DataClass implements Insertable<SaleTable> {
  final String id;
  final DateTime createdAt;
  final String shiftId;
  final String openedBy;
  final double totalAmount;
  final int paymentType;
  final bool isReturned;
  final String? returnedSaleId;
  final double globalDiscount;
  const SaleTable(
      {required this.id,
      required this.createdAt,
      required this.shiftId,
      required this.openedBy,
      required this.totalAmount,
      required this.paymentType,
      required this.isReturned,
      this.returnedSaleId,
      required this.globalDiscount});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['shift_id'] = Variable<String>(shiftId);
    map['opened_by'] = Variable<String>(openedBy);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_type'] = Variable<int>(paymentType);
    map['is_returned'] = Variable<bool>(isReturned);
    if (!nullToAbsent || returnedSaleId != null) {
      map['returned_sale_id'] = Variable<String>(returnedSaleId);
    }
    map['global_discount'] = Variable<double>(globalDiscount);
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      shiftId: Value(shiftId),
      openedBy: Value(openedBy),
      totalAmount: Value(totalAmount),
      paymentType: Value(paymentType),
      isReturned: Value(isReturned),
      returnedSaleId: returnedSaleId == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedSaleId),
      globalDiscount: Value(globalDiscount),
    );
  }

  factory SaleTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleTable(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      shiftId: serializer.fromJson<String>(json['shiftId']),
      openedBy: serializer.fromJson<String>(json['openedBy']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentType: serializer.fromJson<int>(json['paymentType']),
      isReturned: serializer.fromJson<bool>(json['isReturned']),
      returnedSaleId: serializer.fromJson<String?>(json['returnedSaleId']),
      globalDiscount: serializer.fromJson<double>(json['globalDiscount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'shiftId': serializer.toJson<String>(shiftId),
      'openedBy': serializer.toJson<String>(openedBy),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentType': serializer.toJson<int>(paymentType),
      'isReturned': serializer.toJson<bool>(isReturned),
      'returnedSaleId': serializer.toJson<String?>(returnedSaleId),
      'globalDiscount': serializer.toJson<double>(globalDiscount),
    };
  }

  SaleTable copyWith(
          {String? id,
          DateTime? createdAt,
          String? shiftId,
          String? openedBy,
          double? totalAmount,
          int? paymentType,
          bool? isReturned,
          Value<String?> returnedSaleId = const Value.absent(),
          double? globalDiscount}) =>
      SaleTable(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        shiftId: shiftId ?? this.shiftId,
        openedBy: openedBy ?? this.openedBy,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentType: paymentType ?? this.paymentType,
        isReturned: isReturned ?? this.isReturned,
        returnedSaleId:
            returnedSaleId.present ? returnedSaleId.value : this.returnedSaleId,
        globalDiscount: globalDiscount ?? this.globalDiscount,
      );
  SaleTable copyWithCompanion(SalesCompanion data) {
    return SaleTable(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      shiftId: data.shiftId.present ? data.shiftId.value : this.shiftId,
      openedBy: data.openedBy.present ? data.openedBy.value : this.openedBy,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paymentType:
          data.paymentType.present ? data.paymentType.value : this.paymentType,
      isReturned:
          data.isReturned.present ? data.isReturned.value : this.isReturned,
      returnedSaleId: data.returnedSaleId.present
          ? data.returnedSaleId.value
          : this.returnedSaleId,
      globalDiscount: data.globalDiscount.present
          ? data.globalDiscount.value
          : this.globalDiscount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleTable(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('shiftId: $shiftId, ')
          ..write('openedBy: $openedBy, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentType: $paymentType, ')
          ..write('isReturned: $isReturned, ')
          ..write('returnedSaleId: $returnedSaleId, ')
          ..write('globalDiscount: $globalDiscount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, createdAt, shiftId, openedBy, totalAmount,
      paymentType, isReturned, returnedSaleId, globalDiscount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleTable &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.shiftId == this.shiftId &&
          other.openedBy == this.openedBy &&
          other.totalAmount == this.totalAmount &&
          other.paymentType == this.paymentType &&
          other.isReturned == this.isReturned &&
          other.returnedSaleId == this.returnedSaleId &&
          other.globalDiscount == this.globalDiscount);
}

class SalesCompanion extends UpdateCompanion<SaleTable> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<String> shiftId;
  final Value<String> openedBy;
  final Value<double> totalAmount;
  final Value<int> paymentType;
  final Value<bool> isReturned;
  final Value<String?> returnedSaleId;
  final Value<double> globalDiscount;
  final Value<int> rowid;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.shiftId = const Value.absent(),
    this.openedBy = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentType = const Value.absent(),
    this.isReturned = const Value.absent(),
    this.returnedSaleId = const Value.absent(),
    this.globalDiscount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SalesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required String shiftId,
    required String openedBy,
    required double totalAmount,
    required int paymentType,
    this.isReturned = const Value.absent(),
    this.returnedSaleId = const Value.absent(),
    this.globalDiscount = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        shiftId = Value(shiftId),
        openedBy = Value(openedBy),
        totalAmount = Value(totalAmount),
        paymentType = Value(paymentType);
  static Insertable<SaleTable> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<String>? shiftId,
    Expression<String>? openedBy,
    Expression<double>? totalAmount,
    Expression<int>? paymentType,
    Expression<bool>? isReturned,
    Expression<String>? returnedSaleId,
    Expression<double>? globalDiscount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (shiftId != null) 'shift_id': shiftId,
      if (openedBy != null) 'opened_by': openedBy,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentType != null) 'payment_type': paymentType,
      if (isReturned != null) 'is_returned': isReturned,
      if (returnedSaleId != null) 'returned_sale_id': returnedSaleId,
      if (globalDiscount != null) 'global_discount': globalDiscount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SalesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? createdAt,
      Value<String>? shiftId,
      Value<String>? openedBy,
      Value<double>? totalAmount,
      Value<int>? paymentType,
      Value<bool>? isReturned,
      Value<String?>? returnedSaleId,
      Value<double>? globalDiscount,
      Value<int>? rowid}) {
    return SalesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      shiftId: shiftId ?? this.shiftId,
      openedBy: openedBy ?? this.openedBy,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentType: paymentType ?? this.paymentType,
      isReturned: isReturned ?? this.isReturned,
      returnedSaleId: returnedSaleId ?? this.returnedSaleId,
      globalDiscount: globalDiscount ?? this.globalDiscount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (shiftId.present) {
      map['shift_id'] = Variable<String>(shiftId.value);
    }
    if (openedBy.present) {
      map['opened_by'] = Variable<String>(openedBy.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentType.present) {
      map['payment_type'] = Variable<int>(paymentType.value);
    }
    if (isReturned.present) {
      map['is_returned'] = Variable<bool>(isReturned.value);
    }
    if (returnedSaleId.present) {
      map['returned_sale_id'] = Variable<String>(returnedSaleId.value);
    }
    if (globalDiscount.present) {
      map['global_discount'] = Variable<double>(globalDiscount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('shiftId: $shiftId, ')
          ..write('openedBy: $openedBy, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentType: $paymentType, ')
          ..write('isReturned: $isReturned, ')
          ..write('returnedSaleId: $returnedSaleId, ')
          ..write('globalDiscount: $globalDiscount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItemTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<String> saleId = GeneratedColumn<String>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES sales (id)'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<String> productId = GeneratedColumn<String>(
      'product_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _productNameMeta =
      const VerificationMeta('productName');
  @override
  late final GeneratedColumn<String> productName = GeneratedColumn<String>(
      'product_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
      'quantity', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _discountMeta =
      const VerificationMeta('discount');
  @override
  late final GeneratedColumn<double> discount = GeneratedColumn<double>(
      'discount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _costPriceMeta =
      const VerificationMeta('costPrice');
  @override
  late final GeneratedColumn<double> costPrice = GeneratedColumn<double>(
      'cost_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        saleId,
        productId,
        productName,
        price,
        quantity,
        discount,
        costPrice
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(Insertable<SaleItemTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('product_name')) {
      context.handle(
          _productNameMeta,
          productName.isAcceptableOrUnknown(
              data['product_name']!, _productNameMeta));
    } else if (isInserting) {
      context.missing(_productNameMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('discount')) {
      context.handle(_discountMeta,
          discount.isAcceptableOrUnknown(data['discount']!, _discountMeta));
    }
    if (data.containsKey('cost_price')) {
      context.handle(_costPriceMeta,
          costPrice.isAcceptableOrUnknown(data['cost_price']!, _costPriceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItemTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItemTable(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sale_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_id'])!,
      productName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}product_name'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}quantity'])!,
      discount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}discount'])!,
      costPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}cost_price'])!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItemTable extends DataClass implements Insertable<SaleItemTable> {
  final int id;
  final String saleId;
  final String productId;
  final String productName;
  final double price;
  final double quantity;
  final double discount;
  final double costPrice;
  const SaleItemTable(
      {required this.id,
      required this.saleId,
      required this.productId,
      required this.productName,
      required this.price,
      required this.quantity,
      required this.discount,
      required this.costPrice});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<String>(saleId);
    map['product_id'] = Variable<String>(productId);
    map['product_name'] = Variable<String>(productName);
    map['price'] = Variable<double>(price);
    map['quantity'] = Variable<double>(quantity);
    map['discount'] = Variable<double>(discount);
    map['cost_price'] = Variable<double>(costPrice);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      productName: Value(productName),
      price: Value(price),
      quantity: Value(quantity),
      discount: Value(discount),
      costPrice: Value(costPrice),
    );
  }

  factory SaleItemTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItemTable(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<String>(json['saleId']),
      productId: serializer.fromJson<String>(json['productId']),
      productName: serializer.fromJson<String>(json['productName']),
      price: serializer.fromJson<double>(json['price']),
      quantity: serializer.fromJson<double>(json['quantity']),
      discount: serializer.fromJson<double>(json['discount']),
      costPrice: serializer.fromJson<double>(json['costPrice']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<String>(saleId),
      'productId': serializer.toJson<String>(productId),
      'productName': serializer.toJson<String>(productName),
      'price': serializer.toJson<double>(price),
      'quantity': serializer.toJson<double>(quantity),
      'discount': serializer.toJson<double>(discount),
      'costPrice': serializer.toJson<double>(costPrice),
    };
  }

  SaleItemTable copyWith(
          {int? id,
          String? saleId,
          String? productId,
          String? productName,
          double? price,
          double? quantity,
          double? discount,
          double? costPrice}) =>
      SaleItemTable(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        productName: productName ?? this.productName,
        price: price ?? this.price,
        quantity: quantity ?? this.quantity,
        discount: discount ?? this.discount,
        costPrice: costPrice ?? this.costPrice,
      );
  SaleItemTable copyWithCompanion(SaleItemsCompanion data) {
    return SaleItemTable(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      productName:
          data.productName.present ? data.productName.value : this.productName,
      price: data.price.present ? data.price.value : this.price,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      discount: data.discount.present ? data.discount.value : this.discount,
      costPrice: data.costPrice.present ? data.costPrice.value : this.costPrice,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemTable(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('discount: $discount, ')
          ..write('costPrice: $costPrice')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, saleId, productId, productName, price, quantity, discount, costPrice);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItemTable &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.productName == this.productName &&
          other.price == this.price &&
          other.quantity == this.quantity &&
          other.discount == this.discount &&
          other.costPrice == this.costPrice);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItemTable> {
  final Value<int> id;
  final Value<String> saleId;
  final Value<String> productId;
  final Value<String> productName;
  final Value<double> price;
  final Value<double> quantity;
  final Value<double> discount;
  final Value<double> costPrice;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.productName = const Value.absent(),
    this.price = const Value.absent(),
    this.quantity = const Value.absent(),
    this.discount = const Value.absent(),
    this.costPrice = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    this.id = const Value.absent(),
    required String saleId,
    required String productId,
    required String productName,
    required double price,
    required double quantity,
    this.discount = const Value.absent(),
    this.costPrice = const Value.absent(),
  })  : saleId = Value(saleId),
        productId = Value(productId),
        productName = Value(productName),
        price = Value(price),
        quantity = Value(quantity);
  static Insertable<SaleItemTable> custom({
    Expression<int>? id,
    Expression<String>? saleId,
    Expression<String>? productId,
    Expression<String>? productName,
    Expression<double>? price,
    Expression<double>? quantity,
    Expression<double>? discount,
    Expression<double>? costPrice,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (productName != null) 'product_name': productName,
      if (price != null) 'price': price,
      if (quantity != null) 'quantity': quantity,
      if (discount != null) 'discount': discount,
      if (costPrice != null) 'cost_price': costPrice,
    });
  }

  SaleItemsCompanion copyWith(
      {Value<int>? id,
      Value<String>? saleId,
      Value<String>? productId,
      Value<String>? productName,
      Value<double>? price,
      Value<double>? quantity,
      Value<double>? discount,
      Value<double>? costPrice}) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      discount: discount ?? this.discount,
      costPrice: costPrice ?? this.costPrice,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<String>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<String>(productId.value);
    }
    if (productName.present) {
      map['product_name'] = Variable<String>(productName.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (discount.present) {
      map['discount'] = Variable<double>(discount.value);
    }
    if (costPrice.present) {
      map['cost_price'] = Variable<double>(costPrice.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('productName: $productName, ')
          ..write('price: $price, ')
          ..write('quantity: $quantity, ')
          ..write('discount: $discount, ')
          ..write('costPrice: $costPrice')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSettingTable> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingTable> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingTable map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingTable(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSettingTable extends DataClass implements Insertable<AppSettingTable> {
  final String key;
  final String value;
  const AppSettingTable({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingTable.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingTable(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingTable copyWith({String? key, String? value}) => AppSettingTable(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingTable copyWithCompanion(AppSettingsCompanion data) {
    return AppSettingTable(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingTable(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingTable &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSettingTable> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingTable> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $UnitsTable units = $UnitsTable(this);
  late final $ShopDetailsTable shopDetails = $ShopDetailsTable(this);
  late final $ShiftsTable shifts = $ShiftsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        products,
        units,
        shopDetails,
        shifts,
        sales,
        saleItems,
        appSettings
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  required String name,
  Value<String?> icon,
  Value<int?> colorCode,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String?> icon,
  Value<int?> colorCode,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryTable> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProductsTable, List<ProductTable>>
      _productsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.products,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.products.categoryId));

  $$ProductsTableProcessedTableManager get productsRefs {
    final manager = $$ProductsTableTableManager($_db, $_db.products)
        .filter((f) => f.categoryId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_productsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnFilters(column));

  Expression<bool> productsRefs(
      Expression<bool> Function($$ProductsTableFilterComposer f) f) {
    final $$ProductsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableFilterComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorCode => $composableBuilder(
      column: $table.colorCode, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<int> get colorCode =>
      $composableBuilder(column: $table.colorCode, builder: (column) => column);

  Expression<T> productsRefs<T extends Object>(
      Expression<T> Function($$ProductsTableAnnotationComposer a) f) {
    final $$ProductsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.products,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ProductsTableAnnotationComposer(
              $db: $db,
              $table: $db.products,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryTable,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryTable, $$CategoriesTableReferences),
    CategoryTable,
    PrefetchHooks Function({bool productsRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<int?> colorCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            name: name,
            icon: icon,
            colorCode: colorCode,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<String?> icon = const Value.absent(),
            Value<int?> colorCode = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            name: name,
            icon: icon,
            colorCode: colorCode,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({productsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (productsRefs) db.products],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (productsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._productsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .productsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryTable,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryTable, $$CategoriesTableReferences),
    CategoryTable,
    PrefetchHooks Function({bool productsRefs})>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  required String id,
  required String name,
  required String barcode,
  required double price,
  Value<double> costPrice,
  Value<double> stock,
  Value<String> unit,
  Value<String?> categoryId,
  Value<int> rowid,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> barcode,
  Value<double> price,
  Value<double> costPrice,
  Value<double> stock,
  Value<String> unit,
  Value<String?> categoryId,
  Value<int> rowid,
});

final class $$ProductsTableReferences
    extends BaseReferences<_$AppDatabase, $ProductsTable, ProductTable> {
  $$ProductsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.products.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    if ($_item.categoryId == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id($_item.categoryId!));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get barcode => $composableBuilder(
      column: $table.barcode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get stock => $composableBuilder(
      column: $table.stock, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get unit => $composableBuilder(
      column: $table.unit, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get barcode =>
      $composableBuilder(column: $table.barcode, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  GeneratedColumn<double> get stock =>
      $composableBuilder(column: $table.stock, builder: (column) => column);

  GeneratedColumn<String> get unit =>
      $composableBuilder(column: $table.unit, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductTable,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductTable, $$ProductsTableReferences),
    ProductTable,
    PrefetchHooks Function({bool categoryId})> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> barcode = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
            Value<double> stock = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            barcode: barcode,
            price: price,
            costPrice: costPrice,
            stock: stock,
            unit: unit,
            categoryId: categoryId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String barcode,
            required double price,
            Value<double> costPrice = const Value.absent(),
            Value<double> stock = const Value.absent(),
            Value<String> unit = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            barcode: barcode,
            price: price,
            costPrice: costPrice,
            stock: stock,
            unit: unit,
            categoryId: categoryId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ProductsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ProductsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ProductsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    ProductTable,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (ProductTable, $$ProductsTableReferences),
    ProductTable,
    PrefetchHooks Function({bool categoryId})>;
typedef $$UnitsTableCreateCompanionBuilder = UnitsCompanion Function({
  required String id,
  required String name,
  required String shortName,
  Value<int> rowid,
});
typedef $$UnitsTableUpdateCompanionBuilder = UnitsCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> shortName,
  Value<int> rowid,
});

class $$UnitsTableFilterComposer extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnFilters(column));
}

class $$UnitsTableOrderingComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get shortName => $composableBuilder(
      column: $table.shortName, builder: (column) => ColumnOrderings(column));
}

class $$UnitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UnitsTable> {
  $$UnitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);
}

class $$UnitsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UnitsTable,
    UnitTable,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (UnitTable, BaseReferences<_$AppDatabase, $UnitsTable, UnitTable>),
    UnitTable,
    PrefetchHooks Function()> {
  $$UnitsTableTableManager(_$AppDatabase db, $UnitsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UnitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UnitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UnitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> shortName = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion(
            id: id,
            name: name,
            shortName: shortName,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String shortName,
            Value<int> rowid = const Value.absent(),
          }) =>
              UnitsCompanion.insert(
            id: id,
            name: name,
            shortName: shortName,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UnitsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UnitsTable,
    UnitTable,
    $$UnitsTableFilterComposer,
    $$UnitsTableOrderingComposer,
    $$UnitsTableAnnotationComposer,
    $$UnitsTableCreateCompanionBuilder,
    $$UnitsTableUpdateCompanionBuilder,
    (UnitTable, BaseReferences<_$AppDatabase, $UnitsTable, UnitTable>),
    UnitTable,
    PrefetchHooks Function()>;
typedef $$ShopDetailsTableCreateCompanionBuilder = ShopDetailsCompanion
    Function({
  required String name,
  required String addressLine1,
  required String addressLine2,
  required String phoneNumber,
  required String upiId,
  required String footerText,
  Value<int> rowid,
});
typedef $$ShopDetailsTableUpdateCompanionBuilder = ShopDetailsCompanion
    Function({
  Value<String> name,
  Value<String> addressLine1,
  Value<String> addressLine2,
  Value<String> phoneNumber,
  Value<String> upiId,
  Value<String> footerText,
  Value<int> rowid,
});

class $$ShopDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopDetailsTable> {
  $$ShopDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressLine1 => $composableBuilder(
      column: $table.addressLine1, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get addressLine2 => $composableBuilder(
      column: $table.addressLine2, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get footerText => $composableBuilder(
      column: $table.footerText, builder: (column) => ColumnFilters(column));
}

class $$ShopDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopDetailsTable> {
  $$ShopDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressLine1 => $composableBuilder(
      column: $table.addressLine1,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get addressLine2 => $composableBuilder(
      column: $table.addressLine2,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get upiId => $composableBuilder(
      column: $table.upiId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get footerText => $composableBuilder(
      column: $table.footerText, builder: (column) => ColumnOrderings(column));
}

class $$ShopDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopDetailsTable> {
  $$ShopDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get addressLine1 => $composableBuilder(
      column: $table.addressLine1, builder: (column) => column);

  GeneratedColumn<String> get addressLine2 => $composableBuilder(
      column: $table.addressLine2, builder: (column) => column);

  GeneratedColumn<String> get phoneNumber => $composableBuilder(
      column: $table.phoneNumber, builder: (column) => column);

  GeneratedColumn<String> get upiId =>
      $composableBuilder(column: $table.upiId, builder: (column) => column);

  GeneratedColumn<String> get footerText => $composableBuilder(
      column: $table.footerText, builder: (column) => column);
}

class $$ShopDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShopDetailsTable,
    ShopTable,
    $$ShopDetailsTableFilterComposer,
    $$ShopDetailsTableOrderingComposer,
    $$ShopDetailsTableAnnotationComposer,
    $$ShopDetailsTableCreateCompanionBuilder,
    $$ShopDetailsTableUpdateCompanionBuilder,
    (ShopTable, BaseReferences<_$AppDatabase, $ShopDetailsTable, ShopTable>),
    ShopTable,
    PrefetchHooks Function()> {
  $$ShopDetailsTableTableManager(_$AppDatabase db, $ShopDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> name = const Value.absent(),
            Value<String> addressLine1 = const Value.absent(),
            Value<String> addressLine2 = const Value.absent(),
            Value<String> phoneNumber = const Value.absent(),
            Value<String> upiId = const Value.absent(),
            Value<String> footerText = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShopDetailsCompanion(
            name: name,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            phoneNumber: phoneNumber,
            upiId: upiId,
            footerText: footerText,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String name,
            required String addressLine1,
            required String addressLine2,
            required String phoneNumber,
            required String upiId,
            required String footerText,
            Value<int> rowid = const Value.absent(),
          }) =>
              ShopDetailsCompanion.insert(
            name: name,
            addressLine1: addressLine1,
            addressLine2: addressLine2,
            phoneNumber: phoneNumber,
            upiId: upiId,
            footerText: footerText,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShopDetailsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShopDetailsTable,
    ShopTable,
    $$ShopDetailsTableFilterComposer,
    $$ShopDetailsTableOrderingComposer,
    $$ShopDetailsTableAnnotationComposer,
    $$ShopDetailsTableCreateCompanionBuilder,
    $$ShopDetailsTableUpdateCompanionBuilder,
    (ShopTable, BaseReferences<_$AppDatabase, $ShopDetailsTable, ShopTable>),
    ShopTable,
    PrefetchHooks Function()>;
typedef $$ShiftsTableCreateCompanionBuilder = ShiftsCompanion Function({
  required String id,
  required DateTime openedAt,
  Value<DateTime?> closedAt,
  required String openedBy,
  required double startBalance,
  Value<double?> endBalance,
  required int status,
  Value<int> rowid,
});
typedef $$ShiftsTableUpdateCompanionBuilder = ShiftsCompanion Function({
  Value<String> id,
  Value<DateTime> openedAt,
  Value<DateTime?> closedAt,
  Value<String> openedBy,
  Value<double> startBalance,
  Value<double?> endBalance,
  Value<int> status,
  Value<int> rowid,
});

final class $$ShiftsTableReferences
    extends BaseReferences<_$AppDatabase, $ShiftsTable, ShiftTable> {
  $$ShiftsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SalesTable, List<SaleTable>> _salesRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sales,
          aliasName: $_aliasNameGenerator(db.shifts.id, db.sales.shiftId));

  $$SalesTableProcessedTableManager get salesRefs {
    final manager = $$SalesTableTableManager($_db, $_db.sales)
        .filter((f) => f.shiftId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_salesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$ShiftsTableFilterComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openedBy => $composableBuilder(
      column: $table.openedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get startBalance => $composableBuilder(
      column: $table.startBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get endBalance => $composableBuilder(
      column: $table.endBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  Expression<bool> salesRefs(
      Expression<bool> Function($$SalesTableFilterComposer f) f) {
    final $$SalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableFilterComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ShiftsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
      column: $table.openedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openedBy => $composableBuilder(
      column: $table.openedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get startBalance => $composableBuilder(
      column: $table.startBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get endBalance => $composableBuilder(
      column: $table.endBalance, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));
}

class $$ShiftsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShiftsTable> {
  $$ShiftsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get openedBy =>
      $composableBuilder(column: $table.openedBy, builder: (column) => column);

  GeneratedColumn<double> get startBalance => $composableBuilder(
      column: $table.startBalance, builder: (column) => column);

  GeneratedColumn<double> get endBalance => $composableBuilder(
      column: $table.endBalance, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> salesRefs<T extends Object>(
      Expression<T> Function($$SalesTableAnnotationComposer a) f) {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.shiftId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableAnnotationComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$ShiftsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShiftsTable,
    ShiftTable,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (ShiftTable, $$ShiftsTableReferences),
    ShiftTable,
    PrefetchHooks Function({bool salesRefs})> {
  $$ShiftsTableTableManager(_$AppDatabase db, $ShiftsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShiftsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShiftsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShiftsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> openedAt = const Value.absent(),
            Value<DateTime?> closedAt = const Value.absent(),
            Value<String> openedBy = const Value.absent(),
            Value<double> startBalance = const Value.absent(),
            Value<double?> endBalance = const Value.absent(),
            Value<int> status = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion(
            id: id,
            openedAt: openedAt,
            closedAt: closedAt,
            openedBy: openedBy,
            startBalance: startBalance,
            endBalance: endBalance,
            status: status,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime openedAt,
            Value<DateTime?> closedAt = const Value.absent(),
            required String openedBy,
            required double startBalance,
            Value<double?> endBalance = const Value.absent(),
            required int status,
            Value<int> rowid = const Value.absent(),
          }) =>
              ShiftsCompanion.insert(
            id: id,
            openedAt: openedAt,
            closedAt: closedAt,
            openedBy: openedBy,
            startBalance: startBalance,
            endBalance: endBalance,
            status: status,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ShiftsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({salesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (salesRefs) db.sales],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (salesRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$ShiftsTableReferences._salesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$ShiftsTableReferences(db, table, p0).salesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.shiftId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$ShiftsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShiftsTable,
    ShiftTable,
    $$ShiftsTableFilterComposer,
    $$ShiftsTableOrderingComposer,
    $$ShiftsTableAnnotationComposer,
    $$ShiftsTableCreateCompanionBuilder,
    $$ShiftsTableUpdateCompanionBuilder,
    (ShiftTable, $$ShiftsTableReferences),
    ShiftTable,
    PrefetchHooks Function({bool salesRefs})>;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  required String id,
  required DateTime createdAt,
  required String shiftId,
  required String openedBy,
  required double totalAmount,
  required int paymentType,
  Value<bool> isReturned,
  Value<String?> returnedSaleId,
  Value<double> globalDiscount,
  Value<int> rowid,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<String> shiftId,
  Value<String> openedBy,
  Value<double> totalAmount,
  Value<int> paymentType,
  Value<bool> isReturned,
  Value<String?> returnedSaleId,
  Value<double> globalDiscount,
  Value<int> rowid,
});

final class $$SalesTableReferences
    extends BaseReferences<_$AppDatabase, $SalesTable, SaleTable> {
  $$SalesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ShiftsTable _shiftIdTable(_$AppDatabase db) => db.shifts
      .createAlias($_aliasNameGenerator(db.sales.shiftId, db.shifts.id));

  $$ShiftsTableProcessedTableManager? get shiftId {
    if ($_item.shiftId == null) return null;
    final manager = $$ShiftsTableTableManager($_db, $_db.shifts)
        .filter((f) => f.id($_item.shiftId!));
    final item = $_typedResult.readTableOrNull(_shiftIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static MultiTypedResultKey<$SaleItemsTable, List<SaleItemTable>>
      _saleItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.saleItems,
          aliasName: $_aliasNameGenerator(db.sales.id, db.saleItems.saleId));

  $$SaleItemsTableProcessedTableManager get saleItemsRefs {
    final manager = $$SaleItemsTableTableManager($_db, $_db.saleItems)
        .filter((f) => f.saleId.id($_item.id));

    final cache = $_typedResult.readTableOrNull(_saleItemsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get openedBy => $composableBuilder(
      column: $table.openedBy, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isReturned => $composableBuilder(
      column: $table.isReturned, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get returnedSaleId => $composableBuilder(
      column: $table.returnedSaleId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get globalDiscount => $composableBuilder(
      column: $table.globalDiscount,
      builder: (column) => ColumnFilters(column));

  $$ShiftsTableFilterComposer get shiftId {
    final $$ShiftsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableFilterComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<bool> saleItemsRefs(
      Expression<bool> Function($$SaleItemsTableFilterComposer f) f) {
    final $$SaleItemsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.saleItems,
        getReferencedColumn: (t) => t.saleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SaleItemsTableFilterComposer(
              $db: $db,
              $table: $db.saleItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get openedBy => $composableBuilder(
      column: $table.openedBy, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isReturned => $composableBuilder(
      column: $table.isReturned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get returnedSaleId => $composableBuilder(
      column: $table.returnedSaleId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get globalDiscount => $composableBuilder(
      column: $table.globalDiscount,
      builder: (column) => ColumnOrderings(column));

  $$ShiftsTableOrderingComposer get shiftId {
    final $$ShiftsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableOrderingComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get openedBy =>
      $composableBuilder(column: $table.openedBy, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<int> get paymentType => $composableBuilder(
      column: $table.paymentType, builder: (column) => column);

  GeneratedColumn<bool> get isReturned => $composableBuilder(
      column: $table.isReturned, builder: (column) => column);

  GeneratedColumn<String> get returnedSaleId => $composableBuilder(
      column: $table.returnedSaleId, builder: (column) => column);

  GeneratedColumn<double> get globalDiscount => $composableBuilder(
      column: $table.globalDiscount, builder: (column) => column);

  $$ShiftsTableAnnotationComposer get shiftId {
    final $$ShiftsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.shiftId,
        referencedTable: $db.shifts,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ShiftsTableAnnotationComposer(
              $db: $db,
              $table: $db.shifts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  Expression<T> saleItemsRefs<T extends Object>(
      Expression<T> Function($$SaleItemsTableAnnotationComposer a) f) {
    final $$SaleItemsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.saleItems,
        getReferencedColumn: (t) => t.saleId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SaleItemsTableAnnotationComposer(
              $db: $db,
              $table: $db.saleItems,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    SaleTable,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (SaleTable, $$SalesTableReferences),
    SaleTable,
    PrefetchHooks Function({bool shiftId, bool saleItemsRefs})> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String> shiftId = const Value.absent(),
            Value<String> openedBy = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<int> paymentType = const Value.absent(),
            Value<bool> isReturned = const Value.absent(),
            Value<String?> returnedSaleId = const Value.absent(),
            Value<double> globalDiscount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            createdAt: createdAt,
            shiftId: shiftId,
            openedBy: openedBy,
            totalAmount: totalAmount,
            paymentType: paymentType,
            isReturned: isReturned,
            returnedSaleId: returnedSaleId,
            globalDiscount: globalDiscount,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime createdAt,
            required String shiftId,
            required String openedBy,
            required double totalAmount,
            required int paymentType,
            Value<bool> isReturned = const Value.absent(),
            Value<String?> returnedSaleId = const Value.absent(),
            Value<double> globalDiscount = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            createdAt: createdAt,
            shiftId: shiftId,
            openedBy: openedBy,
            totalAmount: totalAmount,
            paymentType: paymentType,
            isReturned: isReturned,
            returnedSaleId: returnedSaleId,
            globalDiscount: globalDiscount,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SalesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({shiftId = false, saleItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (saleItemsRefs) db.saleItems],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (shiftId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.shiftId,
                    referencedTable: $$SalesTableReferences._shiftIdTable(db),
                    referencedColumn:
                        $$SalesTableReferences._shiftIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (saleItemsRefs)
                    await $_getPrefetchedData(
                        currentTable: table,
                        referencedTable:
                            $$SalesTableReferences._saleItemsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SalesTableReferences(db, table, p0).saleItemsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.saleId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    SaleTable,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (SaleTable, $$SalesTableReferences),
    SaleTable,
    PrefetchHooks Function({bool shiftId, bool saleItemsRefs})>;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  required String saleId,
  required String productId,
  required String productName,
  required double price,
  required double quantity,
  Value<double> discount,
  Value<double> costPrice,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  Value<String> saleId,
  Value<String> productId,
  Value<String> productName,
  Value<double> price,
  Value<double> quantity,
  Value<double> discount,
  Value<double> costPrice,
});

final class $$SaleItemsTableReferences
    extends BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItemTable> {
  $$SaleItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SalesTable _saleIdTable(_$AppDatabase db) => db.sales
      .createAlias($_aliasNameGenerator(db.saleItems.saleId, db.sales.id));

  $$SalesTableProcessedTableManager? get saleId {
    if ($_item.saleId == null) return null;
    final manager = $$SalesTableTableManager($_db, $_db.sales)
        .filter((f) => f.id($_item.saleId!));
    final item = $_typedResult.readTableOrNull(_saleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnFilters(column));

  $$SalesTableFilterComposer get saleId {
    final $$SalesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableFilterComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get discount => $composableBuilder(
      column: $table.discount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get costPrice => $composableBuilder(
      column: $table.costPrice, builder: (column) => ColumnOrderings(column));

  $$SalesTableOrderingComposer get saleId {
    final $$SalesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableOrderingComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<String> get productName => $composableBuilder(
      column: $table.productName, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get discount =>
      $composableBuilder(column: $table.discount, builder: (column) => column);

  GeneratedColumn<double> get costPrice =>
      $composableBuilder(column: $table.costPrice, builder: (column) => column);

  $$SalesTableAnnotationComposer get saleId {
    final $$SalesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.saleId,
        referencedTable: $db.sales,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SalesTableAnnotationComposer(
              $db: $db,
              $table: $db.sales,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SaleItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItemTable,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItemTable, $$SaleItemsTableReferences),
    SaleItemTable,
    PrefetchHooks Function({bool saleId})> {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> saleId = const Value.absent(),
            Value<String> productId = const Value.absent(),
            Value<String> productName = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> quantity = const Value.absent(),
            Value<double> discount = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
          }) =>
              SaleItemsCompanion(
            id: id,
            saleId: saleId,
            productId: productId,
            productName: productName,
            price: price,
            quantity: quantity,
            discount: discount,
            costPrice: costPrice,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String saleId,
            required String productId,
            required String productName,
            required double price,
            required double quantity,
            Value<double> discount = const Value.absent(),
            Value<double> costPrice = const Value.absent(),
          }) =>
              SaleItemsCompanion.insert(
            id: id,
            saleId: saleId,
            productId: productId,
            productName: productName,
            price: price,
            quantity: quantity,
            discount: discount,
            costPrice: costPrice,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SaleItemsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({saleId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (saleId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.saleId,
                    referencedTable:
                        $$SaleItemsTableReferences._saleIdTable(db),
                    referencedColumn:
                        $$SaleItemsTableReferences._saleIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SaleItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItemTable,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItemTable, $$SaleItemsTableReferences),
    SaleItemTable,
    PrefetchHooks Function({bool saleId})>;
typedef $$AppSettingsTableCreateCompanionBuilder = AppSettingsCompanion
    Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingsTableUpdateCompanionBuilder = AppSettingsCompanion
    Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingTable,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingTable,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingTable>
    ),
    AppSettingTable,
    PrefetchHooks Function()> {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingsCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingsTable,
    AppSettingTable,
    $$AppSettingsTableFilterComposer,
    $$AppSettingsTableOrderingComposer,
    $$AppSettingsTableAnnotationComposer,
    $$AppSettingsTableCreateCompanionBuilder,
    $$AppSettingsTableUpdateCompanionBuilder,
    (
      AppSettingTable,
      BaseReferences<_$AppDatabase, $AppSettingsTable, AppSettingTable>
    ),
    AppSettingTable,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db, _db.units);
  $$ShopDetailsTableTableManager get shopDetails =>
      $$ShopDetailsTableTableManager(_db, _db.shopDetails);
  $$ShiftsTableTableManager get shifts =>
      $$ShiftsTableTableManager(_db, _db.shifts);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
