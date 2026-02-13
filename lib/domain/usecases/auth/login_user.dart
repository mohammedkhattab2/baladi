// Domain - Use case for staff user login.
//
// Authenticates a staff user (shop, rider, admin) using
// username, password, and role.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../enums/user_role.dart';
import '../../repositories/auth_repository.dart';

/// Parameters for staff user login.
class LoginUserParams extends Equatable {
  /// Username for the staff account.
  final String username;

  /// Password for the staff account.
  final String password;

  /// The role of the staff user (shop, rider, or admin).
  final UserRole role;

  /// Creates [LoginUserParams].
  const LoginUserParams({
    required this.username,
    required this.password,
    required this.role,
  });

  @override
  List<Object?> get props => [username, password, role];
}

/// Authenticates a staff user with username, password, and role.
///
/// Used for shop owners, riders, and admin accounts.
/// Returns auth tokens and user profile on success.
@lazySingleton
class LoginUser extends UseCase<AuthResult, LoginUserParams> {
  final AuthRepository _repository;

  /// Creates a [LoginUser] use case.
  LoginUser(this._repository);

  @override
  Future<Result<AuthResult>> call(LoginUserParams params) {
    return _repository.loginUser(
      username: params.username,
      password: params.password,
      role: params.role,
    );
  }
}