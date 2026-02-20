// Core - Environment configuration for dev, staging, and production.
//
// Provides environment-specific settings such as API base URL, logging,
// cache timeouts, and connection timeouts. Call [EnvironmentConfig.initialize]
// at app startup to set the active environment.

/// The three supported deployment environments.
enum Environment {
  /// Local development environment.
  dev,

  /// Pre-production staging environment.
  staging,

  /// Live production environment.
  prod,
}

/// Holds all configuration values that vary per [Environment].
///
/// Usage:
/// ```dart
/// void main() {
///   EnvironmentConfig.initialize(Environment.dev);
///   final baseUrl = EnvironmentConfig.current.apiBaseUrl;
/// }
/// ```
class EnvironmentConfig {
  /// The active environment (dev, staging, or prod).
  final Environment environment;

  /// The base URL for all API requests.
  final String apiBaseUrl;

  /// Whether debug logging is enabled.
  final bool enableLogging;

  /// Whether to use local mock data instead of real API calls.
  final bool useMockData;

  /// How long cached data is considered valid before re-fetching.
  final Duration cacheTimeout;

  /// Interval between background sync operations.
  final Duration syncInterval;

  /// HTTP connection timeout duration.
  final Duration connectTimeout;

  const EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.useMockData,
    required this.cacheTimeout,
    required this.syncInterval,
    required this.connectTimeout,
  });

  /// The currently active [EnvironmentConfig].
  ///
  /// Throws [StateError] if [initialize] has not been called.
  static EnvironmentConfig get current {
    final config = _current;
    if (config == null) {
      throw StateError(
        'EnvironmentConfig has not been initialized. '
        'Call EnvironmentConfig.initialize(Environment) before accessing current.',
      );
    }
    return config;
  }

  static EnvironmentConfig? _current;

  /// Initializes the environment configuration for the given [env].
  ///
  /// Must be called once at app startup before any code accesses [current].
  static void initialize(Environment env) {
    _current = switch (env) {
      Environment.dev => const EnvironmentConfig._(
          environment: Environment.dev,
          apiBaseUrl: 'http://192.168.1.3:5000/api',
          enableLogging: true,
          useMockData: false,
          cacheTimeout: Duration(minutes: 5),
          syncInterval: Duration(seconds: 30),
          connectTimeout: Duration(seconds: 10),
        ),
      Environment.staging => const EnvironmentConfig._(
          environment: Environment.staging,
          apiBaseUrl: 'https://staging-api.baladi.app/api/v1',
          enableLogging: true,
          useMockData: false,
          cacheTimeout: Duration(minutes: 10),
          syncInterval: Duration(minutes: 1),
          connectTimeout: Duration(seconds: 15),
        ),
      Environment.prod => const EnvironmentConfig._(
          environment: Environment.prod,
          apiBaseUrl: 'https://api.baladi.app/api/v1',
          enableLogging: false,
          useMockData: false,
          cacheTimeout: Duration(minutes: 15),
          syncInterval: Duration(minutes: 2),
          connectTimeout: Duration(seconds: 15),
        ),
    };
  }

  /// Whether the current environment is development.
  bool get isDev => environment == Environment.dev;

  /// Whether the current environment is staging.
  bool get isStaging => environment == Environment.staging;

  /// Whether the current environment is production.
  bool get isProd => environment == Environment.prod;

  @override
  String toString() =>
      'EnvironmentConfig(environment: ${environment.name}, apiBaseUrl: $apiBaseUrl)';
}