// Domain - Use case for user logout.
//
// Logs out the current user, invalidates tokens on the server,
// and clears all local auth data.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Logs out the current user.
///
/// Sends a logout request to the backend to invalidate tokens,
/// then clears all locally stored authentication data.
@lazySingleton
class Logout extends UseCase<void, NoParams> {
  final AuthRepository _repository;

  /// Creates a [Logout] use case.
  Logout(this._repository);

  @override
  Future<Result<void>> call(NoParams params) {
    return _repository.logout();
  }
}