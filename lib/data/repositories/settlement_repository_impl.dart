// Data - Settlement repository implementation.
//
// Implements the SettlementRepository contract using remote datasource.
// Handles weekly periods, shop settlements, and rider settlements.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/rider_settlement.dart';
import '../../domain/entities/shop_settlement.dart';
import '../../domain/entities/weekly_period.dart';
import '../../domain/repositories/settlement_repository.dart';
import '../datasources/remote/settlement_remote_datasource.dart';

/// Implementation of [SettlementRepository].
@LazySingleton(as: SettlementRepository)
class SettlementRepositoryImpl implements SettlementRepository {
  final SettlementRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [SettlementRepositoryImpl].
  SettlementRepositoryImpl({
    required SettlementRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<List<WeeklyPeriod>>> getWeeklyPeriods({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getWeeklyPeriods(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<WeeklyPeriod>> getCurrentPeriod() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getCurrentPeriod());
  }

  @override
  Future<Result<List<ShopSettlement>>> getShopSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getShopSettlements(
          periodId: periodId,
          page: page,
          perPage: perPage,
        ));
  }

  @override
  Future<Result<List<RiderSettlement>>> getRiderSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getRiderSettlements(
          periodId: periodId,
          page: page,
          perPage: perPage,
        ));
  }

  @override
  Future<Result<ShopSettlement>> getShopSettlementById(
    String settlementId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getShopSettlementById(settlementId),
    );
  }

  @override
  Future<Result<RiderSettlement>> getRiderSettlementById(
    String settlementId,
  ) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getRiderSettlementById(settlementId),
    );
  }
}