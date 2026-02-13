// Core - Result wrapper implementing the Either pattern (Success/Failure).
//
// Provides a type-safe way to represent the outcome of an operation that
// can either succeed with data of type [T] or fail with a [Failure].

import '../error/exceptions.dart';
import '../error/failures.dart';

/// A sealed class representing the result of an operation.
///
/// Use [Success] to wrap successful data and [ResultFailure] to wrap
/// a [Failure] instance. Provides functional combinators like [fold],
/// [map], and [flatMap] for ergonomic consumption.
sealed class Result<T> {
  const Result();

  /// Whether this result represents a successful outcome.
  bool get isSuccess => this is Success<T>;

  /// Whether this result represents a failed outcome.
  bool get isFailure => this is ResultFailure<T>;

  /// Returns the success data or `null` if this is a failure.
  T? get data => switch (this) {
        Success<T>(:final data) => data,
        ResultFailure<T>() => null,
      };

  /// Returns the failure or `null` if this is a success.
  Failure? get failure => switch (this) {
        Success<T>() => null,
        ResultFailure<T>(:final failure) => failure,
      };

  /// Pattern-matches on this result, invoking [onSuccess] or [onFailure].
  ///
  /// ```dart
  /// final message = result.fold(
  ///   onSuccess: (data) => 'Got $data',
  ///   onFailure: (failure) => 'Error: ${failure.message}',
  /// );
  /// ```
  R fold<R>({
    required R Function(T data) onSuccess,
    required R Function(Failure failure) onFailure,
  }) {
    return switch (this) {
      Success<T>(:final data) => onSuccess(data),
      ResultFailure<T>(:final failure) => onFailure(failure),
    };
  }

  /// Transforms the success data using [transform], leaving failures untouched.
  Result<R> map<R>(R Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => Success<R>(transform(data)),
      ResultFailure<T>(:final failure) => ResultFailure<R>(failure),
    };
  }

  /// Chains an operation that itself returns a [Result], leaving failures untouched.
  Result<R> flatMap<R>(Result<R> Function(T data) transform) {
    return switch (this) {
      Success<T>(:final data) => transform(data),
      ResultFailure<T>(:final failure) => ResultFailure<R>(failure),
    };
  }

  /// Wraps an async [action] in a try/catch, returning a [Result].
  ///
  /// [AppException]s are mapped to [Failure] via [Failure.fromException].
  /// Any other exception is wrapped in a [ServerFailure].
  ///
  /// ```dart
  /// final result = await Result.guard(() => api.fetchUser(id));
  /// ```
  static Future<Result<T>> guard<T>(Future<T> Function() action) async {
    try {
      final data = await action();
      return Success<T>(data);
    } on AppException catch (e) {
      return ResultFailure<T>(Failure.fromException(e));
    } catch (e) {
      return ResultFailure<T>(
        ServerFailure(message: e.toString(), statusCode: 500),
      );
    }
  }
}

/// Represents a successful result carrying [data] of type [T].
class Success<T> extends Result<T> {
  /// The successful data payload.
  @override
  final T data;

  const Success(this.data);

  @override
  String toString() => 'Success(data: $data)';
}

/// Represents a failed result carrying a [Failure] instance.
class ResultFailure<T> extends Result<T> {
  /// The failure describing what went wrong.
  @override
  final Failure failure;

  const ResultFailure(this.failure);

  @override
  String toString() => 'ResultFailure(failure: $failure)';
}