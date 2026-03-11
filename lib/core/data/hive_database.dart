import 'package:hive_flutter/hive_flutter.dart';
import '../../features/product/data/models/product_model.dart';
import '../../features/shop/data/models/shop_model.dart';
import '../../features/shift/data/models/shift_model.dart';
import '../../features/sales/data/models/sale_model.dart';
import '../../features/measurement_unit/data/models/unit_model.dart';
import '../../features/product/data/models/category_model.dart';

class HiveDatabase {
  static const String productBoxName = 'products';
  static const String shopBoxName = 'shop';
  static const String settingsBoxName = 'settings';
  static const String shiftsBoxName = 'shifts';
  static const String salesBoxName = 'sales';
  static const String unitsBoxName = 'units';
  static const String categoriesBoxName = 'categories';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(ProductModelAdapter());
    Hive.registerAdapter(ShopModelAdapter());
    Hive.registerAdapter(ShiftModelAdapter());
    Hive.registerAdapter(SaleModelAdapter());
    Hive.registerAdapter(SaleItemModelAdapter());
    Hive.registerAdapter(UnitModelAdapter());
    Hive.registerAdapter(CategoryModelAdapter());

    // Open Boxes
    await Hive.openBox<ProductModel>(productBoxName);
    await Hive.openBox<ShopModel>(shopBoxName);
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<ShiftModel>(shiftsBoxName);
    await Hive.openBox<SaleModel>(salesBoxName);
    await Hive.openBox<UnitModel>(unitsBoxName);
    await Hive.openBox<CategoryModel>(categoriesBoxName);
  }

  static Box<ProductModel> get productBox =>
      Hive.box<ProductModel>(productBoxName);
  static Box<ShopModel> get shopBox => Hive.box<ShopModel>(shopBoxName);
  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<ShiftModel> get shiftsBox => Hive.box<ShiftModel>(shiftsBoxName);
  static Box<SaleModel> get salesBox => Hive.box<SaleModel>(salesBoxName);
  static Box<UnitModel> get unitsBox => Hive.box<UnitModel>(unitsBoxName);
  static Box<CategoryModel> get categoriesBox =>
      Hive.box<CategoryModel>(categoriesBoxName);
}
