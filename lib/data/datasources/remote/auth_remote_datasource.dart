// Data - Auth remote datasource.
//
// Abstract interface and implementation for authentication API calls.
// Handles customer registration/login, staff login, token refresh,
// logout, and FCM token updates.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/auth_token_model.dart';

/// Remote datasource contract for authentication operations.
abstract class AuthRemoteDatasource {
  /// Registers a new customer with phone, PIN, name, and security Q&A.
  Future<AuthResultModel> registerCustomer({
    required String phone,
    required String pin,
    required String fullName,
    String? referralCode,
    required String securityQuestion,
    required String securityAnswer,
  });

  /// Logs in a customer with phone and PIN.
  Future<AuthResultModel> loginCustomer({
    required String phone,
    required String pin,
  });

  /// Recovers a customer's PIN via phone.
  Future<void> recoverCustomerPin({required String phone});

  /// Logs in a staff user (shop/rider/admin) with username and password.
  Future<AuthResultModel> loginUser({
    required String username,
    required String password,
    required String role,
  });

  /// Refreshes the access token using a refresh token.
  Future<AuthTokensModel> refreshToken(String refreshToken);

  /// Logs out and invalidates the refresh token.
  Future<void> logout(String refreshToken);

  /// Updates the device FCM token on the server.
  Future<void> updateFcmToken(String fcmToken);

  /// Returns the security question for the given phone number.
  Future<String> getSecurityQuestion({required String phone});

  /// Verifies security answer and resets the PIN.
  Future<void> resetPin({
    required String phone,
    required String securityAnswer,
    required String newPin,
  });
}

/// Implementation of [AuthRemoteDatasource] using [ApiClient].
@LazySingleton(as: AuthRemoteDatasource)
class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates an [AuthRemoteDatasourceImpl].
  AuthRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<AuthResultModel> registerCustomer({
    required String phone,
    required String pin,
    required String fullName,
    String? referralCode,
    required String securityQuestion,
    required String securityAnswer,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerRegister,
      body: {
        'phone': phone,
        'pin': pin,
        'full_name': fullName,
        if (referralCode != null) 'referral_code': referralCode,
        'security_question': securityQuestion,
        'security_answer': securityAnswer,
      },
      fromJson: (json) => AuthResultModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<AuthResultModel> loginCustomer({
    required String phone,
    required String pin,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.customerLogin,
      body: {
        'phone': phone,
        'pin': pin,
      },
      fromJson: (json) => AuthResultModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<void> recoverCustomerPin({required String phone}) async {
    await _apiClient.post(
      ApiEndpoints.customerRecover,
      body: {'phone': phone},
    );
  }

  @override
  Future<AuthResultModel> loginUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      body: {
        'username': username,
        'password': password,
        'role': role,
      },
      fromJson: (json) => AuthResultModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final response = await _apiClient.post(
      ApiEndpoints.refresh,
      body: {'refresh_token': refreshToken},
      fromJson: (json) => AuthTokensModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<void> logout(String refreshToken) async {
    await _apiClient.post(
      ApiEndpoints.logout,
      body: {'refresh_token': refreshToken},
    );
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await _apiClient.put(
      ApiEndpoints.updateFcmToken,
      body: {'fcm_token': fcmToken},
    );
  }

  @override
  Future<String> getSecurityQuestion({required String phone}) async {
    final response = await _apiClient.post(
      ApiEndpoints.securityQuestion,
      body: {'phone': phone},
      fromJson: (json) => json['security_question'] as String,
    );
    return response.data!;
  }

  @override
  Future<void> resetPin({
    required String phone,
    required String securityAnswer,
    required String newPin,
  }) async {
    await _apiClient.post(
      ApiEndpoints.resetPin,
      body: {
        'phone': phone,
        'security_answer': securityAnswer,
        'new_pin': newPin,
      },
    );
  }
}