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
    // Backend admin /periods endpoint only supports "page" and may return either:
    // - a raw JSON array: [ {..}, {..} ]
    // - a wrapped object with items/data: { items: [..] } or { data: [..] }
    //
    // We must NOT use ApiClient.get<T> here because it always expects a
    // Map<String, dynamic> body. When the backend returns a List, that cast
    // causes: "type 'List<dynamic>' is not a subtype of type 'Map<String, dynamic>'".
    //
    // So we go directly through Dio with a flexible dynamic body and then parse.
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminPeriods,
      queryParameters: {
        'page': page.toString(),
      },
    );

    final data = response.data;
    return _parseList(data, WeeklyPeriodModel.fromJson);
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
    // Similar to periods, /admin/settlements can respond with either a raw list
    // or a wrapped object. Use Dio directly to avoid forcing Map<String, dynamic>.
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminSettlements,
      queryParameters: {
        'period_id': periodId,
        'type': 'shop',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final data = response.data;
    return _parseList(data, ShopSettlementModel.fromJson);
  }

  @override
  Future<List<RiderSettlementModel>> getRiderSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminSettlements,
      queryParameters: {
        'period_id': periodId,
        'type': 'rider',
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
    );

    final data = response.data;
    return _parseList(data, RiderSettlementModel.fromJson);
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

  /// Parses a list of items from API list responses.
  ///
  /// Supports:
  /// - Direct list: [ {..}, {..} ]
  /// - Wrapped with "items": { items: [..] }
  /// - Wrapped with "data"/feature key: { data: [..] } or { periods: [..], settlements: [..] }
  static List<T> _parseList<T>(
    dynamic json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    // Direct list response
    if (json is List) {
      return json
          .whereType<Map<String, dynamic>>()
          .map(fromJson)
          .toList();
    }

    if (json is Map<String, dynamic>) {
      // Prefer explicit items/data keys when present
      final List<dynamic>? raw =
          json['items'] as List<dynamic>? ??
          json['data'] as List<dynamic>? ??
          json['periods'] as List<dynamic>? ??
          json['settlements'] as List<dynamic>?;

      if (raw != null) {
        return raw
            .whereType<Map<String, dynamic>>()
            .map(fromJson)
            .toList();
      }
    }

    // Unknown shape
    return <T>[];
  }
}