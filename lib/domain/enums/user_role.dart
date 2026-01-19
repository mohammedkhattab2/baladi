/// User roles in the Baladi application.
/// 
/// Each role has different permissions and access levels.
/// 
/// Architecture note: Enums are part of the domain layer
/// and define the possible states/types for entities.
library;
/// Available user roles in the system.
enum UserRole {
  /// Customer who places orders.
  customer,
  
  /// Store/merchant who sells products.
  store,
  
  /// Delivery rider who delivers orders.
  delivery,
  
  /// Admin with full system access.
  admin;

  /// Returns display name for the role.
  String get displayName {
    return switch (this) {
      UserRole.customer => 'Customer',
      UserRole.store => 'Store',
      UserRole.delivery => 'Delivery',
      UserRole.admin => 'Admin',
    };
  }

  /// Returns Arabic display name for the role.
  String get displayNameAr {
    return switch (this) {
      UserRole.customer => 'عميل',
      UserRole.store => 'متجر',
      UserRole.delivery => 'توصيل',
      UserRole.admin => 'مدير',
    };
  }

  /// Returns true if this role requires admin approval.
  bool get requiresApproval {
    return switch (this) {
      UserRole.customer => false,
      UserRole.store => true,
      UserRole.delivery => true,
      UserRole.admin => true,
    };
  }

  /// Returns true if this role can manage products.
  bool get canManageProducts {
    return this == UserRole.store || this == UserRole.admin;
  }

  /// Returns true if this role can accept orders.
  bool get canAcceptOrders {
    return this == UserRole.store || this == UserRole.admin;
  }

  /// Returns true if this role can deliver orders.
  bool get canDeliverOrders {
    return this == UserRole.delivery || this == UserRole.admin;
  }

  /// Parses a string to UserRole.
  static UserRole? fromString(String? value) {
    if (value == null) return null;
    return UserRole.values.where((r) => r.name == value).firstOrNull;
  }
}