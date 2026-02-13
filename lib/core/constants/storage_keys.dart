// Core - Keys for all local storage (SecureStorage, SharedPreferences, Hive).
//
// Centralizes every storage key used across the application to prevent
// typos and ensure consistency. Organized by storage backend.

/// Storage key constants for SecureStorage, SharedPreferences, and Hive boxes.
class StorageKeys {
  StorageKeys._();

  // ─── Flutter Secure Storage Keys ──────────────────────────────────────

  /// Key for the JWT access token in secure storage.
  static const String accessToken = 'access_token';

  /// Key for the JWT refresh token in secure storage.
  static const String refreshToken = 'refresh_token';

  /// Key for the user's PIN in secure storage.
  static const String userPin = 'user_pin';

  // ─── SharedPreferences Keys ───────────────────────────────────────────

  /// Key for the currently authenticated user's ID.
  static const String userId = 'user_id';

  /// Key for the currently authenticated user's role (customer/shop/rider/admin).
  static const String userRole = 'user_role';

  /// Key for the currently authenticated user's display name.
  static const String userName = 'user_name';

  /// Key for the device's Firebase Cloud Messaging token.
  static const String fcmToken = 'fcm_token';

  /// Key for the first-launch flag (onboarding).
  static const String isFirstLaunch = 'is_first_launch';

  /// Key for the timestamp of the last background sync.
  static const String lastSyncTime = 'last_sync_time';

  /// Key for the user's selected language code.
  static const String selectedLanguage = 'selected_language';

  // ─── Hive Box Names ───────────────────────────────────────────────────

  /// Hive box name for cached orders.
  static const String ordersBox = 'orders_box';

  /// Hive box name for cached products.
  static const String productsBox = 'products_box';

  /// Hive box name for the shopping cart.
  static const String cartBox = 'cart_box';

  /// Hive box name for cached notifications.
  static const String notificationsBox = 'notifications_box';

  /// Hive box name for cached user data.
  static const String userBox = 'user_box';
}