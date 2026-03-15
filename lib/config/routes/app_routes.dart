import 'package:go_router/go_router.dart';
import '../../features/billing/presentation/pages/home_page.dart';
import '../../features/product/presentation/pages/product_list_page.dart';
import '../../features/product/presentation/pages/add_product_page.dart';
import '../../features/product/presentation/pages/edit_product_page.dart';
import '../../features/shop/presentation/pages/shop_details_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/settings/presentation/pages/auth_entry_page.dart';
import '../../features/settings/presentation/pages/platform_registration_page.dart';
import '../../features/settings/presentation/pages/cash_register_setup_page.dart';
import '../../features/settings/presentation/pages/cashier_login_page.dart';
import '../../features/settings/presentation/pages/owner_login_page.dart';
import '../../features/settings/presentation/pages/open_shift_page.dart';
import '../../features/settings/presentation/pages/cashier_device_qr_page.dart';
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
  initialLocation: '/auth',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const AuthEntryPage(),
    ),
    GoRoute(
      path: '/platform-registration',
      builder: (context, state) => const PlatformRegistrationPage(),
    ),
    GoRoute(
      path: '/cash-register-setup',
      builder: (context, state) => const CashRegisterSetupPage(),
    ),
    GoRoute(
      path: '/cashier-login',
      builder: (context, state) => const CashierLoginPage(),
    ),
    GoRoute(
      path: '/owner-login',
      builder: (context, state) => const OwnerLoginPage(),
    ),
    GoRoute(
      path: '/cashier-device-qr',
      builder: (context, state) {
        final deviceId = (state.extra as String?) ?? '';
        return CashierDeviceQrPage(deviceId: deviceId);
      },
    ),
    GoRoute(
      path: '/open-shift',
      builder: (context, state) => const OpenShiftPage(),
    ),
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
          path: 'platform-registration',
          builder: (context, state) => const PlatformRegistrationPage(),
        ),
        GoRoute(
          path: 'cash-register-setup',
          builder: (context, state) => const CashRegisterSetupPage(),
        ),
        GoRoute(
          path: 'cashier-login',
          builder: (context, state) => const CashierLoginPage(),
        ),
        GoRoute(
          path: 'open-shift',
          builder: (context, state) => const OpenShiftPage(),
        ),
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
