/// Local data source for authentication operations.
///
/// This interface defines the contract for local auth data storage.
/// Implementation will use SharedPreferences or secure storage.
library;

import '../../dto/user_dto.dart';

/// Local data source interface for authentication.
abstract class AuthLocalDataSource {
  /// Cache current user data.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheUser(UserDto user);

  /// Get cached user data.
  /// 
  /// Returns [UserDto] if cached.
  /// Returns null if no cached user.
  /// Throws [CacheException] on storage failure.
  Future<UserDto?> getCachedUser();

  /// Clear cached user data.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearCachedUser();

  /// Cache authentication token.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheToken(String token);

  /// Get cached authentication token.
  /// 
  /// Returns token string if cached.
  /// Returns null if no cached token.
  /// Throws [CacheException] on storage failure.
  Future<String?> getCachedToken();

  /// Clear cached authentication token.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearCachedToken();

  /// Check if user is logged in (has cached token).
  /// 
  /// Returns true if token exists and is valid.
  Future<bool> isLoggedIn();

  /// Cache user PIN for quick login (encrypted).
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cachePinHash(String phoneNumber, String pinHash);

  /// Verify cached PIN hash.
  /// 
  /// Returns true if PIN hash matches.
  Future<bool> verifyPinHash(String phoneNumber, String pinHash);

  /// Clear all auth-related cache.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearAllAuthCache();

  /// Get last login timestamp.
  /// 
  /// Returns DateTime if available.
  Future<DateTime?> getLastLoginTime();

  /// Update last login timestamp.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateLastLoginTime();
}