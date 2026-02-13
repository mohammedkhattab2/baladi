// Core - Base UseCase interface for Clean Architecture.
//
// Every use case in the application implements [UseCase] with a specific
// return type [T] and parameter type [Params]. Use cases encapsulate
// a single piece of business logic and return a [Result].

import 'package:equatable/equatable.dart';

import '../result/result.dart';

/// Abstract use case contract.
///
/// [T] is the success data type returned by the use case.
/// [Params] is the parameter object required to execute the use case.
///
/// ```dart
/// class GetUser extends UseCase<User, GetUserParams> {
///   @override
///   Future<Result<User>> call(GetUserParams params) async { ... }
/// }
/// ```
abstract class UseCase<T, Params> {
  /// Executes the use case with the given [params].
  Future<Result<T>> call(Params params);
}

/// A parameter class used when a use case requires no input parameters.
///
/// ```dart
/// class GetCategories extends UseCase<List<Category>, NoParams> {
///   @override
///   Future<Result<List<Category>>> call(NoParams params) async { ... }
/// }
///
/// // Usage:
/// final result = await getCategories(NoParams());
/// ```
class NoParams extends Equatable {
  const NoParams();

  @override
  List<Object?> get props => [];
}