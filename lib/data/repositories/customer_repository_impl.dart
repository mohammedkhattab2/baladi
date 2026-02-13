// Data - Customer repository implementation.
//
// Implements the CustomerRepository contract using remote and local datasources.
// Supports offline-first profile caching.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/customer.dart';
import '../../domain/repositories/customer_repository.dart';
import '../datasources/local/auth_local_datasource.dart';
import '../datasources/remote/customer_remote_datasource.dart';
import '../models/customer_model.dart';

/// Implementation of [CustomerRepository].
@LazySingleton(as: CustomerRepository)
class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [CustomerRepositoryImpl].
  CustomerRepositoryImpl({
    required CustomerRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<Customer>> getProfile() async {
    if (!await _networkInfo.isConnected) {
      final cached = await _localDatasource.getCachedCustomerProfile();
      if (cached != null) return Success(cached);
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final profile = await _remoteDatasource.getProfile();
      await _localDatasource.saveCustomerProfile(profile);
      return profile;
    });
  }

  @override
  Future<Result<Customer>> updateProfile({String? fullName}) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final profile = await _remoteDatasource.updateProfile(
        fullName: fullName,
      );
      await _localDatasource.saveCustomerProfile(profile);
      return profile;
    });
  }

  @override
  Future<Result<Customer>> updateAddress({
    required String addressText,
    String? landmark,
    String? area,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final profile = await _remoteDatasource.updateAddress(
        addressText: addressText,
        landmark: landmark,
        area: area,
      );
      await _localDatasource.saveCustomerProfile(profile);
      return profile;
    });
  }

  @override
  Future<Result<void>> applyReferralCode(String referralCode) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      await _remoteDatasource.applyReferralCode(referralCode);
    });
  }

  @override
  Future<Result<String>> getReferralCode() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      return _remoteDatasource.getReferralCode();
    });
  }

  @override
  Future<Customer?> getCachedProfile() =>
      _localDatasource.getCachedCustomerProfile();

  @override
  Future<void> cacheProfile(Customer customer) async {
    await _localDatasource.saveCustomerProfile(
      CustomerModel.fromEntity(customer),
    );
  }

  @override
  Future<void> clearCache() async {
    await _localDatasource.clearAuthData();
  }
}