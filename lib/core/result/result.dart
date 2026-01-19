/// Result type for handling success and failure cases.
///
/// This follows functional programming patterns to handle errors
/// without throwing exceptions. All use cases return `Result<T>`.
///
/// Architecture note: This is the primary way to handle errors
/// across layer boundaries. It makes error handling explicit
/// and forces consumers to handle both success and failure cases.
library;

import '../error/failures.dart' as failures;

/// A Result type that represents either success or failure.
/// 
/// Usage:
/// ```dart
/// final result = await useCase(params);
/// result.fold(
///   onSuccess: (data) => print('Success: $data'),
///   onFailure: (failure) => print('Error: ${failure.message}'),
/// );
/// ```
sealed class Result<T> {
  const Result();

  /// Returns true if this is a successful result.
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a failure result.
  bool get isFailure => this is Failure<T>;

  /// Gets the data if successful, null otherwise.
  T? get dataOrNull => isSuccess ? (this as Success<T>).data : null;

  /// Gets the failure if failed, null otherwise.
  failures.Failure? get failureOrNull =>
      isFailure ? (this as Failure<T>).failure : null;

  /// Pattern matching for Result.
  /// 
  /// Forces handling of both success and failure cases.
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(failures.Failure failure) onFailure,
  });

  /// Maps the success value to a new type.
  Result<R> map<R>(R Function(T data) mapper) {
    return fold(
      onSuccess: (data) => Success(mapper(data)),
      onFailure: (failure) => Failure(failure),
    );
  }

  /// Flat maps the success value to a new Result.
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return fold(
      onSuccess: (data) => mapper(data),
      onFailure: (failure) => Failure(failure),
    );
  }

  /// Returns the data or a default value if failed.
  T getOrElse(T defaultValue) {
    return fold(
      onSuccess: (data) => data,
      onFailure: (_) => defaultValue,
    );
  }

  /// Returns the data or throws the failure message.
  T getOrThrow() {
    return fold(
      onSuccess: (data) => data,
      onFailure: (failure) => throw Exception(failure.message),
    );
  }
}

/// Represents a successful result with data.
class Success<T> extends Result<T> {
  final T data;

  const Success(this.data);

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(failures.Failure failure) onFailure,
  }) =>
      onSuccess(data);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Success<T> && other.data == data;
  }

  @override
  int get hashCode => data.hashCode;

  @override
  String toString() => 'Success($data)';
}

/// Represents a failed result with a failure.
class Failure<T> extends Result<T> {
  final failures.Failure failure;

  const Failure(this.failure);

  /// Convenience constructor for creating a Failure with a message.
  factory Failure.withMessage(String message, {String? code}) {
    return Failure(failures.BusinessRuleFailure(message: message, code: code));
  }

  @override
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(failures.Failure failure) onFailure,
  }) =>
      onFailure(failure);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure<T> && other.failure == failure;
  }

  @override
  int get hashCode => failure.hashCode;

  @override
  String toString() => 'Failure(${failure.message})';
}

/// Extension methods for Result.
extension ResultExtensions<T> on Result<T> {
  /// Executes a side effect on success.
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }

  /// Executes a side effect on failure.
  Result<T> onFailure(void Function(failures.Failure failure) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).failure);
    }
    return this;
  }
}

/// Extension for converting nullable values to Result.
extension NullableToResult<T> on T? {
  /// Converts a nullable value to a Result.
  /// Returns Success if not null, Failure otherwise.
  Result<T> toResult({String errorMessage = 'Value is null'}) {
    if (this != null) {
      return Success(this as T);
    }
    return Failure(failures.NotFoundFailure(message: errorMessage));
  }
}