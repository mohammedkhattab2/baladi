// Data - Points repository implementation.
//
// Implements the PointsRepository contract using remote datasource.
// Handles points balance retrieval and transaction history.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/points_transaction.dart';
import '../../domain/repositories/points_repository.dart';
import '../datasources/remote/points_remote_datasource.dart';

/// Implementation of [PointsRepository].
@LazySingleton(as: PointsRepository)
class PointsRepositoryImpl implements PointsRepository {
  final PointsRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [PointsRepositoryImpl].
  PointsRepositoryImpl({
    required PointsRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<int>> getPointsBalance() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getPointsBalance());
  }

  @override
  Future<Result<List<PointsTransaction>>> getPointsHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getPointsHistory(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<List<PointsTransaction>>> getPointsHistoryByType({
    required PointsTransactionType type,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getPointsHistoryByType(
        type: type.value,
        page: page,
        perPage: perPage,
      ),
    );
  }
}