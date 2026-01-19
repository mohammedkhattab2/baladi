/// User Data Transfer Object.
///
/// Used for serialization/deserialization of User data
/// between API/database and domain entities.
library;

import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';

/// DTO for User entity.
class UserDto {
  final String id;
  final String role;
  final String? phoneNumber;
  final String? username;
  final bool isActive;
  final bool isApproved;
  final String? fcmToken;
  final String createdAt;
  final String? updatedAt;
  final String? lastLoginAt;

  const UserDto({
    required this.id,
    required this.role,
    this.phoneNumber,
    this.username,
    this.isActive = true,
    this.isApproved = false,
    this.fcmToken,
    required this.createdAt,
    this.updatedAt,
    this.lastLoginAt,
  });

  /// Create from JSON map.
  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      username: json['username'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      isApproved: json['is_approved'] as bool? ?? false,
      fcmToken: json['fcm_token'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      lastLoginAt: json['last_login_at'] as String?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role,
      'phone_number': phoneNumber,
      'username': username,
      'is_active': isActive,
      'is_approved': isApproved,
      'fcm_token': fcmToken,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'last_login_at': lastLoginAt,
    };
  }

  /// Convert to domain entity.
  User toEntity() {
    return User(
      id: id,
      role: UserRole.fromString(role) ?? UserRole.customer,
      phoneNumber: phoneNumber,
      username: username,
      isActive: isActive,
      isApproved: isApproved,
      fcmToken: fcmToken,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      lastLoginAt: lastLoginAt != null ? DateTime.parse(lastLoginAt!) : null,
    );
  }

  /// Create from domain entity.
  factory UserDto.fromEntity(User entity) {
    return UserDto(
      id: entity.id,
      role: entity.role.name,
      phoneNumber: entity.phoneNumber,
      username: entity.username,
      isActive: entity.isActive,
      isApproved: entity.isApproved,
      fcmToken: entity.fcmToken,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
      lastLoginAt: entity.lastLoginAt?.toIso8601String(),
    );
  }
}