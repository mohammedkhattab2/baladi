/// Authentication repository implementation.
///
/// Implements [AuthRepository] with offline-first strategy.
/// Uses local cache for quick access and syncs with remote.
library;

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart' as failures;
import '../../core/result/result.dart';
import '../../domain/entities/user.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/auth_local_data_source.dart';
import '../datasources/remote/auth_remote_data_source.dart';

/// Implementation of [AuthRepository] with offline-first strategy.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<User>> loginWithPin({
    required String mobileNumber,
    required String pin,
  }) async {
    try {
      // Try remote login first
      final userDto = await _remoteDataSource.loginCustomer(
        phoneNumber: mobileNumber,
        pin: pin,
      );

      // Cache user data locally
      await _localDataSource.cacheUser(userDto);
      await _localDataSource.updateLastLoginTime();

      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      // Try offline login with cached PIN
      try {
        final pinHash = _hashPin(pin);
        final isValid = await _localDataSource.verifyPinHash(mobileNumber, pinHash);
        
        if (isValid) {
          final cachedUser = await _localDataSource.getCachedUser();
          if (cachedUser != null && cachedUser.phoneNumber == mobileNumber) {
            return Success(cachedUser.toEntity());
          }
        }
        return Failure(failures.NetworkFailure(message: e.message));
      } catch (_) {
        return Failure(failures.NetworkFailure(message: e.message));
      }
    } on UnauthorizedException catch (e) {
      return Failure(failures.AuthFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> loginWithCredentials({
    required String username,
    required String password,
  }) async {
    try {
      final userDto = await _remoteDataSource.loginWithCredentials(
        username: username,
        password: password,
      );

      await _localDataSource.cacheUser(userDto);
      await _localDataSource.updateLastLoginTime();

      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Failure(failures.AuthFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User>> registerCustomer({
    required String mobileNumber,
    required String pin,
    required String name,
    required String securityAnswer,
  }) async {
    try {
      final userDto = await _remoteDataSource.registerCustomer(
        phoneNumber: mobileNumber,
        pin: pin,
        name: name,
        securityAnswer: securityAnswer,
      );

      await _localDataSource.cacheUser(userDto);
      await _localDataSource.cachePinHash(mobileNumber, _hashPin(pin));
      await _localDataSource.updateLastLoginTime();

      return Success(userDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Failure(failures.ValidationFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> verifySecurityAnswer({
    required String mobileNumber,
    required String securityAnswer,
  }) async {
    try {
      final isValid = await _remoteDataSource.verifySecurityAnswer(
        phoneNumber: mobileNumber,
        answer: securityAnswer,
      );
      return Success(isValid);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPin({
    required String mobileNumber,
    required String newPin,
  }) async {
    try {
      final userDto = await _remoteDataSource.resetPin(
        phoneNumber: mobileNumber,
        newPin: newPin,
      );

      await _localDataSource.cacheUser(userDto);
      await _localDataSource.cachePinHash(mobileNumber, _hashPin(newPin));

      return const Success(null);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> requestPasswordReset({
    required String username,
    required UserRole role,
  }) async {
    try {
      // This is handled by admin - just send the request
      // In actual implementation, this would notify admin
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword({
    required String userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      // Implementation would call remote to change password
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } on UnauthorizedException catch (e) {
      return Failure(failures.AuthFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      // Try remote first for fresh data
      final userDto = await _remoteDataSource.getCurrentUser();
      await _localDataSource.cacheUser(userDto);
      return Success(userDto.toEntity());
    } on NetworkException {
      // Fallback to cache
      try {
        final cachedUser = await _localDataSource.getCachedUser();
        if (cachedUser != null) {
          return Success(cachedUser.toEntity());
        }
        return const Success(null);
      } on CacheException catch (e) {
        return Failure(failures.CacheFailure(message: e.message));
      }
    } on UnauthorizedException catch (e) {
      await _localDataSource.clearAllAuthCache();
      return Failure(failures.AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _remoteDataSource.logout();
      await _localDataSource.clearAllAuthCache();
      return const Success(null);
    } on ServerException catch (e) {
      // Still clear local cache even if remote fails
      await _localDataSource.clearAllAuthCache();
      return Failure(failures.ServerFailure(message: e.message));
    } catch (e) {
      await _localDataSource.clearAllAuthCache();
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<bool>> isSessionValid() async {
    try {
      final isLoggedIn = await _localDataSource.isLoggedIn();
      return Success(isLoggedIn);
    } on CacheException catch (e) {
      return Failure(failures.CacheFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> refreshToken() async {
    try {
      final userDto = await _remoteDataSource.refreshToken();
      await _localDataSource.cacheUser(userDto);
      return const Success(null);
    } on UnauthorizedException catch (e) {
      await _localDataSource.clearAllAuthCache();
      return Failure(failures.AuthFailure(message: e.message));
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> registerDeviceToken({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      // Implementation would register device token with remote
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<void>> unregisterDeviceToken({
    required String userId,
    required String deviceToken,
  }) async {
    try {
      // Implementation would unregister device token from remote
      return const Success(null);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  /// Simple PIN hash function (in production, use proper hashing).
  String _hashPin(String pin) {
    // In production, use bcrypt or similar
    // This is a placeholder for demonstration
    return pin.hashCode.toString();
  }
}