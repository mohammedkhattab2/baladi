// Core - GoRouter configuration for declarative navigation.
//
// Defines all application routes organized by role (auth, customer,
// shop, rider, admin). Includes redirect logic for authentication
// guards and role-based access control.

import 'package:baladi/domain/entities/shop.dart';
import 'package:baladi/presentation/features/admin/screens/admin_dashboard_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_orders_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_periods_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_points_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_riders_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_settlements_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_shops_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_users_screen.dart';
import 'package:baladi/presentation/features/admin/screens/admin_categories_screen.dart';
import 'package:baladi/presentation/features/auth/screens/customer_login_screen.dart';
import 'package:baladi/presentation/features/auth/screens/customer_register_screen.dart';
import 'package:baladi/presentation/features/auth/screens/pin_recovery_screen.dart';
import 'package:baladi/presentation/features/auth/screens/staff_login_screen.dart';
import 'package:baladi/presentation/features/auth/screens/welcome_screen.dart';
import 'package:baladi/presentation/features/customer/screens/cart_screen.dart';
import 'package:baladi/presentation/features/customer/screens/category_shops_screen.dart';
import 'package:baladi/presentation/features/customer/screens/checkout_screen.dart';
import 'package:baladi/presentation/features/customer/screens/customer_home_screen.dart';
import 'package:baladi/presentation/features/customer/screens/customer_order_details_screen.dart';
import 'package:baladi/presentation/features/customer/screens/orders_history_screen.dart';
import 'package:baladi/presentation/features/customer/screens/shop_details_screen.dart';
import 'package:baladi/presentation/features/rider/screens/rider_available_orders_screen.dart';
import 'package:baladi/presentation/features/rider/screens/rider_current_delivery_screen.dart';
import 'package:baladi/presentation/features/rider/screens/rider_dashboard_screen.dart';
import 'package:baladi/presentation/features/rider/screens/rider_earnings_screen.dart';
import 'package:baladi/presentation/features/rider/screens/rider_profile_screen.dart';
import 'package:baladi/presentation/features/customer/screens/customer_profile_screen.dart';
import 'package:baladi/presentation/features/customer/screens/customer_notifications_screen.dart';
import 'package:baladi/presentation/features/shop/screens/points_screen.dart';
import 'package:baladi/presentation/features/shop/screens/referral_screen.dart';
import 'package:baladi/presentation/features/shop/screens/shop_dashboard_screen.dart';
import 'package:baladi/presentation/features/shop/screens/shop_order_manage_screen.dart';
import 'package:baladi/presentation/features/shop/screens/shop_orders_screen.dart';
import 'package:baladi/presentation/features/shop/screens/shop_products_screen.dart';
import 'package:baladi/presentation/features/shop/screens/shop_settings_screen.dart';
import 'package:baladi/presentation/features/shop/screens/shop_settlements_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../services/secure_storage_service.dart';
import 'route_names.dart';

/// Builds and configures the application's [GoRouter] instance.
///
/// The router handles:
/// - Authentication redirects (unauthenticated → welcome)
/// - Role-based home screen routing (customer/shop/rider/admin)
/// - Deep linking from push notifications
@lazySingleton
class AppRouter {
  final SecureStorageService _secureStorage;

  late final GoRouter router;

  /// Creates an [AppRouter] with required storage services for auth checks.
  AppRouter({required SecureStorageService secureStorage})
    : _secureStorage = secureStorage {
    router = _createRouter();
  }

