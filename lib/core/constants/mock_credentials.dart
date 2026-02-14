// Core - Mock credentials for development/testing.
//
// Provides predefined test account credentials for each user role
// so developers can quickly log in without remembering credentials.

import '../../domain/enums/user_role.dart';

/// A single mock account entry.
class MockAccount {
  /// Display label (Arabic).
  final String label;

  /// The user role.
  final UserRole role;

  /// Phone number (for customer login).
  final String? phone;

  /// PIN code (for customer login).
  final String? pin;

  /// Username (for staff login).
  final String? username;

  /// Password (for staff login).
  final String? password;

  /// Icon to display in the quick-login panel.
  final String emoji;

  const MockAccount({
    required this.label,
    required this.role,
    this.phone,
    this.pin,
    this.username,
    this.password,
    required this.emoji,
  });
}

/// Predefined mock accounts for all roles.
///
/// These credentials must match accounts that exist in the backend
/// (or Supabase seed data). Update values as needed.
class MockCredentials {
  MockCredentials._();

  static const customer = MockAccount(
    label: 'عميل تجريبي',
    role: UserRole.customer,
    phone: '01000000000',
    pin: '1234',
    emoji: '🛒',
  );

  static const shop = MockAccount(
    label: 'متجر تجريبي',
    role: UserRole.shop,
    username: 'shop_test',
    password: 'password123',
    emoji: '🏪',
  );

  static const rider = MockAccount(
    label: 'سائق تجريبي',
    role: UserRole.rider,
    username: 'rider_test',
    password: 'password123',
    emoji: '🛵',
  );

  static const admin = MockAccount(
    label: 'مدير تجريبي',
    role: UserRole.admin,
    username: 'admin_test',
    password: 'password123',
    emoji: '👨‍💼',
  );

  /// All mock accounts in display order.
  static const List<MockAccount> all = [customer, shop, rider, admin];
}