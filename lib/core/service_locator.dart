import 'package:get_it/get_it.dart';
import 'package:billing_app/features/product/data/repositories/product_repository_impl.dart';
import 'package:billing_app/features/product/domain/repositories/product_repository.dart';
import 'package:billing_app/features/product/domain/usecases/product_usecases.dart';
import 'package:billing_app/features/product/presentation/bloc/product_bloc.dart';
import 'package:billing_app/features/product/presentation/bloc/category_bloc.dart';
import 'package:billing_app/features/product/data/repositories/category_repository_impl.dart';
import 'package:billing_app/features/product/domain/repositories/category_repository.dart';
import 'package:billing_app/features/product/domain/usecases/category_usecases.dart';
import 'package:billing_app/features/shop/data/repositories/shop_repository_impl.dart';
import 'package:billing_app/features/shop/domain/repositories/shop_repository.dart';
import 'package:billing_app/features/shop/domain/usecases/shop_usecases.dart';
import 'package:billing_app/features/shop/presentation/bloc/shop_bloc.dart';
import 'package:billing_app/features/settings/data/repositories/printer_repository_impl.dart';
import 'package:billing_app/features/settings/domain/repositories/printer_repository.dart';
import 'package:billing_app/features/settings/presentation/bloc/printer_bloc.dart';
import 'package:billing_app/features/settings/presentation/bloc/locale_cubit.dart';
import 'package:billing_app/features/shift/data/repositories/shift_repository_impl.dart';
import 'package:billing_app/features/shift/domain/repositories/shift_repository.dart';
import 'package:billing_app/features/shift/domain/usecases/shift_usecases.dart';
import 'package:billing_app/features/shift/presentation/bloc/shift_bloc.dart';
import 'package:billing_app/features/sales/data/repositories/sales_repository_impl.dart';
import 'package:billing_app/features/sales/domain/usecases/sales_usecases.dart';
import 'package:billing_app/features/sales/presentation/bloc/sales_bloc.dart';
import 'package:billing_app/features/sales/presentation/bloc/analytics_bloc.dart';
import 'package:billing_app/features/measurement_unit/data/repositories/unit_repository_impl.dart';
import 'package:billing_app/features/measurement_unit/domain/usecases/unit_usecases.dart';
import 'package:billing_app/features/measurement_unit/presentation/bloc/unit_bloc.dart';
import 'package:billing_app/core/data/app_database.dart';
import 'package:billing_app/features/billing/presentation/bloc/billing_bloc.dart';
import 'package:billing_app/core/util/backup_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Database
  sl.registerLazySingleton<AppDatabase>(() => AppDatabase());
  sl.registerLazySingleton<BackupService>(() => BackupService(sl()));

  // Features - Product
  // Bloc
  sl.registerFactory(
    () => ProductBloc(
      getProductsUseCase: sl(),
      addProductUseCase: sl(),
      updateProductUseCase: sl(),
      deleteProductUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => CategoryBloc(
      getCategoriesUseCase: sl(),
      addCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => ShopBloc(
      getShopUseCase: sl(),
      updateShopUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PrinterBloc(
      repository: sl(),
    ),
  );

  sl.registerFactory(
    () => BillingBloc(
      getProductByBarcodeUseCase: sl(),
      createSaleUseCase: sl(),
      printerRepository: sl(),
    ),
  );

  // Features - Shift
  sl.registerFactory(
    () => ShiftBloc(
      openShiftUseCase: sl(),
      closeShiftUseCase: sl(),
      getCurrentShiftUseCase: sl(),
    ),
  );

  // Features - Sales
  sl.registerFactory(
    () => SalesBloc(
      getSalesHistoryUseCase: sl(),
      returnSaleUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AnalyticsBloc(
      getSalesHistoryUseCase: sl(),
    ),
  );

  // Features - Unit
  sl.registerFactory(
    () => UnitBloc(
      addUnitUseCase: sl(),
      updateUnitUseCase: sl(),
      deleteUnitUseCase: sl(),
      getAllUnitsUseCase: sl(),
    ),
  );

  // Features - Settings
  sl.registerFactory(() => LocaleCubit(sl()));

  // Use cases
  sl.registerLazySingleton(() => GetProductsUseCase(sl()));
  sl.registerLazySingleton(() => AddProductUseCase(sl()));
  sl.registerLazySingleton(() => UpdateProductUseCase(sl()));
  sl.registerLazySingleton(() => DeleteProductUseCase(sl()));
  sl.registerLazySingleton(() => GetProductByBarcodeUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(sl()),
  );

  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerLazySingleton(() => AddCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));

  // Features - Shop
  // Use cases
  sl.registerLazySingleton(() => GetShopUseCase(sl()));
  sl.registerLazySingleton(() => UpdateShopUseCase(sl()));

  // Repository
  sl.registerLazySingleton<ShopRepository>(
    () => ShopRepositoryImpl(sl()),
  );

  // Features - Settings / Printer
  sl.registerLazySingleton<PrinterRepository>(
    () => PrinterRepositoryImpl(sl()),
  );

  // Features - Shift
  sl.registerLazySingleton<ShiftRepository>(
    () => ShiftRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => OpenShiftUseCase(sl()));
  sl.registerLazySingleton(() => CloseShiftUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentShiftUseCase(sl()));

  // Features - Sales
  sl.registerLazySingleton<SalesRepository>(() => SalesRepositoryImpl(sl()));
  sl.registerLazySingleton(() => CreateSaleUseCase(sl()));
  sl.registerLazySingleton(() => GetSalesHistoryUseCase(sl()));
  sl.registerLazySingleton(() => ReturnSaleUseCase(sl()));

  // Features - Unit
  sl.registerLazySingleton<UnitRepository>(() => UnitRepositoryImpl(sl()));
  sl.registerLazySingleton(() => AddUnitUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUnitUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUnitUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUnitsUseCase(sl()));
}
