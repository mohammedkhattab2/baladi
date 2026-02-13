// Domain - User role enumeration.
//
// Defines the four roles in the Baladi system. Each role has
// different permissions and views in the application.

/// The role of an authenticated user in the system.
enum UserRole {
  /// End-user who places orders for delivery.
  customer('customer', 'عميل'),

  /// Shop owner who manages products and accepts/prepares orders.
  shop('shop', 'متجر'),

  /// Delivery person who picks up and delivers orders.
  rider('rider', 'سائق توصيل'),

  /// System administrator with full management access.
  admin('admin', 'مدير');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label for the role.
  final String labelAr;

  const UserRole(this.value, this.labelAr);

  /// Creates a [UserRole] from its string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any role.
  static UserRole fromValue(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw ArgumentError('Unknown UserRole: $value'),
    );
  }

  /// Returns `true` if this role can manage orders (shop, rider, admin).
  bool get canManageOrders =>
      this == UserRole.shop ||
      this == UserRole.rider ||
      this == UserRole.admin;

  /// Returns `true` if this role uses phone+PIN authentication.
  bool get usesPhoneAuth => this == UserRole.customer;

  /// Returns `true` if this role uses username+password authentication.
  bool get usesPasswordAuth =>
      this == UserRole.shop ||
      this == UserRole.rider ||
      this == UserRole.admin;
}