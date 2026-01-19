/// Environment configuration for dependency injection.
///
/// This allows switching between development, staging, and production
/// configurations without code changes.
///
/// Architecture note: Environment configuration is a core concern
/// that affects DI setup, logging, and API endpoints.
library;

/// Available environments for the application.
enum Environment {
  /// Development environment with mock data and verbose logging.
  dev,
  
  /// Staging environment for testing with real backend.
  staging,
  
  /// Production environment with optimized settings.
  prod,
}

/// Configuration settings for each environment.
class EnvironmentConfig {
  /// Current environment.
  final Environment environment;
  
  /// Base URL for API calls.
  final String apiBaseUrl;
  
  /// Whether to enable debug logging.
  final bool enableLogging;
  
  /// Whether to use mock data instead of real API.
  final bool useMockData;
  
  /// Cache timeout duration.
  final Duration cacheTimeout;
  
  /// Interval for background sync operations.
  final Duration syncInterval;
  
  /// Connection timeout for API calls.
  final Duration connectionTimeout;
  
  /// Read timeout for API calls.
  final Duration readTimeout;

  const EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.useMockData,
    required this.cacheTimeout,
    required this.syncInterval,
    required this.connectionTimeout,
    required this.readTimeout,
  });

  /// Development configuration.
  static const EnvironmentConfig dev = EnvironmentConfig._(
    environment: Environment.dev,
    apiBaseUrl: 'http://localhost:3000/api',
    enableLogging: true,
    useMockData: true,
    cacheTimeout: Duration(minutes: 5),
    syncInterval: Duration(seconds: 30),
    connectionTimeout: Duration(seconds: 30),
    readTimeout: Duration(seconds: 30),
  );

  /// Staging configuration.
  static const EnvironmentConfig staging = EnvironmentConfig._(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.baladi.app/api',
    enableLogging: true,
    useMockData: false,
    cacheTimeout: Duration(minutes: 10),
    syncInterval: Duration(minutes: 1),
    connectionTimeout: Duration(seconds: 15),
    readTimeout: Duration(seconds: 15),
  );

  /// Production configuration.
  static const EnvironmentConfig prod = EnvironmentConfig._(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.baladi.app/api',
    enableLogging: false,
    useMockData: false,
    cacheTimeout: Duration(minutes: 15),
    syncInterval: Duration(minutes: 2),
    connectionTimeout: Duration(seconds: 10),
    readTimeout: Duration(seconds: 10),
  );

  /// Current active configuration.
  /// Defaults to development.
  static EnvironmentConfig _current = dev;
  
  /// Gets the current environment configuration.
  static EnvironmentConfig get current => _current;

  /// Initializes the environment configuration.
  /// 
  /// Should be called once at app startup.
  static void initialize(Environment env) {
    _current = switch (env) {
      Environment.dev => dev,
      Environment.staging => staging,
      Environment.prod => prod,
    };
  }

  /// Whether this is a development environment.
  bool get isDev => environment == Environment.dev;

  /// Whether this is a staging environment.
  bool get isStaging => environment == Environment.staging;

  /// Whether this is a production environment.
  bool get isProd => environment == Environment.prod;

  @override
  String toString() => 'EnvironmentConfig(${environment.name})';
}