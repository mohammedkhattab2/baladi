// Domain - User entity.
//
// Represents the base authenticated user in the system. Each user
// has a role that determines their view and permissions.

import 'package:equatable/equatable.dart';

import '../enums/user_role.dart';

/// Base user entity shared across all roles.
///
/// The [User] holds authentication-level information. Role-specific
/// profile data lives in [Customer], [Shop], or [Rider] entities.
class User extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The user's role in the system.
  final UserRole role;

  /// Phone number (for customers).
  final String? phone;

  /// Username (for shop/rider/admin).
  final String? username;

  /// Firebase Cloud Messaging token for push notifications.
  final String? fcmToken;

  /// Whether the user account is active.
  final bool isActive;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.role,
    this.phone,
    this.username,
    this.fcmToken,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the display identifier — phone for customers, username for staff.
  String get displayIdentifier => phone ?? username ?? id;

  @override
  List<Object?> get props => [
        id,
        role,
        phone,
        username,
        fcmToken,
        isActive,
        createdAt,
        updatedAt,
      ];
}