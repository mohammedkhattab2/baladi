// Core - App-wide static constants and default configuration values.
//
// Contains application metadata, business rule defaults, and locale settings
// used throughout the app. All values are compile-time constants.

/// Application-wide configuration constants.
///
/// These values are shared across all features and should not change at runtime.
/// For environment-specific settings, see [EnvironmentConfig].
class AppConfig {
  AppConfig._();

  // ─── App Metadata ───────────────────────────────────────────────────

  /// Arabic application name displayed in UI.
  static const String appName = 'بلدي';

  /// English application name used in logs and technical contexts.
  static const String appNameEn = 'Baladi';

  /// Current application version string.
  static const String appVersion = '1.0.0';

  // ─── Business Rules ─────────────────────────────────────────────────

  /// Default commission rate charged on each order (10%).
  static const double defaultCommissionRate = 0.10;

  /// Default delivery fee in EGP.
  static const double defaultDeliveryFee = 10.0;

  /// Number of loyalty points earned per 1 EGP spent.
  static const double pointsPerCurrencyUnit = 100.0;

  /// Value in EGP of 1 loyalty point when redeemed.
  static const double pointValueInCurrency = 1.0;

  /// Number of bonus points awarded for a successful referral.
  static const int referralBonusPoints = 2;

  // ─── PIN / Auth ─────────────────────────────────────────────────────

  /// Minimum allowed PIN length.
  static const int minPinLength = 4;

  /// Maximum allowed PIN length.
  static const int maxPinLength = 6;

  // ─── Locale & Regional ──────────────────────────────────────────────

  /// The day the business week starts (Saturday in Egypt).
  static const int weekStartDay = DateTime.saturday;

  /// Default currency code.
  static const String defaultCurrency = 'EGP';

  /// Default locale identifier.
  static const String defaultLocale = 'ar_EG';

  /// Default timezone identifier (Cairo).
  static const String defaultTimezone = 'Africa/Cairo';
}