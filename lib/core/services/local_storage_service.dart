// Core - Wrapper around SharedPreferences for non-sensitive local data.
//
// Provides a typed interface for reading/writing user preferences
// and app state like user ID, role, FCM token, and locale settings.

import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/storage_keys.dart';

/// Abstraction for non-sensitive key-value local storage.
///
/// Used for storing user preferences, session metadata, and app state.
/// Backed by SharedPreferences on both iOS and Android.
abstract class LocalStorageService {
  /// Reads a string value for the given [key]. Returns `null` if not found.
  Future<String?> getString(String key);

  /// Writes a string [value] for the given [key].
  Future<void> setString(String key, String value);

  /// Reads a bool value for the given [key]. Returns `null` if not found.
  Future<bool?> getBool(String key);

  /// Writes a bool [value] for the given [key].
  Future<void> setBool(String key, bool value);

  /// Reads an int value for the given [key]. Returns `null` if not found.
  Future<int?> getInt(String key);

  /// Writes an int [value] for the given [key].
  Future<void> setInt(String key, int value);

  /// Removes the value for the given [key].
  Future<void> remove(String key);

  /// Removes all stored values.
  Future<void> clear();

  // ─── Convenience Accessors ──────────────────────────────────────

  /// Gets the currently authenticated user's ID.
  Future<String?> getUserId();

  /// Stores the currently authenticated user's ID.
  Future<void> setUserId(String id);

  /// Gets the currently authenticated user's role.
  Future<String?> getUserRole();

  /// Stores the currently authenticated user's role.
  Future<void> setUserRole(String role);

  /// Gets the currently authenticated user's display name.
  Future<String?> getUserName();

  /// Stores the currently authenticated user's display name.
  Future<void> setUserName(String name);

  /// Gets the stored FCM token.
  Future<String?> getFcmToken();

  /// Stores the FCM token.
  Future<void> setFcmToken(String token);

  /// Gets whether this is the first app launch.
  Future<bool> isFirstLaunch();

  /// Marks the first launch as completed.
  Future<void> setFirstLaunchCompleted();

  /// Gets the last background sync timestamp as ISO 8601 string.
  Future<String?> getLastSyncTime();

  /// Stores the last background sync timestamp.
  Future<void> setLastSyncTime(String isoTime);

  /// Gets the user's selected language code.
  Future<String?> getSelectedLanguage();

  /// Stores the user's selected language code.
  Future<void> setSelectedLanguage(String languageCode);

  /// Clears all user-related session data (for logout).
  Future<void> clearUserData();
}

/// Implementation of [LocalStorageService] using `SharedPreferences`.
@LazySingleton(as: LocalStorageService)
class LocalStorageServiceImpl implements LocalStorageService {
  final SharedPreferencesAsync _prefs;

  /// Creates a [LocalStorageServiceImpl].
  ///
  /// [prefs] is injected via the DI container.
  LocalStorageServiceImpl(this._prefs);

  @override
  Future<String?> getString(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<bool?> getBool(String key) async {
    return _prefs.getBool(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  @override
  Future<int?> getInt(String key) async {
    return _prefs.getInt(key);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    await _prefs.clear();
  }

  // ─── Convenience Accessors ──────────────────────────────────────

  @override
  Future<String?> getUserId() => getString(StorageKeys.userId);

  @override
  Future<void> setUserId(String id) => setString(StorageKeys.userId, id);

  @override
  Future<String?> getUserRole() => getString(StorageKeys.userRole);

  @override
  Future<void> setUserRole(String role) => setString(StorageKeys.userRole, role);

  @override
  Future<String?> getUserName() => getString(StorageKeys.userName);

  @override
  Future<void> setUserName(String name) => setString(StorageKeys.userName, name);

  @override
  Future<String?> getFcmToken() => getString(StorageKeys.fcmToken);

  @override
  Future<void> setFcmToken(String token) =>
      setString(StorageKeys.fcmToken, token);

  @override
  Future<bool> isFirstLaunch() async {
    final value = await getBool(StorageKeys.isFirstLaunch);
    return value ?? true; // Default: true (is first launch)
  }

  @override
  Future<void> setFirstLaunchCompleted() =>
      setBool(StorageKeys.isFirstLaunch, false);

  @override
  Future<String?> getLastSyncTime() => getString(StorageKeys.lastSyncTime);

  @override
  Future<void> setLastSyncTime(String isoTime) =>
      setString(StorageKeys.lastSyncTime, isoTime);

  @override
  Future<String?> getSelectedLanguage() =>
      getString(StorageKeys.selectedLanguage);

  @override
  Future<void> setSelectedLanguage(String languageCode) =>
      setString(StorageKeys.selectedLanguage, languageCode);

  @override
  Future<void> clearUserData() async {
    await remove(StorageKeys.userId);
    await remove(StorageKeys.userRole);
    await remove(StorageKeys.userName);
    await remove(StorageKeys.lastSyncTime);
  }
}