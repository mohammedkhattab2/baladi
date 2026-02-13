// Data - Auth local datasource.
//
// Abstract interface and implementation for local auth data persistence.
// Uses SecureStorage for tokens and LocalStorage for user metadata.

import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/cache_service.dart';
import '../../../core/services/local_storage_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../domain/enums/user_role.dart';
import '../../models/auth_token_model.dart';
import '../../models/customer_model.dart';
import '../../models/user_model.dart';

/// Local datasource contract for authentication data persistence.
abstract class AuthLocalDatasource {
  /// Saves auth tokens to secure storage.
  Future<void> saveTokens(AuthTokensModel tokens);

  /// Retrieves the stored access token.
  Future<String?> getAccessToken();

  /// Retrieves the stored refresh token.
  Future<String?> getRefreshToken();

  /// Saves user metadata to local storage.
  Future<void> saveUserData(UserModel user);

  /// Saves customer profile to cache.
  Future<void> saveCustomerProfile(CustomerModel customer);

  /// Retrieves cached customer profile.
  Future<CustomerModel?> getCachedCustomerProfile();

  /// Retrieves the stored user role.
  Future<UserRole?> getStoredUserRole();

  /// Returns whether the user is currently authenticated.
  Future<bool> isAuthenticated();

  /// Clears all auth-related data (tokens, user info, cached profile).
  Future<void> clearAuthData();
}

/// Implementation of [AuthLocalDatasource] using secure and local storage.
@LazySingleton(as: AuthLocalDatasource)
class AuthLocalDatasourceImpl implements AuthLocalDatasource {
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;
  final CacheService _cacheService;

  /// Creates an [AuthLocalDatasourceImpl].
  AuthLocalDatasourceImpl({
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
    required CacheService cacheService,
  })  : _secureStorage = secureStorage,
        _localStorage = localStorage,
        _cacheService = cacheService;

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    await _secureStorage.setAccessToken(tokens.accessToken);
    await _secureStorage.setRefreshToken(tokens.refreshToken);
  }

  @override
  Future<String?> getAccessToken() async {
    return _secureStorage.getAccessToken();
  }

  @override
  Future<String?> getRefreshToken() async {
    return _secureStorage.getRefreshToken();
  }

  @override
  Future<void> saveUserData(UserModel user) async {
    await _localStorage.setUserId(user.id);
    await _localStorage.setUserRole(user.role.value);
    await _localStorage.setUserName(user.displayIdentifier);
  }

  @override
  Future<void> saveCustomerProfile(CustomerModel customer) async {
    final jsonString = jsonEncode(customer.toJson());
    await _cacheService.put(
      StorageKeys.userBox,
      'customer_profile',
      jsonString,
    );
  }

  @override
  Future<CustomerModel?> getCachedCustomerProfile() async {
    final jsonString = _cacheService.get(
      StorageKeys.userBox,
      'customer_profile',
    );
    if (jsonString == null) return null;
    final json = jsonDecode(jsonString as String) as Map<String, dynamic>;
    return CustomerModel.fromJson(json);
  }

  @override
  Future<UserRole?> getStoredUserRole() async {
    final roleStr = await _localStorage.getUserRole();
    if (roleStr == null) return null;
    try {
      return UserRole.fromValue(roleStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await _secureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> clearAuthData() async {
    await _secureStorage.clearAuthData();
    await _localStorage.clearUserData();
    await _cacheService.delete(StorageKeys.userBox, 'customer_profile');
  }
}