/// Repository interface for authentication operations.
/// 
/// This defines the contract for authentication-related data access.
/// The data layer will implement this interface.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/user.dart';
import '../enums/user_role.dart';

/// Authentication repository interface.
abstract class AuthRepository {
  /// Authenticate customer with mobile number and PIN.
  /// 
  /// Returns the authenticated user on success.
  Future<Result<User>> loginWithPin({
    required String mobileNumber,
    required String pin,
  });

  /// Authenticate shop/rider/admin with username and password.
  /// 
  /// Returns the authenticated user on success.
  Future<Result<User>> loginWithCredentials({
    required String username,
    required String password,
  });

  /// Register a new customer.
  /// 
  /// Requires mobile number, PIN, name, and security answer.
  Future<Result<User>> registerCustomer({
    required String mobileNumber,
    required String pin,
    required String name,
    required String securityAnswer,
  });

  /// Recover customer account using security question.
  /// 
  /// Returns true if answer is correct, allowing PIN reset.
  Future<Result<bool>> verifySecurityAnswer({
    required String mobileNumber,
    required String securityAnswer,
  });

  /// Reset customer PIN after security verification.
  Future<Result<void>> resetPin({
    required String mobileNumber,
    required String newPin,
  });

  /// Request password reset for shop/rider (admin handles this).
  Future<Result<void>> requestPasswordReset({
    required String username,
    required UserRole role,
  });

  /// Change password for authenticated user.
  Future<Result<void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  });

  /// Get currently authenticated user.
  Future<Result<User?>> getCurrentUser();

  /// Logout current user.
  Future<Result<void>> logout();

  /// Check if user session is valid.
  Future<Result<bool>> isSessionValid();

  /// Refresh authentication token.
  Future<Result<void>> refreshToken();

  /// Register device for push notifications.
  Future<Result<void>> registerDeviceToken({
    required String userId,
    required String deviceToken,
  });

  /// Unregister device from push notifications.
  Future<Result<void>> unregisterDeviceToken({
    required String userId,
    required String deviceToken,
  });
}