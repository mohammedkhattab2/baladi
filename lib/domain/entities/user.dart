/// User entity in the Baladi application.
/// 
/// This is a pure domain entity with no framework dependencies.
/// It represents a user in the system regardless of their role.
/// 
/// Architecture note: Entities are immutable value objects that
/// represent core business concepts. They contain no business logic,
/// only data and basic validation.
library;
import '../enums/user_role.dart';

/// Represents a user in the system.
class User {
  /// Unique identifier for the user.
  final String id;

  /// User's role in the system.
  final UserRole role;

  /// Phone number (for customers).
  final String? phoneNumber;

  /// Username (for store/delivery/admin).
  final String? username;

  /// Whether the user account is active.
  final bool isActive;

  /// Whether the user has been approved (for store/delivery).
  final bool isApproved;

  /// Firebase Cloud Messaging token for push notifications.
  final String? fcmToken;

  /// When the user was created.
  final DateTime createdAt;

  /// When the user was last updated.
  final DateTime? updatedAt;

  /// When the user last logged in.
  final DateTime? lastLoginAt;

  const User({
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

  /// Creates a copy of this user with the given fields replaced.
  User copyWith({
    String? id,
    UserRole? role,
    String? phoneNumber,
    String? username,
    bool? isActive,
    bool? isApproved,
    String? fcmToken,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastLoginAt,
  }) {
    return User(
      id: id ?? this.id,
      role: role ?? this.role,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      username: username ?? this.username,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      fcmToken: fcmToken ?? this.fcmToken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  /// Returns true if the user can perform actions in the system.
  bool get canOperate => isActive && (role == UserRole.customer || isApproved);

  /// Returns the display identifier (phone or username).
  String get displayIdentifier => phoneNumber ?? username ?? id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, role: ${role.name})';
}