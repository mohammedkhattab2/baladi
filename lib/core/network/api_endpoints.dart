// Core - All API endpoint paths as static constants organized by feature.
//
// Centralizes every REST endpoint used by the application so that paths
// are defined in a single place. Methods with parameters use string
// interpolation to build dynamic paths.

/// Static API endpoint path constants grouped by feature domain.
class ApiEndpoints {
  ApiEndpoints._();

  // ─── Auth ─────────────────────────────────────────────────────────────

  /// POST — Register a new customer account.
  static const String customerRegister = '/auth/customer/register';

  /// POST — Customer login with phone + PIN.
  static const String customerLogin = '/auth/customer/login';

  /// POST — Customer account recovery.
  static const String customerRecover = '/auth/customer/recover';

  /// POST — Generic login (shop/rider/admin).
  static const String login = '/auth/login';

  /// POST — Refresh the access token.
  static const String refresh = '/auth/refresh';

  /// POST — Logout and invalidate tokens.
  static const String logout = '/auth/logout';

  /// PUT — Update the device FCM token for push notifications.
  static const String updateFcmToken = '/auth/fcm-token';

  /// POST — Get security question for a customer by phone.
  static const String securityQuestion = '/auth/customer/security-question';

  /// POST — Reset customer PIN after verifying security answer.
  static const String resetPin = '/auth/customer/reset-pin';

  // ─── Customer ─────────────────────────────────────────────────────────

  /// GET/PUT — Customer profile.
  static const String customerProfile = '/customer/profile';

  /// GET/POST/PUT/DELETE — Customer addresses.
  static const String customerAddress = '/customer/address';

  /// GET — Customer loyalty points balance.
  static const String customerPoints = '/customer/points';

  /// GET — Customer loyalty points transaction history.
  static const String customerPointsHistory = '/customer/points/history';

  /// POST — Redeem customer loyalty points on an order.
  static const String customerPointsRedeem = '/customer/points/redeem';

  /// GET — Customer referral info (own code, stats).
  static const String customerReferral = '/customer/referral';

  /// POST — Apply a referral code.
  static const String customerReferralApply = '/customer/referral/apply';

  // ─── Categories ───────────────────────────────────────────────────────

  /// GET — List all categories.
  static const String categories = '/categories';

  /// GET — List shops for a category by slug.
  static String categoryShops(String slug) => '/categories/$slug/shops';

  // ─── Shops ────────────────────────────────────────────────────────────

  /// GET — Shop details by ID.
  static String shopDetails(String id) => '/shops/$id';

  /// GET — List products for a shop by ID.
  static String shopProducts(String id) => '/shops/$id/products';

  // ─── Orders ───────────────────────────────────────────────────────────

  /// GET/POST — List orders or create a new order.
  static const String orders = '/orders';

  /// GET — Order details by ID.
  static String orderDetails(String id) => '/orders/$id';

  /// PUT — Shop accepts an order.
  static String orderAccept(String id) => '/orders/$id/accept';

  /// PUT — Shop marks an order as preparing.
  static String orderPreparing(String id) => '/orders/$id/preparing';

  /// PUT — Rider picks up the order.
  static String orderPickup(String id) => '/orders/$id/pickup';

  /// PUT — Rider delivers the order.
  static String orderDeliver(String id) => '/orders/$id/deliver';

  /// PUT — Rider confirms cash collection.
  static String orderConfirmCash(String id) => '/orders/$id/confirm-cash';

  /// PUT — Cancel an order.
  static String orderCancel(String id) => '/orders/$id/cancel';

  // ─── Shop Management ─────────────────────────────────────────────────

  /// GET/PUT — Shop owner profile.
  static const String shopProfile = '/shop/profile';

  /// PUT — Toggle shop open/closed status.
  static const String shopStatus = '/shop/status';

  /// GET/POST — Shop owner's product management.
  static const String shopProductsManage = '/shop/products';

  /// GET/PUT/DELETE — Single product management by ID.
  static String shopProductById(String id) => '/shop/products/$id';

  /// GET — Shop owner's orders.
  static const String shopOrders = '/shop/orders';

  /// GET — Shop owner's dashboard stats.
  static const String shopDashboard = '/shop/dashboard';

  /// GET — Shop owner's settlement history.
  static const String shopSettlements = '/shop/settlements';

  /// GET/POST — Shop owner's advertisements.
  static const String shopAds = '/shop/ads';

  // ─── Rider ────────────────────────────────────────────────────────────

  /// GET/PUT — Rider profile.
  static const String riderProfile = '/rider/profile';

  /// PUT — Toggle rider availability status.
  static const String riderStatus = '/rider/status';

  /// GET — Available orders for the rider to accept.
  static const String riderAvailableOrders = '/rider/orders/available';

  /// GET — Rider's assigned/completed orders.
  static const String riderOrders = '/rider/orders';

  /// GET — Rider dashboard stats.
  static const String riderDashboard = '/rider/dashboard';

  /// GET — Rider earnings summary.
  static const String riderEarnings = '/rider/earnings';

  /// GET — Rider settlement history.
  static const String riderSettlements = '/rider/settlements';

  // ─── Ads ──────────────────────────────────────────────────────────────

  /// GET — List active advertisements.
  static const String activeAds = '/ads/active';

  // ─── Admin ────────────────────────────────────────────────────────────

  /// GET — Admin dashboard stats.
  static const String adminDashboard = '/admin/dashboard';

  /// GET — Admin manage users.
  static const String adminUsers = '/admin/users';

  /// GET — Admin manage shops.
  static const String adminShops = '/admin/shops';

  /// GET — Admin manage riders.
  static const String adminRiders = '/admin/riders';

  /// GET — Admin manage orders.
  static const String adminOrders = '/admin/orders';

  /// GET — Admin settlement periods.
  static const String adminPeriods = '/admin/periods';

  /// POST — Admin close a settlement period.
  static const String adminPeriodsClose = '/admin/periods/close';

  /// GET — Admin settlements.
  static const String adminSettlements = '/admin/settlements';

  /// POST — Admin adjust customer loyalty points.
  static const String adminPointsAdjust = '/admin/points/adjust';

  // ─── Notifications ────────────────────────────────────────────────────

  /// GET — List notifications.
  static const String notifications = '/notifications';

  /// PUT — Mark a single notification as read.
  static String notificationRead(String id) => '/notifications/$id/read';

  /// PUT — Mark all notifications as read.
  static const String notificationsReadAll = '/notifications/read-all';
}