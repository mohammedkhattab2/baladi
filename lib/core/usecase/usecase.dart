/// Base use case interface for the application.
///
/// All use cases implement this interface to ensure consistent
/// signature across the domain layer.
///
/// Architecture note: Use cases represent single actions in the domain.
/// They orchestrate domain services and repositories to fulfill
/// business requirements.
library;

import '../result/result.dart';

/// Base interface for all use cases.
///
/// [T] is the return type on success.
/// [Params] is the input parameters type.
///
/// Usage:
/// ```dart
/// class GetUser implements UseCase<User, GetUserParams> {
///   @override
///   Future<Result<User>> call(GetUserParams params) async {
///     // Implementation
///   }
/// }
/// ```
abstract class UseCase<T, Params> {
  /// Executes the use case with the given parameters.
  Future<Result<T>> call(Params params);
}

/// Use this when a use case doesn't need parameters.
/// 
/// Usage:
/// ```dart
/// class GetCurrentUser implements UseCase<User, NoParams> {
///   @override
///   Future<Result<User>> call(NoParams params) async {
///     // Implementation
///   }
/// }
/// 
/// // Call with:
/// final result = await getCurrentUser(const NoParams());
/// ```
class NoParams {
  const NoParams();

  @override
  bool operator ==(Object other) => other is NoParams;

  @override
  int get hashCode => 0;
}

/// Base interface for synchronous use cases.
///
/// Use this for use cases that don't need async operations,
/// such as pure calculations.
abstract class SyncUseCase<T, Params> {
  /// Executes the use case synchronously with the given parameters.
  Result<T> call(Params params);
}

/// Base interface for stream-based use cases.
///
/// Use this for use cases that return a stream of data,
/// such as real-time updates.
abstract class StreamUseCase<T, Params> {
  /// Returns a stream of results.
  Stream<Result<T>> call(Params params);
}