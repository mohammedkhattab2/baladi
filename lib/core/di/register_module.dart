// Core - Injectable module for registering external package dependencies.
//
// External classes that cannot be annotated directly (third-party packages)
// and classes with complex constructor params are registered here.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment.dart';
import '../network/api_client.dart';
import '../services/secure_storage_service.dart';

/// Registers external (third-party) dependencies that cannot be annotated
/// and services with complex constructor parameters (e.g. closures).
@module
abstract class RegisterModule {
  /// Connectivity checker from connectivity_plus.
  @lazySingleton
  Connectivity get connectivity => Connectivity();

  /// Firebase Cloud Messaging instance.
  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  /// Secure storage with platform-specific options.
  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions:
            IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      );

  /// SharedPreferences async instance.
  @lazySingleton
  SharedPreferencesAsync get sharedPreferencesAsync =>
      SharedPreferencesAsync();

  /// API client (Dio-based) with auth-token injection and environment configuration.
  ///
  /// Registered via module method because the [authTokenGetter] closure
  /// cannot be auto-resolved by Injectable code generation.
  ///
  /// The [tokenRefresher] uses a **separate Dio instance** to call the
  /// `/auth/refresh` endpoint, avoiding interceptor recursion on the
  /// main ApiClient's auth interceptor.
  @lazySingleton
  ApiClient apiClient(
    SecureStorageService secureStorage,
  ) =>
      ApiClient(
        baseUrl: EnvironmentConfig.current.apiBaseUrl,
        authTokenGetter: () => secureStorage.getAccessToken(),
        tokenRefresher: () async {
          final refreshToken = await secureStorage.getRefreshToken();
          if (refreshToken == null || refreshToken.isEmpty) return null;

          try {
            // Dedicated Dio instance — bypasses the main client's
            // auth interceptor to prevent infinite 401 loops.
            final refreshDio = Dio(BaseOptions(
              baseUrl: EnvironmentConfig.current.apiBaseUrl,
              connectTimeout: EnvironmentConfig.current.connectTimeout,
              receiveTimeout: EnvironmentConfig.current.connectTimeout,
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

            final response = await refreshDio.post<Map<String, dynamic>>(
              '/auth/refresh',
              data: {'refresh_token': refreshToken},
            );

            final json = response.data;
            if (json == null) return null;

            // Backend wraps in { success, data: { access_token, refresh_token } }
            final data = json['data'] as Map<String, dynamic>?;
            if (data == null) return null;

            final newAccessToken = data['access_token'] as String?;
            final newRefreshToken = data['refresh_token'] as String?;

            if (newAccessToken != null && newRefreshToken != null) {
              await secureStorage.setAccessToken(newAccessToken);
              await secureStorage.setRefreshToken(newRefreshToken);
              return newAccessToken;
            }
            return null;
          } catch (_) {
            // Refresh failed — interceptor will call onTokenExpired
            return null;
          }
        },
        enableLogging: EnvironmentConfig.current.enableLogging,
        connectTimeout: EnvironmentConfig.current.connectTimeout,
        receiveTimeout: EnvironmentConfig.current.connectTimeout,
      );
}