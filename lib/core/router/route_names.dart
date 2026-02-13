// Core - Centralized route name constants for navigation.
//
// All named routes used by GoRouter are defined here to prevent
// typos and enable easy refactoring of navigation paths.

/// Static route name and path constants for the entire application.
///
/// Organized by feature module. Use these constants with GoRouter's
/// `goNamed()` and `pushNamed()` methods.
class RouteNames {
  RouteNames._();

  // ─── Auth ─────────────────────────────────────────────────────────

  /// Welcome / landing screen.
  static const String welcome = 'welcome';
  static const String welcomePath = '/welcome';

  /// Customer login screen.
  static const String customerLogin = 'customerLogin';
  static const String customerLoginPath = '/auth/customer/login';

  /// Customer registration screen.
  static const String customerRegister = 'customerRegister';
  static const String customerRegisterPath = '/auth/customer/register';

  /// PIN recovery screen.
  static const String pinRecovery = 'pinRecovery';
  static const String pinRecoveryPath = '/auth/customer/recover';

  /// Staff (shop/rider/admin) login screen.
  static const String staffLogin = 'staffLogin';
  static const String staffLoginPath = '/auth/staff/login';

  // ─── Customer ─────────────────────────────────────────────────────

  /// Customer home screen (categories + ads).
  static const String customerHome = 'customerHome';
  static const String customerHomePath = '/customer';

  /// Shops list for a category.
  static const String categoryShops = 'categoryShops';
  static const String categoryShopsPath = 'category/:slug/shops';

  /// Shop details + product listing.
  static const String shopDetails = 'shopDetails';
  static const String shopDetailsPath = 'shop/:id';

  /// Shopping cart screen.
  static const String cart = 'cart';
  static const String cartPath = '/customer/cart';

  /// Checkout / order confirmation screen.
  static const String checkout = 'checkout';
  static const String checkoutPath = '/customer/checkout';

  /// Customer order details.
  static const String customerOrderDetails = 'customerOrderDetails';
  static const String customerOrderDetailsPath = 'order/:id';

  /// Customer orders history.
  static const String ordersHistory = 'ordersHistory';
  static const String ordersHistoryPath = '/customer/orders';

  /// Customer loyalty points screen.
  static const String points = 'points';
  static const String pointsPath = '/customer/points';

  /// Customer referral screen.
  static const String referral = 'referral';
  static const String referralPath = '/customer/referral';

  /// Customer profile screen.
  static const String customerProfile = 'customerProfile';
  static const String customerProfilePath = '/customer/profile';

  // ─── Shop Management ──────────────────────────────────────────────

  /// Shop owner dashboard.
  static const String shopDashboard = 'shopDashboard';
  static const String shopDashboardPath = '/shop';

  /// Shop orders list.
  static const String shopOrders = 'shopOrders';
  static const String shopOrdersPath = '/shop/orders';

  /// Shop order management (accept, prepare, etc.).
  static const String shopOrderManage = 'shopOrderManage';
  static const String shopOrderManagePath = 'order/:id';

  /// Shop products management.
  static const String shopProducts = 'shopProducts';
  static const String shopProductsPath = '/shop/products';

  /// Shop product add/edit form.
  static const String shopProductForm = 'shopProductForm';
  static const String shopProductFormPath = 'product/form';

  /// Shop settings screen.
  static const String shopSettings = 'shopSettings';
  static const String shopSettingsPath = '/shop/settings';

  /// Shop settlements screen.
  static const String shopSettlements = 'shopSettlements';
  static const String shopSettlementsPath = '/shop/settlements';

  // ─── Rider ────────────────────────────────────────────────────────

  /// Rider dashboard.
  static const String riderDashboard = 'riderDashboard';
  static const String riderDashboardPath = '/rider';

  /// Available orders for rider to accept.
  static const String riderAvailableOrders = 'riderAvailableOrders';
  static const String riderAvailableOrdersPath = '/rider/available';

  /// Current delivery tracking screen.
  static const String riderCurrentDelivery = 'riderCurrentDelivery';
  static const String riderCurrentDeliveryPath = '/rider/delivery/:id';

  /// Rider earnings screen.
  static const String riderEarnings = 'riderEarnings';
  static const String riderEarningsPath = '/rider/earnings';

  /// Rider profile screen.
  static const String riderProfile = 'riderProfile';
  static const String riderProfilePath = '/rider/profile';

  // ─── Admin ────────────────────────────────────────────────────────

  /// Admin dashboard.
  static const String adminDashboard = 'adminDashboard';
  static const String adminDashboardPath = '/admin';

  /// Admin users management.
  static const String adminUsers = 'adminUsers';
  static const String adminUsersPath = '/admin/users';

  /// Admin shops management.
  static const String adminShops = 'adminShops';
  static const String adminShopsPath = '/admin/shops';

  /// Admin riders management.
  static const String adminRiders = 'adminRiders';
  static const String adminRidersPath = '/admin/riders';

  /// Admin orders management.
  static const String adminOrders = 'adminOrders';
  static const String adminOrdersPath = '/admin/orders';

  /// Admin weekly periods management.
  static const String adminPeriods = 'adminPeriods';
  static const String adminPeriodsPath = '/admin/periods';

  /// Admin settlements screen.
  static const String adminSettlements = 'adminSettlements';
  static const String adminSettlementsPath = '/admin/settlements';

  /// Admin points management.
  static const String adminPoints = 'adminPoints';
  static const String adminPointsPath = '/admin/points';

  // ─── Common ───────────────────────────────────────────────────────

  /// Notifications screen.
  static const String notifications = 'notifications';
  static const String notificationsPath = '/notifications';
}