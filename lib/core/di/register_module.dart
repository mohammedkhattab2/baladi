// Core - Injectable module for registering external package dependencies.
//
// External classes that cannot be annotated directly (third-party packages)
// and classes with complex constructor params are registered here.

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/environment.dart';
import '../network/api_client.dart';
import '../services/secure_storage_service.dart';

/// Registers external (third-party) dependencies that cannot be annotated
/// and services with complex constructor parameters (e.g. closures).
@module
abstract class RegisterModule {
  /// HTTP client for network requests.
  @lazySingleton
  http.Client get httpClient => http.Client();

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

  /// API client with auth-token injection and environment configuration.
  ///
  /// Registered via module method because the [authTokenGetter] closure
  /// cannot be auto-resolved by Injectable code generation.
  @lazySingleton
  ApiClient apiClient(
    http.Client httpClient,
    SecureStorageService secureStorage,
  ) =>
      ApiClient(
        baseUrl: EnvironmentConfig.current.apiBaseUrl,
        authTokenGetter: () => secureStorage.getAccessToken(),
        enableLogging: EnvironmentConfig.current.enableLogging,
        httpClient: httpClient,
        timeout: EnvironmentConfig.current.connectTimeout,
      );
}