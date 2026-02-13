// Data - Auth repository implementation.
//
// Implements the AuthRepository contract using remote and local datasources.
// Handles token persistence, user metadata caching, and token refresh logic.

import 'package:injectable/injectable.dart';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/auth_token_model.dart';
import '../models/customer_model.dart';
import '../models/user_model.dart';

/// Implementation of [AuthRepository].
@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  /// Creates an [AuthRepositoryImpl].
  AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<AuthResult>> registerCustomer({
    required String phone,
    required String pin,
    required String fullName,
    String? referralCode,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final result = await _remoteDatasource.registerCustomer(
        phone: phone,
        pin: pin,
        fullName: fullName,
        referralCode: referralCode,
      );
      await _persistAuthResult(result);
      return result;
    });
  }

  @override
  Future<Result<AuthResult>> loginCustomer({
    required String phone,
    required String pin,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final result = await _remoteDatasource.loginCustomer(
        phone: phone,
        pin: pin,
      );
      await _persistAuthResult(result);
      return result;
    });
  }

  @override
  Future<Result<void>> recoverCustomerPin({required String phone}) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      await _remoteDatasource.recoverCustomerPin(phone: phone);
    });
  }

  @override
  Future<Result<AuthResult>> loginUser({
    required String username,
    required String password,
    required UserRole role,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final result = await _remoteDatasource.loginUser(
        username: username,
        password: password,
        role: role.value,
      );
      await _persistAuthResult(result);
      return result;
    });
  }

  @override
  Future<Result<AuthTokens>> refreshToken() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final currentRefreshToken = await _localDatasource.getRefreshToken();
      if (currentRefreshToken == null) {
        throw const AuthException(message: 'لا يوجد رمز تحديث');
      }
      final tokens = await _remoteDatasource.refreshToken(currentRefreshToken);
      await _localDatasource.saveTokens(tokens);
      return tokens;
    });
  }

  @override
  Future<Result<void>> logout() async {
    try {
      if (await _networkInfo.isConnected) {
        final currentRefreshToken = await _localDatasource.getRefreshToken();
        if (currentRefreshToken != null) {
          await _remoteDatasource.logout(currentRefreshToken);
        }
      }
    } catch (_) {
      // Ignore remote logout errors — always clear local data.
    }
    await _localDatasource.clearAuthData();
    return const Success(null);
  }

  @override
  Future<Result<void>> updateFcmToken(String fcmToken) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      await _remoteDatasource.updateFcmToken(fcmToken);
    });
  }

  @override
  Future<String?> getAccessToken() => _localDatasource.getAccessToken();

  @override
  Future<String?> getRefreshToken() => _localDatasource.getRefreshToken();

  @override
  Future<void> saveTokens(AuthTokens tokens) async {
    await _localDatasource.saveTokens(
      AuthTokensModel.fromEntity(tokens),
    );
  }

  @override
  Future<void> clearAuthData() => _localDatasource.clearAuthData();

  @override
  Future<bool> isAuthenticated() => _localDatasource.isAuthenticated();

  @override
  Future<UserRole?> getStoredUserRole() =>
      _localDatasource.getStoredUserRole();

  /// Persists tokens, user metadata, and optional customer profile locally.
  Future<void> _persistAuthResult(AuthResult result) async {
    await _localDatasource.saveTokens(
      AuthTokensModel.fromEntity(result.tokens),
    );
    await _localDatasource.saveUserData(
      UserModel.fromEntity(result.user),
    );
    if (result.customer != null) {
      await _localDatasource.saveCustomerProfile(
        CustomerModel.fromEntity(result.customer!),
      );
    }
  }
}