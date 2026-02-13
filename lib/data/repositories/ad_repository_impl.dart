// Data - Ad repository implementation.
//
// Implements the AdRepository contract using remote datasource.
// Handles fetching active ads, shop ads, and creating new ads.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/ad.dart';
import '../../domain/repositories/ad_repository.dart';
import '../datasources/remote/ad_remote_datasource.dart';

/// Implementation of [AdRepository].
@LazySingleton(as: AdRepository)
class AdRepositoryImpl implements AdRepository {
  final AdRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  /// Creates an [AdRepositoryImpl].
  AdRepositoryImpl({
    required AdRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<List<Ad>>> getActiveAds() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getActiveAds());
  }

  @override
  Future<Result<List<Ad>>> getShopAds({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getShopAds(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<Ad>> createAd({
    required String title,
    String? titleAr,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.createAd(
          title: title,
          titleAr: titleAr,
          description: description,
          imageUrl: imageUrl,
          startDate: startDate,
          endDate: endDate,
        ));
  }

  @override
  Future<Result<Ad>> getAdById(String adId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getAdById(adId));
  }
}