// Domain - Auth repository interface.
//
// Defines the contract for authentication operations including
// customer phone+PIN auth and staff username+password auth.

import '../../core/result/result.dart';
import '../entities/customer.dart';
import '../entities/user.dart';
import '../enums/user_role.dart';

/// Authentication token pair returned after successful login.
class AuthTokens {
  /// JWT access token for API requests.
  final String accessToken;

  /// Refresh token for obtaining new access tokens.
  final String refreshToken;

  /// Creates an [AuthTokens] instance.
  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
  });
}

/// Combined result of a successful login operation.
class AuthResult {
  /// The authenticated user.
  final User user;

  /// The token pair.
  final AuthTokens tokens;

  /// Customer profile (only for customer role).
  final Customer? customer;

  /// Creates an [AuthResult].
  const AuthResult({
    required this.user,
    required this.tokens,
    this.customer,
  });
}

/// Repository contract for authentication operations.
///
/// Handles customer registration/login via phone+PIN,
/// staff login via username+password, token refresh, and logout.
abstract class AuthRepository {
  /// Registers a new customer with phone and PIN.
  ///
  /// - [phone]: Egyptian phone number (11 digits starting with 01).
  /// - [pin]: 4-digit PIN code.
  /// - [fullName]: Customer's full name.
  /// - [referralCode]: Optional referral code from another customer.
  Future<Result<AuthResult>> registerCustomer({
    required String phone,
    required String pin,
    required String fullName,
    String? referralCode,
  });

  /// Logs in a customer with phone and PIN.
  Future<Result<AuthResult>> loginCustomer({
    required String phone,
    required String pin,
  });

  /// Recovers a customer's PIN (sends reset via backend logic).
  Future<Result<void>> recoverCustomerPin({
    required String phone,
  });

  /// Logs in a staff user (shop/rider/admin) with username and password.
  Future<Result<AuthResult>> loginUser({
    required String username,
    required String password,
    required UserRole role,
  });

  /// Refreshes the access token using the refresh token.
  Future<Result<AuthTokens>> refreshToken();

  /// Logs out the current user and invalidates tokens.
  Future<Result<void>> logout();

  /// Updates the FCM token on the server for push notifications.
  Future<Result<void>> updateFcmToken(String fcmToken);

  /// Returns the currently stored access token, or `null` if not logged in.
  Future<String?> getAccessToken();

  /// Returns the currently stored refresh token.
  Future<String?> getRefreshToken();

  /// Persists auth tokens to secure storage.
  Future<void> saveTokens(AuthTokens tokens);

  /// Clears all stored auth data (tokens, user info).
  Future<void> clearAuthData();

  /// Returns whether the user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Returns the stored user role, or `null` if not logged in.
  Future<UserRole?> getStoredUserRole();
}