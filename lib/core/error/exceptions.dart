// Core - Custom exception classes for structured error handling across the app.
//
// All exceptions extend [AppException] which provides a unified interface
// with [message] and optional [code] fields.

/// Base exception class for all application-specific exceptions.
class AppException implements Exception {
  /// A human-readable error message describing the exception.
  final String message;

  /// An optional error code for programmatic identification.
  final String? code;

  const AppException({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'AppException(message: $message, code: $code)';
}

/// Exception thrown when the server returns an error response.
///
/// Carries the HTTP [statusCode] and an optional raw [errorBody]
/// for further inspection or logging.
class ServerException extends AppException {
  /// The HTTP status code returned by the server.
  final int statusCode;

  /// The raw error body from the server response, if available.
  final Map<String, dynamic>? errorBody;

  const ServerException({
    required super.message,
    required this.statusCode,
    this.errorBody,
    super.code,
  });

  @override
  String toString() =>
      'ServerException(message: $message, statusCode: $statusCode, code: $code)';
}

/// Exception thrown when a local cache operation fails.
///
/// This covers SharedPreferences, Hive, and SecureStorage errors.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
  });

  @override
  String toString() => 'CacheException(message: $message, code: $code)';
}

/// Exception thrown when there is no network connectivity.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.code = 'NETWORK_ERROR',
  });

  @override
  String toString() => 'NetworkException(message: $message, code: $code)';
}

/// Exception thrown on authentication/authorization failures (401/403).
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
  });

  @override
  String toString() => 'AuthException(message: $message, code: $code)';
}

/// Exception thrown when input validation fails.
///
/// Carries a map of [fieldErrors] where keys are field names and values
/// are the corresponding validation error messages.
class ValidationException extends AppException {
  /// Field-level validation errors.
  final Map<String, String> fieldErrors;

  const ValidationException({
    required super.message,
    required this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
  });

  @override
  String toString() =>
      'ValidationException(message: $message, fieldErrors: $fieldErrors, code: $code)';
}

/// Exception thrown when a requested resource is not found (404).
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
  });

  @override
  String toString() => 'NotFoundException(message: $message, code: $code)';
}

/// Exception thrown when an HTTP request exceeds the allowed timeout.
class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'انتهت مهلة الطلب، يرجى المحاولة مرة أخرى',
    super.code = 'TIMEOUT',
  });

  @override
  String toString() => 'TimeoutException(message: $message, code: $code)';
}