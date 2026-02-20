// Domain - Use cases for admin user management.
//
// Provides GetUsers (list all users with optional role filter)
// and ToggleUserStatus (activate/deactivate a user account).

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/shop.dart';
import '../../entities/user.dart';
import '../../entities/rider.dart';
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

// ─── Create / Update Shop as Admin ──────────────────────────────────────────

/// Parameters for creating a new shop (with owner user) from the admin panel.
///
/// NOTE:
/// نحافظ على الـ payload كـ Map خام بحيث نقدر نطابق الـ Joi schema في الباك إند
/// بدون ما نربط الدومين مباشرةً بـ DTOs خاصة بالأدمن.
class CreateShopAsAdminParams extends Equatable {
  /// Raw payload that will be sent as-is to the backend.
  final Map<String, dynamic> payload;

  const CreateShopAsAdminParams({required this.payload});

  @override
  List<Object?> get props => [payload];
}

/// Creates a new shop (and its owner user) from the admin panel.
@lazySingleton
class CreateShopAsAdmin extends UseCase<Shop, CreateShopAsAdminParams> {
  final AdminRepository _repository;

  CreateShopAsAdmin(this._repository);

  @override
  Future<Result<Shop>> call(CreateShopAsAdminParams params) {
    return _repository.createShopAsAdmin(payload: params.payload);
  }
}

/// Parameters for updating an existing shop from the admin panel.
class UpdateShopAsAdminParams extends Equatable {
  /// Shop ID to update.
  final String shopId;

  /// Raw payload to send to backend.
  final Map<String, dynamic> payload;

  const UpdateShopAsAdminParams({
    required this.shopId,
    required this.payload,
  });

  @override
  List<Object?> get props => [shopId, payload];
}

/// Updates an existing shop from the admin panel.
@lazySingleton
class UpdateShopAsAdmin extends UseCase<Shop, UpdateShopAsAdminParams> {
  final AdminRepository _repository;

  UpdateShopAsAdmin(this._repository);

  @override
  Future<Result<Shop>> call(UpdateShopAsAdminParams params) {
    return _repository.updateShopAsAdmin(
      shopId: params.shopId,
      payload: params.payload,
    );
  }
}

// ─── Create / Update Rider as Admin ─────────────────────────────────────────

/// Parameters for creating a new rider (with user account) from the admin panel.
///
/// NOTE:
/// نستخدم Map خام للـ payload عشان نطابق الـ Joi schema في الباك إند من غير
/// ما نربط الدومين بـ DTOs خاصة بالأدمن.
class CreateRiderAsAdminParams extends Equatable {
  /// Raw payload that will be sent as-is to the backend.
  final Map<String, dynamic> payload;

  const CreateRiderAsAdminParams({required this.payload});

  @override
  List<Object?> get props => [payload];
}

/// Creates a new rider (and its user account) from the admin panel.
@lazySingleton
class CreateRiderAsAdmin extends UseCase<Rider, CreateRiderAsAdminParams> {
  final AdminRepository _repository;

  CreateRiderAsAdmin(this._repository);

  @override
  Future<Result<Rider>> call(CreateRiderAsAdminParams params) {
    return _repository.createRiderAsAdmin(payload: params.payload);
  }
}

/// Parameters for updating an existing rider from the admin panel.
class UpdateRiderAsAdminParams extends Equatable {
  /// Rider ID to update.
  final String riderId;

  /// Raw payload to send to backend.
  final Map<String, dynamic> payload;

  const UpdateRiderAsAdminParams({
    required this.riderId,
    required this.payload,
  });

  @override
  List<Object?> get props => [riderId, payload];
}

/// Updates an existing rider from the admin panel.
@lazySingleton
class UpdateRiderAsAdmin extends UseCase<Rider, UpdateRiderAsAdminParams> {
  final AdminRepository _repository;

  UpdateRiderAsAdmin(this._repository);

  @override
  Future<Result<Rider>> call(UpdateRiderAsAdminParams params) {
    return _repository.updateRiderAsAdmin(
      riderId: params.riderId,
      payload: params.payload,
    );
  }
}

// ─── ResetUserPassword ───────────────────────────────────────────────────────

/// Parameters for resetting a staff user's password.
///
/// Backend constraints (from Joi schema):
/// - Min 8 characters
/// - At least one uppercase, one lowercase, and one number
class ResetUserPasswordParams extends Equatable {
  /// The user's unique identifier.
  final String userId;

  /// The new password that satisfies backend policy.
  final String newPassword;

  const ResetUserPasswordParams({
    required this.userId,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [userId, newPassword];
}

/// Resets a staff (shop / rider / admin) user's password.
///
/// Backend:
///   POST /api/admin/users/:userId/reset-password
///   Body: { "new_password": "..." }
@lazySingleton
class ResetUserPassword extends UseCase<void, ResetUserPasswordParams> {
  final AdminRepository _repository;

  ResetUserPassword(this._repository);

  @override
  Future<Result<void>> call(ResetUserPasswordParams params) {
    return _repository.resetUserPassword(
      userId: params.userId,
      newPassword: params.newPassword,
    );
  }
}