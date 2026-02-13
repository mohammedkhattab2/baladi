// Core - Failure classes for functional error handling via the Result pattern.
//
// Failures are value objects (not exceptions) that represent error states
// returned from use cases and repositories. All failures extend [Failure]
// and implement [Equatable] for easy comparison in tests and state checks.

import 'package:equatable/equatable.dart';

import 'exceptions.dart';

/// Abstract base failure class.
///
/// Every domain-level error is represented as a [Failure] subclass carrying
/// a human-readable [message] and an optional programmatic [code].
abstract class Failure extends Equatable {
  /// A human-readable description of the failure.
  final String message;

  /// An optional error code for programmatic identification.
  final String? code;

  const Failure({
    required this.message,
    this.code,
  });

  @override
  List<Object?> get props => [message, code];

  /// Maps an [AppException] to the corresponding [Failure] subtype.
  static Failure fromException(AppException e) {
    if (e is ServerException) {
      return ServerFailure(
        message: e.message,
        code: e.code,
        statusCode: e.statusCode,
      );
    } else if (e is CacheException) {
      return CacheFailure(message: e.message, code: e.code);
    } else if (e is NetworkException) {
      return NetworkFailure(message: e.message, code: e.code);
    } else if (e is AuthException) {
      return AuthFailure(message: e.message, code: e.code);
    } else if (e is ValidationException) {
      return ValidationFailure(
        message: e.message,
        code: e.code,
        fieldErrors: e.fieldErrors,
      );
    } else if (e is NotFoundException) {
      return NotFoundFailure(message: e.message, code: e.code);
    } else if (e is TimeoutException) {
      return ServerFailure(message: e.message, code: e.code, statusCode: 408);
    }
    return ServerFailure(message: e.message, code: e.code, statusCode: 500);
  }
}

/// Failure originating from a server/API error.
class ServerFailure extends Failure {
  /// The HTTP status code associated with the server error.
  final int statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    this.statusCode = 500,
  });

  @override
  List<Object?> get props => [message, code, statusCode];
}

/// Failure originating from a local cache operation.
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code,
  });
}

/// Failure indicating the device has no network connectivity.
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'لا يوجد اتصال بالإنترنت',
    super.code = 'NETWORK_ERROR',
  });
}

/// Failure indicating an authentication or authorization error.
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    super.code = 'AUTH_ERROR',
  });
}

/// Failure carrying field-level validation errors.
class ValidationFailure extends Failure {
  /// Map of field names to their respective error messages.
  final Map<String, String> fieldErrors;

  const ValidationFailure({
    required super.message,
    required this.fieldErrors,
    super.code = 'VALIDATION_ERROR',
  });

  @override
  List<Object?> get props => [message, code, fieldErrors];
}

/// Failure indicating a requested resource was not found.
class NotFoundFailure extends Failure {
  const NotFoundFailure({
    required super.message,
    super.code = 'NOT_FOUND',
  });
}