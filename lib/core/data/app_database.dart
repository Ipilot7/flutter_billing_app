import 'dart:io';
import 'package:drift/drift.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:drift/native.dart';

part 'app_database.g.dart';

// Tables definitions

@DataClassName('CategoryTable')
class Categories extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get icon => text().nullable()();
  IntColumn get colorCode => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ProductTable')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get barcode => text()();
  RealColumn get price => real()();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();
  RealColumn get stock => real().withDefault(const Constant(0.0))();
  TextColumn get unit => text().withDefault(const Constant('шт'))();
  TextColumn get categoryId => text().nullable().references(Categories, #id)();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('UnitTable')
class Units extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get shortName => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ShopTable')
class ShopDetails extends Table {
  TextColumn get name => text()();
  TextColumn get addressLine1 => text()();
  TextColumn get addressLine2 => text()();
  TextColumn get phoneNumber => text()();
  TextColumn get upiId => text()();
  TextColumn get footerText => text()();
}

@DataClassName('ShiftTable')
class Shifts extends Table {
  TextColumn get id => text()();
  DateTimeColumn get openedAt => dateTime()();
  DateTimeColumn get closedAt => dateTime().nullable()();
  TextColumn get openedBy => text()();
  RealColumn get startBalance => real()();
  RealColumn get endBalance => real().nullable()();
  IntColumn get status => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleTable')
class Sales extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get shiftId => text().references(Shifts, #id)();
  TextColumn get openedBy => text()();
  RealColumn get totalAmount => real()();
  IntColumn get paymentType => integer()();
  BoolColumn get isReturned => boolean().withDefault(const Constant(false))();
  TextColumn get returnedSaleId => text().nullable()();
  RealColumn get globalDiscount => real().withDefault(const Constant(0.0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleItemTable')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text()();
  TextColumn get productName => text()();
  RealColumn get price => real()();
  RealColumn get quantity => real()();
  RealColumn get discount => real().withDefault(const Constant(0.0))();
  RealColumn get costPrice => real().withDefault(const Constant(0.0))();
}

@DataClassName('AppSettingTable')
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [
  Categories,
  Products,
  Units,
  ShopDetails,
  Shifts,
  Sales,
  SaleItems,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();

          // Seed default units
          final defaultUnits = [
            {'id': '1', 'name': 'Штука', 'shortName': 'шт'},
            {'id': '2', 'name': 'Килограмм', 'shortName': 'кг'},
            {'id': '3', 'name': 'Литр', 'shortName': 'л'},
            {'id': '4', 'name': 'Метр', 'shortName': 'м'},
            {'id': '5', 'name': 'Грамм', 'shortName': 'г'},
            {'id': '6', 'name': 'Упаковка', 'shortName': 'уп'},
          ];

          for (var unit in defaultUnits) {
            await into(units).insert(UnitTable(
              id: unit['id']!,
              name: unit['name']!,
              shortName: unit['shortName']!,
            ));
          }
        },
      );

  // You can add data access methods (DAOs) here later
  
  // Example: Products
  Future<List<ProductTable>> getAllProducts() => select(products).get();
  Future<int> addProduct(ProductTable product) => into(products).insert(product);
  Future updateProduct(ProductTable product) => update(products).replace(product);
  Future deleteProduct(String id) => (delete(products)..where((t) => t.id.equals(id))).go();

  // Categories
  Future<List<CategoryTable>> getAllCategories() => select(categories).get();
  Future<int> addCategory(CategoryTable category) => into(categories).insert(category);

  // Settings
  Future<String?> getSetting(String key) async {
    final row = await (select(appSettings)..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> saveSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(AppSettingTable(key: key, value: value));
  }

  Future<void> deleteSetting(String key) async {
    await (delete(appSettings)..where((t) => t.key.equals(key))).go();
  }
}

QueryExecutor _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
