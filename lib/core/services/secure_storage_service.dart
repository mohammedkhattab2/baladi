// Core - Wrapper around flutter_secure_storage for sensitive data.
//
// Provides a typed interface for reading/writing secure values like
// JWT tokens and user PINs. All operations are async.

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../constants/storage_keys.dart';

/// Abstraction for secure key-value storage.
///
/// Used for storing sensitive data such as access tokens, refresh tokens,
/// and user PINs. Backed by Keychain on iOS and EncryptedSharedPreferences
/// on Android.
abstract class SecureStorageService {
  /// Reads a value for the given [key]. Returns `null` if not found.
  Future<String?> read(String key);

  /// Writes a [value] for the given [key].
  Future<void> write(String key, String value);

  /// Deletes the value for the given [key].
  Future<void> delete(String key);

  /// Deletes all stored values.
  Future<void> deleteAll();

  // ─── Convenience Accessors ──────────────────────────────────────

  /// Reads the stored access token.
  Future<String?> getAccessToken();

  /// Stores the access token.
  Future<void> setAccessToken(String token);

  /// Reads the stored refresh token.
  Future<String?> getRefreshToken();

  /// Stores the refresh token.
  Future<void> setRefreshToken(String token);

  /// Reads the stored user PIN.
  Future<String?> getUserPin();

  /// Stores the user PIN.
  Future<void> setUserPin(String pin);

  /// Clears all authentication-related secure data.
  Future<void> clearAuthData();
}

/// Implementation of [SecureStorageService] using `flutter_secure_storage`.
@LazySingleton(as: SecureStorageService)
class SecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  /// Creates a [SecureStorageServiceImpl].
  ///
  /// [storage] is injected via the DI container.
  SecureStorageServiceImpl(this._storage);

  @override
  Future<String?> read(String key) async {
    return _storage.read(key: key);
  }

  @override
  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  @override
  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  @override
  Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  // ─── Convenience Accessors ──────────────────────────────────────

  @override
  Future<String?> getAccessToken() => read(StorageKeys.accessToken);

  @override
  Future<void> setAccessToken(String token) =>
      write(StorageKeys.accessToken, token);

  @override
  Future<String?> getRefreshToken() => read(StorageKeys.refreshToken);

  @override
  Future<void> setRefreshToken(String token) =>
      write(StorageKeys.refreshToken, token);

  @override
  Future<String?> getUserPin() => read(StorageKeys.userPin);

  @override
  Future<void> setUserPin(String pin) => write(StorageKeys.userPin, pin);

  @override
  Future<void> clearAuthData() async {
    await delete(StorageKeys.accessToken);
    await delete(StorageKeys.refreshToken);
    await delete(StorageKeys.userPin);
  }
}