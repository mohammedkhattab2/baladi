/// Remote data source for authentication operations.
///
/// This interface defines the contract for authentication API calls.
/// Implementation will use Supabase Auth or similar service.
library;

import '../../dto/user_dto.dart';

/// Remote data source interface for authentication.
abstract class AuthRemoteDataSource {
  /// Login customer with phone number and PIN.
  ///
  /// Returns [UserDto] on success.
  /// Throws [ServerException] on API failure.
  Future<UserDto> loginCustomer({
    required String phoneNumber,
    required String pin,
  });

  /// Login shop or rider with username and password.
  ///
  /// Returns [UserDto] on success.
  /// Throws [ServerException] on API failure.
  Future<UserDto> loginWithCredentials({
    required String username,
    required String password,
  });

  /// Register a new customer.
  ///
  /// Returns [UserDto] on success.
  /// Throws [ServerException] on API failure.
  Future<UserDto> registerCustomer({
    required String phoneNumber,
    required String pin,
    required String name,
    required String securityAnswer,
  });

  /// Verify customer security answer for PIN recovery.
  ///
  /// Returns true if answer matches.
  /// Throws [ServerException] on API failure.
  Future<bool> verifySecurityAnswer({
    required String phoneNumber,
    required String answer,
  });

  /// Reset customer PIN after security verification.
  ///
  /// Returns updated [UserDto] on success.
  /// Throws [ServerException] on API failure.
  Future<UserDto> resetPin({
    required String phoneNumber,
    required String newPin,
  });

  /// Get current user profile.
  ///
  /// Returns [UserDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [UnauthorizedException] if not logged in.
  Future<UserDto> getCurrentUser();

  /// Update user profile.
  ///
  /// Returns updated [UserDto] on success.
  /// Throws [ServerException] on API failure.
  Future<UserDto> updateProfile({
    required String userId,
    String? name,
    String? address,
    String? addressDetails,
  });

  /// Logout current user.
  ///
  /// Throws [ServerException] on API failure.
  Future<void> logout();

  /// Refresh authentication token.
  ///
  /// Returns new [UserDto] with refreshed token.
  /// Throws [ServerException] on API failure.
  Future<UserDto> refreshToken();
}