  GoRouter _createRouter() {
    return GoRouter(
      initialLocation: RouteNames.welcomePath,
      debugLogDiagnostics: true,
      redirect: _globalRedirect,
      routes: [
        // ─── Auth Routes ──────────────────────────────────────────
        GoRoute(
          name: RouteNames.welcome,
          path: RouteNames.welcomePath,
          builder: (context, state) => const WelcomeScreen(),
        ),

        GoRoute(
          name: RouteNames.customerLogin,
          path: RouteNames.customerLoginPath,
          builder: (context, state) => const CustomerLoginScreen(),
        ),
        GoRoute(
          name: RouteNames.customerRegister,
          path: RouteNames.customerRegisterPath,
          builder: (context, state) => const CustomerRegisterScreen(),
        ),
        GoRoute(
          name: RouteNames.pinRecovery,
          path: RouteNames.pinRecoveryPath,
          builder: (context, state) => const PinRecoveryScreen(),
        ),
        GoRoute(
          name: RouteNames.staffLogin,
          path: RouteNames.staffLoginPath,
          builder: (context, state) => const StaffLoginScreen(),
        ),

        // ─── Customer Routes ──────────────────────────────────────
        GoRoute(
          path: RouteNames.customerHomePath,
          name: RouteNames.customerHome,
          builder: (context, state) => const CustomerHomeScreen(),
          routes: [
            GoRoute(
              path: RouteNames.categoryShopsPath,
              name: RouteNames.categoryShops,
              builder: (context, state) {
                final slug = state.pathParameters['slug']!;
                return CategoryShopsScreen(categorySlug: slug);
              },
            ),
            GoRoute(
              path: RouteNames.shopDetailsPath,
              name: RouteNames.shopDetails,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                final shop = state.extra as Shop?;
                return ShopDetailsScreen(shopId: id, initialShop: shop);
              },
            ),
            GoRoute(
              path: RouteNames.customerOrderDetailsPath,
              name: RouteNames.customerOrderDetails,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return CustomerOrderDetailsScreen(orderId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.cartPath,
          name: RouteNames.cart,
          builder: (context, state) => const CustomerCartScreen(),
        ),
        GoRoute(
          path: RouteNames.checkoutPath,
          name: RouteNames.checkout,
          builder: (context, state) => const CheckoutScreen(),
        ),
        GoRoute(
          path: RouteNames.ordersHistoryPath,
          name: RouteNames.ordersHistory,
          builder: (context, state) => const OrdersHistoryScreen(),
        ),
        GoRoute(
          path: RouteNames.pointsPath,
          name: RouteNames.points,
          builder: (context, state) => const PointsScreen(),
        ),
        GoRoute(
          path: RouteNames.referralPath,
          name: RouteNames.referral,
          builder: (context, state) => const ReferralScreen(),
        ),
        GoRoute(
          path: RouteNames.customerProfilePath,
          name: RouteNames.customerProfile,
          builder: (context, state) => const CustomerProfileScreen(),
        ),
        GoRoute(
          path: RouteNames.notificationsPath,
          name: RouteNames.notifications,
          builder: (context, state) => const CustomerNotificationsScreen(),
        ),

        // ─── Shop Routes ──────────────────────────────────────────
        GoRoute(
          path: RouteNames.shopDashboardPath,
          name: RouteNames.shopDashboard,
          builder: (context, state) => const ShopDashboardScreen(),
          routes: [
            GoRoute(
              path: RouteNames.shopOrderManagePath,
              name: RouteNames.shopOrderManage,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return ShopOrderManageScreen(orderId: id);
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.shopOrdersPath,
          name: RouteNames.shopOrders,
          builder: (context, state) => const ShopOrdersScreen(),
        ),
        GoRoute(
          path: RouteNames.shopProductsPath,
          name: RouteNames.shopProducts,
          builder: (context, state) => const ShopProductsScreen(),
        ),
        GoRoute(
          path: RouteNames.shopSettingsPath,
          name: RouteNames.shopSettings,
          builder: (context, state) => const ShopSettingsScreen(),
        ),
        GoRoute(
          path: RouteNames.shopSettlementsPath,
          name: RouteNames.shopSettlements,
          builder: (context, state) => const ShopSettlementsScreen(),
        ),

        // ─── Rider Routes ─────────────────────────────────────────
        GoRoute(
          path: RouteNames.riderDashboardPath,
          name: RouteNames.riderDashboard,
          builder: (context, state) => const RiderDashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.riderAvailableOrdersPath,
          name: RouteNames.riderAvailableOrders,
          builder: (context, state) => const RiderAvailableOrdersScreen(),
        ),
        GoRoute(
          path: RouteNames.riderCurrentDeliveryPath,
          name: RouteNames.riderCurrentDelivery,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return RiderCurrentDeliveryScreen(orderId: id);
          },
        ),
        GoRoute(
          path: RouteNames.riderEarningsPath,
          name: RouteNames.riderEarnings,
          builder: (context, state) => const RiderEarningsScreen(),
        ),
        GoRoute(
          path: RouteNames.riderProfilePath,
          name: RouteNames.riderProfile,
          builder: (context, state) => const RiderProfileScreen(),
        ),

        // ─── Admin Routes ─────────────────────────────────────────
        GoRoute(
          path: RouteNames.adminDashboardPath,
          name: RouteNames.adminDashboard,
          builder: (context, state) => const AdminDashboardScreen(),
        ),
        GoRoute(
          path: RouteNames.adminUsersPath,
          name: RouteNames.adminUsers,
          builder: (context, state) => const AdminUsersScreen(),
        ),
        GoRoute(
          path: RouteNames.adminShopsPath,
          name: RouteNames.adminShops,
          builder: (context, state) => const AdminShopsScreen(),
        ),
        GoRoute(
          path: RouteNames.adminCategoriesPath,
          name: RouteNames.adminCategories,
          builder: (context, state) => const AdminCategoriesScreen(),
        ),
        GoRoute(
          path: RouteNames.adminRidersPath,
          name: RouteNames.adminRiders,
          builder: (context, state) => const AdminRidersScreen(),
        ),
        GoRoute(
          path: RouteNames.adminOrdersPath,
          name: RouteNames.adminOrders,
          builder: (context, state) => const AdminOrdersScreen(),
        ),
        GoRoute(
          path: RouteNames.adminPeriodsPath,
          name: RouteNames.adminPeriods,
          builder: (context, state) => const AdminPeriodsScreen(),
        ),
        GoRoute(
          path: RouteNames.adminSettlementsPath,
          name: RouteNames.adminSettlements,
          builder: (context, state) => const AdminSettlementsScreen(),
        ),
        GoRoute(
          path: RouteNames.adminPointsPath,
          name: RouteNames.adminPoints,
          builder: (context, state) => const AdminPointsScreen(),
        ),

      ],
    );
  }

  /// Global redirect logic for authentication and role-based routing.
  ///
  /// - Unauthenticated users are sent to the welcome screen.
  /// - Auth pages (welcome, login, register) are always accessible — never
  ///   auto-redirect away from them so the app always starts at welcome.
  Future<String?> _globalRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final token = await _secureStorage.getAccessToken();
    final isAuthenticated = token != null && token.isNotEmpty;
    final currentPath = state.matchedLocation;

    // Auth page paths
    final isOnAuthPage =
        currentPath.startsWith('/welcome') || currentPath.startsWith('/auth');

    if (!isAuthenticated && !isOnAuthPage) {
      // Not authenticated and not on auth page → go to welcome
      return RouteNames.welcomePath;
    }

    // Never auto-redirect from auth pages — always show welcome/login screens.
    // "Remember me" only pre-fills credentials; the user must still tap login.
    return null;
  }
}



