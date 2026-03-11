import 'package:go_router/go_router.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/billing/presentation/pages/scanner_page.dart';
import '../../features/billing/presentation/pages/checkout_page.dart';
import '../../features/product/domain/entities/product.dart';
import '../../features/sales/presentation/pages/sales_history_page.dart';
import '../../features/measurement_unit/presentation/pages/measurement_units_page.dart';
import '../../features/product/presentation/pages/categories_page.dart';
import '../../features/product/presentation/pages/product_search_page.dart';
import '../../features/sales/presentation/pages/analytics_page.dart';
import '../../features/product/presentation/pages/stock_management_page.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
      routes: [
        GoRoute(
          path: 'scanner',
          builder: (context, state) => const ScannerPage(),
        ),
        GoRoute(
          path: 'checkout',
          builder: (context, state) => const CheckoutPage(),
        ),
        GoRoute(
          path: 'sales',
          builder: (context, state) => const SalesHistoryPage(),
        ),
        GoRoute(
          path: 'analytics',
          builder: (context, state) => const AnalyticsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
      routes: [
        GoRoute(
          path: 'units',
          builder: (context, state) => const MeasurementUnitsPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const ProductListPage(),
      routes: [
        GoRoute(
          path: 'add',
          builder: (context, state) => const AddProductPage(),
        ),
        GoRoute(
          path: 'edit/:id',
          builder: (context, state) {
            final product = state.extra as Product?;
            if (product == null) {
              return const ProductListPage();
            }
            return EditProductPage(product: product);
          },
        ),
        GoRoute(
          path: 'categories',
          builder: (context, state) => const CategoriesPage(),
        ),
        GoRoute(
          path: 'search',
          builder: (context, state) => const ProductSearchPage(),
        ),
        GoRoute(
          path: 'inventory',
          builder: (context, state) => const StockManagementPage(),
        ),
      ],
    ),
    GoRoute(
      path: '/shop',
      builder: (context, state) => const ShopDetailsPage(),
    ),
  ],
);
