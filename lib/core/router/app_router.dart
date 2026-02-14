// Core - GoRouter configuration for declarative navigation.
//
// Defines all application routes organized by role (auth, customer,
// shop, rider, admin). Includes redirect logic for authentication
// guards and role-based access control.

import 'package:baladi/presentation/features/auth/screens/customer_login_screen.dart';
import 'package:baladi/presentation/features/auth/screens/customer_register_screen.dart';
import 'package:baladi/presentation/features/auth/screens/pin_recovery_screen.dart';
import 'package:baladi/presentation/features/auth/screens/staff_login_screen.dart';
import 'package:baladi/presentation/features/auth/screens/welcome_screen.dart';
import 'package:baladi/presentation/features/customer/screens/customer_home_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:injectable/injectable.dart';

import '../services/local_storage_service.dart';
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
  final LocalStorageService _localStorage;
  final SecureStorageService _secureStorage;

  late final GoRouter router;

  /// Creates an [AppRouter] with required storage services for auth checks.
  AppRouter({
    required LocalStorageService localStorage,
    required SecureStorageService secureStorage,
  }) : _localStorage = localStorage,
       _secureStorage = secureStorage {
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
                return _PlaceholderScreen(title: 'Category: $slug');
              },
            ),
            GoRoute(
              path: RouteNames.shopDetailsPath,
              name: RouteNames.shopDetails,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return _PlaceholderScreen(title: 'Shop: $id');
              },
            ),
            GoRoute(
              path: RouteNames.customerOrderDetailsPath,
              name: RouteNames.customerOrderDetails,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return _PlaceholderScreen(title: 'Order: $id');
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.cartPath,
          name: RouteNames.cart,
          builder: (context, state) => const _PlaceholderScreen(title: 'Cart'),
        ),
        GoRoute(
          path: RouteNames.checkoutPath,
          name: RouteNames.checkout,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Checkout'),
        ),
        GoRoute(
          path: RouteNames.ordersHistoryPath,
          name: RouteNames.ordersHistory,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Orders History'),
        ),
        GoRoute(
          path: RouteNames.pointsPath,
          name: RouteNames.points,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Points'),
        ),
        GoRoute(
          path: RouteNames.referralPath,
          name: RouteNames.referral,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Referral'),
        ),
        GoRoute(
          path: RouteNames.customerProfilePath,
          name: RouteNames.customerProfile,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Profile'),
        ),

        // ─── Shop Routes ──────────────────────────────────────────
        GoRoute(
          path: RouteNames.shopDashboardPath,
          name: RouteNames.shopDashboard,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Shop Dashboard'),
          routes: [
            GoRoute(
              path: RouteNames.shopOrderManagePath,
              name: RouteNames.shopOrderManage,
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return _PlaceholderScreen(title: 'Manage Order: $id');
              },
            ),
          ],
        ),
        GoRoute(
          path: RouteNames.shopOrdersPath,
          name: RouteNames.shopOrders,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Shop Orders'),
        ),
        GoRoute(
          path: RouteNames.shopProductsPath,
          name: RouteNames.shopProducts,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Shop Products'),
        ),
        GoRoute(
          path: RouteNames.shopSettingsPath,
          name: RouteNames.shopSettings,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Shop Settings'),
        ),
        GoRoute(
          path: RouteNames.shopSettlementsPath,
          name: RouteNames.shopSettlements,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Shop Settlements'),
        ),

        // ─── Rider Routes ─────────────────────────────────────────
        GoRoute(
          path: RouteNames.riderDashboardPath,
          name: RouteNames.riderDashboard,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Rider Dashboard'),
        ),
        GoRoute(
          path: RouteNames.riderAvailableOrdersPath,
          name: RouteNames.riderAvailableOrders,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Available Orders'),
        ),
        GoRoute(
          path: RouteNames.riderCurrentDeliveryPath,
          name: RouteNames.riderCurrentDelivery,
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return _PlaceholderScreen(title: 'Delivery: $id');
          },
        ),
        GoRoute(
          path: RouteNames.riderEarningsPath,
          name: RouteNames.riderEarnings,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Rider Earnings'),
        ),
        GoRoute(
          path: RouteNames.riderProfilePath,
          name: RouteNames.riderProfile,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Rider Profile'),
        ),

        // ─── Admin Routes ─────────────────────────────────────────
        GoRoute(
          path: RouteNames.adminDashboardPath,
          name: RouteNames.adminDashboard,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Dashboard'),
        ),
        GoRoute(
          path: RouteNames.adminUsersPath,
          name: RouteNames.adminUsers,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Users'),
        ),
        GoRoute(
          path: RouteNames.adminShopsPath,
          name: RouteNames.adminShops,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Shops'),
        ),
        GoRoute(
          path: RouteNames.adminRidersPath,
          name: RouteNames.adminRiders,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Riders'),
        ),
        GoRoute(
          path: RouteNames.adminOrdersPath,
          name: RouteNames.adminOrders,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Orders'),
        ),
        GoRoute(
          path: RouteNames.adminPeriodsPath,
          name: RouteNames.adminPeriods,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Periods'),
        ),
        GoRoute(
          path: RouteNames.adminSettlementsPath,
          name: RouteNames.adminSettlements,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Settlements'),
        ),
        GoRoute(
          path: RouteNames.adminPointsPath,
          name: RouteNames.adminPoints,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Admin Points'),
        ),

        // ─── Common Routes ────────────────────────────────────────
        GoRoute(
          path: RouteNames.notificationsPath,
          name: RouteNames.notifications,
          builder: (context, state) =>
              const _PlaceholderScreen(title: 'Notifications'),
        ),
      ],
    );
  }

  /// Global redirect logic for authentication and role-based routing.
  ///
  /// - Unauthenticated users are sent to the welcome screen.
  /// - Authenticated users on auth pages are sent to their role-specific home.
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

    if (isAuthenticated && isOnAuthPage) {
      // Authenticated but on auth page → redirect to role home
      return await _getRoleHomePath();
    }

    return null; // No redirect needed
  }

  /// Returns the home path for the currently authenticated user's role.
  Future<String> _getRoleHomePath() async {
    final role = await _localStorage.getUserRole();
    return switch (role) {
      'customer' => RouteNames.customerHomePath,
      'shop' => RouteNames.shopDashboardPath,
      'rider' => RouteNames.riderDashboardPath,
      'admin' => RouteNames.adminDashboardPath,
      _ => RouteNames.welcomePath,
    };
  }
}

/// Temporary placeholder screen used until real feature screens are implemented.
///
/// Will be replaced by actual screen widgets during feature development.
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}
