// Data - Rider repository implementation.
//
// Implements the RiderRepository contract using remote datasource.
// Handles rider profile, availability, orders, dashboard, earnings,
// and settlements.

import 'package:injectable/injectable.dart' hide Order;

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/rider.dart';
import '../../domain/entities/rider_settlement.dart';
import '../../domain/repositories/rider_repository.dart';
import '../datasources/remote/rider_remote_datasource.dart';

/// Implementation of [RiderRepository].
@LazySingleton(as: RiderRepository)
class RiderRepositoryImpl implements RiderRepository {
  final RiderRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [RiderRepositoryImpl].
  RiderRepositoryImpl({
    required RiderRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<Rider>> getRiderProfile() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getRiderProfile());
  }

  @override
  Future<Result<Rider>> updateAvailability({required bool isAvailable}) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.updateAvailability(isAvailable: isAvailable),
    );
  }

  @override
  Future<Result<List<Order>>> getAvailableOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getAvailableOrders(
        page: page,
        perPage: perPage,
      ),
    );
  }

  @override
  Future<Result<List<Order>>> getRiderOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getRiderOrders(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<RiderDashboard>> getRiderDashboard() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final json = await _remoteDatasource.getRiderDashboard();
      return RiderDashboard(
        totalDeliveries: json['total_deliveries'] as int? ?? 0,
        totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
        totalCashHandled:
            (json['total_cash_handled'] as num?)?.toDouble() ?? 0,
        availableOrdersCount: json['available_orders_count'] as int? ?? 0,
      );
    });
  }

  @override
  Future<Result<double>> getTotalEarnings() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getTotalEarnings());
  }

  @override
  Future<Result<List<RiderSettlement>>> getSettlements({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getSettlements(page: page, perPage: perPage),
    );
  }
}