// Data - User model with JSON serialization.
//
// Maps between the API JSON representation and the domain User entity.

import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';

/// Data model for [User] with JSON serialization support.
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.role,
    super.phone,
    super.username,
    super.fcmToken,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.value == json['role'],
        orElse: () => UserRole.customer,
      ),
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      fcmToken: json['fcm_token'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Creates a [UserModel] from a domain [User] entity.
  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      role: user.role,
      phone: user.phone,
      username: user.username,
      fcmToken: user.fcmToken,
      isActive: user.isActive,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.value,
      'phone': phone,
      'username': username,
      'fcm_token': fcmToken,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}