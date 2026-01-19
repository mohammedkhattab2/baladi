/// Failure types for the application.
///
/// Failures are used in the domain layer to represent errors
/// without throwing exceptions. They are returned as part of
/// the Result type.
///
/// Architecture note: Failures are domain-level error representations.
/// They are created from exceptions in the repository layer.
library;

/// Base failure class for all application failures.
sealed class Failure {
  final String message;
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Failure for server/API errors.
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode,
  });
}

/// Failure for network connectivity issues.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'No internet connection. Please check your network.',
    super.code = 'NETWORK_ERROR',
  });
}

/// Failure for cache/storage issues.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
  });
}

/// Failure for authentication issues.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
  });
}

/// Failure when data is not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND',
  });
}

/// Failure for validation errors.
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    this.fieldErrors,
  });
}

/// Failure for unauthorized actions.
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({
    super.message = 'You do not have permission to perform this action',
    super.code = 'UNAUTHORIZED',
  });
}

/// Failure for data sync issues.
class SyncFailure extends Failure {
  const SyncFailure({
    required super.message,
    super.code = 'SYNC_ERROR',
  });
}

/// Failure for business rule violations.
class BusinessRuleFailure extends Failure {
  const BusinessRuleFailure({
    required super.message,
    super.code = 'BUSINESS_RULE_ERROR',
  });
}