// Data - Settlement remote datasource.
//
// Abstract interface and implementation for settlement-related API calls.
// Handles weekly periods, shop settlements, and rider settlements.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/rider_settlement_model.dart';
import '../../models/shop_settlement_model.dart';
import '../../models/weekly_period_model.dart';

/// Remote datasource contract for settlement operations.
abstract class SettlementRemoteDatasource {
  /// Fetches all weekly periods.
  Future<List<WeeklyPeriodModel>> getWeeklyPeriods({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches the current active weekly period.
  Future<WeeklyPeriodModel> getCurrentPeriod();

  /// Fetches shop settlements for a specific period.
  Future<List<ShopSettlementModel>> getShopSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches rider settlements for a specific period.
  Future<List<RiderSettlementModel>> getRiderSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches a single shop settlement by ID.
  Future<ShopSettlementModel> getShopSettlementById(String settlementId);

  /// Fetches a single rider settlement by ID.
  Future<RiderSettlementModel> getRiderSettlementById(String settlementId);
}

/// Implementation of [SettlementRemoteDatasource] using [ApiClient].
@LazySingleton(as: SettlementRemoteDatasource)
class SettlementRemoteDatasourceImpl implements SettlementRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [SettlementRemoteDatasourceImpl].
  SettlementRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<WeeklyPeriodModel>> getWeeklyPeriods({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<WeeklyPeriodModel>>(
      ApiEndpoints.adminPeriods,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, WeeklyPeriodModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<WeeklyPeriodModel> getCurrentPeriod() async {
    final response = await _apiClient.get(
      '${ApiEndpoints.adminPeriods}/current',
      fromJson: (json) => WeeklyPeriodModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<List<ShopSettlementModel>> getShopSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<ShopSettlementModel>>(
      ApiEndpoints.adminSettlements,
      queryParameters: {
        'period_id': periodId,
        'type': 'shop',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, ShopSettlementModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<RiderSettlementModel>> getRiderSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<RiderSettlementModel>>(
      ApiEndpoints.adminSettlements,
      queryParameters: {
        'period_id': periodId,
        'type': 'rider',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, RiderSettlementModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<ShopSettlementModel> getShopSettlementById(
    String settlementId,
  ) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.adminSettlements}/$settlementId',
      fromJson: (json) => ShopSettlementModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<RiderSettlementModel> getRiderSettlementById(
    String settlementId,
  ) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.adminSettlements}/$settlementId',
      fromJson: (json) => RiderSettlementModel.fromJson(json),
    );
    return response.data!;
  }

  /// Parses a list of items from the standard API list response format.
  static List<T> _parseList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}