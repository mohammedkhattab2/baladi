/// Custom exceptions for the application.
///
/// These exceptions are used in the data layer and are
/// converted to [Failure] types when crossing layer boundaries.
///
/// Architecture note: Exceptions are thrown in data layer,
/// caught in repositories, and converted to Result/Failure.
library;

/// Base exception class for all application exceptions.
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Exception thrown when a server/API error occurs.
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });

  @override
  String toString() => 'ServerException: $message (status: $statusCode)';
}

/// Exception thrown when there's no internet connection.
class NetworkException extends AppException {
  const NetworkException({
    super.message = 'No internet connection',
    super.code = 'NETWORK_ERROR',
    super.originalError,
  });
}

/// Exception thrown when local cache operations fail.
class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.originalError,
  });
}

/// Exception thrown when authentication fails.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code = 'AUTH_ERROR',
    super.originalError,
  });
}

/// Exception thrown when requested data is not found.
class NotFoundException extends AppException {
  const NotFoundException({
    required super.message,
    super.code = 'NOT_FOUND',
    super.originalError,
  });
}

/// Exception thrown when validation fails.
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    this.fieldErrors,
  });
}

/// Exception thrown when user doesn't have permission.
class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'You do not have permission to perform this action',
    super.code = 'UNAUTHORIZED',
    super.originalError,
  });
}

/// Exception thrown when data sync fails.
class SyncException extends AppException {
  const SyncException({
    required super.message,
    super.code = 'SYNC_ERROR',
    super.originalError,
  });
}