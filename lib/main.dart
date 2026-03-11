import 'package:billing_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'config/routes/app_routes.dart';
import 'core/data/hive_database.dart';
import 'core/service_locator.dart' as di;
import 'core/theme/app_theme.dart';
import 'features/billing/presentation/bloc/billing_bloc.dart';
import 'features/product/presentation/bloc/product_bloc.dart';
import 'features/shop/presentation/bloc/shop_bloc.dart';
import 'features/settings/presentation/bloc/printer_bloc.dart';
import 'features/settings/presentation/bloc/locale_cubit.dart';
import 'features/shift/presentation/bloc/shift_bloc.dart';
import 'features/sales/presentation/bloc/sales_bloc.dart';
import 'features/sales/presentation/bloc/analytics_bloc.dart';
import 'features/measurement_unit/presentation/bloc/unit_bloc.dart';
import 'features/product/presentation/bloc/category_bloc.dart';
import 'features/product/presentation/bloc/category_event.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveDatabase.init();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(create: (context) => di.sl<ProductBloc>()),
        BlocProvider<ShopBloc>(create: (context) => di.sl<ShopBloc>()),
        BlocProvider<BillingBloc>(create: (context) => di.sl<BillingBloc>()),
        BlocProvider<PrinterBloc>(create: (context) => di.sl<PrinterBloc>()),
        BlocProvider<LocaleCubit>(create: (context) => di.sl<LocaleCubit>()),
        BlocProvider<ShiftBloc>(create: (context) => di.sl<ShiftBloc>()),
        BlocProvider<SalesBloc>(create: (context) => di.sl<SalesBloc>()),
        BlocProvider<AnalyticsBloc>(
            create: (context) => di.sl<AnalyticsBloc>()),
        BlocProvider<UnitBloc>(create: (context) => di.sl<UnitBloc>()),
        BlocProvider<CategoryBloc>(
          create: (context) => di.sl<CategoryBloc>()..add(GetCategoriesEvent()),
        ),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return MaterialApp.router(
            title: 'Billing App',
            theme: AppTheme.lightTheme,
            routerConfig: router,
            debugShowCheckedModeBanner: false,
            locale: locale,
            supportedLocales: const [
              Locale('ru'),
              Locale('uz'),
              Locale('en'),
            ],
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              AppLocalizations.delegate,
            ],
          );
        },
      ),
    );
  }
}
