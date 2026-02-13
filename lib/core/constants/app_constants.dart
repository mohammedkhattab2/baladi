// Core - App-wide constants for pagination, timeouts, cache durations, and limits.
//
// These constants define system-wide defaults that are referenced across
// multiple features. They are compile-time constants and do not vary
// by environment (see [EnvironmentConfig] for environment-specific values).

/// Application-wide numeric and duration constants.
class AppConstants {
  AppConstants._();

  // ─── Pagination ───────────────────────────────────────────────────────

  /// Default number of items per page for paginated requests.
  static const int defaultPageSize = 20;

  /// Maximum allowed items per page.
  static const int maxPageSize = 100;

  // ─── Timeouts ─────────────────────────────────────────────────────────

  /// HTTP connection timeout.
  static const Duration connectionTimeout = Duration(seconds: 15);

  /// HTTP response receive timeout.
  static const Duration receiveTimeout = Duration(seconds: 15);

  // ─── Cache Durations ──────────────────────────────────────────────────

  /// How long category data is cached locally.
  static const Duration categoriesCacheDuration = Duration(hours: 6);

  /// How long shop listing data is cached locally.
  static const Duration shopsCacheDuration = Duration(minutes: 30);

  /// How long product data is cached locally.
  static const Duration productsCacheDuration = Duration(minutes: 15);

  // ─── Limits ───────────────────────────────────────────────────────────

  /// Maximum number of items allowed in the shopping cart.
  static const int maxCartItems = 50;

  /// Maximum character length for order notes.
  static const int maxOrderNotes = 500;

  /// Maximum character length for a delivery address.
  static const int maxAddressLength = 255;

  // ─── Auth ─────────────────────────────────────────────────────────────

  /// Required PIN length for customer authentication.
  static const int pinLength = 4;

  /// Maximum consecutive failed login attempts before lockout.
  static const int maxLoginAttempts = 5;

  /// Duration the account is locked after exceeding [maxLoginAttempts].
  static const Duration lockoutDuration = Duration(minutes: 15);

  /// Lifetime of an access token before it must be refreshed.
  static const Duration accessTokenExpiry = Duration(minutes: 15);

  /// Lifetime of a refresh token before the user must re-authenticate.
  static const Duration refreshTokenExpiry = Duration(days: 7);

  // ─── Orders ───────────────────────────────────────────────────────────

  /// Time before an unaccepted order is automatically rejected.
  static const Duration orderAutoRejectTimeout = Duration(minutes: 10);

  // ─── Referral ─────────────────────────────────────────────────────────

  /// Character length of generated referral codes.
  static const int referralCodeLength = 8;
}