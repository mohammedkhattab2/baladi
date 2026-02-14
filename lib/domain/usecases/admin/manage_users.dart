// Domain - Use cases for admin user management.
//
// Provides GetUsers (list all users with optional role filter)
// and ToggleUserStatus (activate/deactivate a user account).

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user.dart';
import '../../repositories/admin_repository.dart';

// ─── GetUsers ────────────────────────────────────────────────────────────────

/// Parameters for fetching users.
class GetUsersParams extends Equatable {
  /// Optional role filter (e.g. 'customer', 'shop', 'rider').
  final String? role;

  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetUsersParams].
  const GetUsersParams({this.role, this.page = 1, this.perPage = 20});

  @override
  List<Object?> get props => [role, page, perPage];
}

/// Fetches a paginated list of users, optionally filtered by role.
@lazySingleton
class GetUsers extends UseCase<List<User>, GetUsersParams> {
  final AdminRepository _repository;

  /// Creates a [GetUsers] use case.
  GetUsers(this._repository);

  @override
  Future<Result<List<User>>> call(GetUsersParams params) {
    return _repository.getUsers(
      role: params.role,
      page: params.page,
      perPage: params.perPage,
    );
  }
}

// ─── ToggleUserStatus ────────────────────────────────────────────────────────

/// Parameters for toggling a user's active status.
class ToggleUserStatusParams extends Equatable {
  /// The user's unique identifier.
  final String userId;

  /// Whether the user should be active.
  final bool isActive;

  /// Creates [ToggleUserStatusParams].
  const ToggleUserStatusParams({
    required this.userId,
    required this.isActive,
  });

  @override
  List<Object?> get props => [userId, isActive];
}

/// Activates or deactivates a user account.
@lazySingleton
class ToggleUserStatus extends UseCase<User, ToggleUserStatusParams> {
  final AdminRepository _repository;

  /// Creates a [ToggleUserStatus] use case.
  ToggleUserStatus(this._repository);

  @override
  Future<Result<User>> call(ToggleUserStatusParams params) {
    return _repository.toggleUserStatus(
      userId: params.userId,
      isActive: params.isActive,
    );
  }
}