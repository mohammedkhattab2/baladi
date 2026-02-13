// Data - Points remote datasource.
//
// Abstract interface and implementation for loyalty points API calls.
// Handles balance retrieval and transaction history.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/points_transaction_model.dart';

/// Remote datasource contract for loyalty points operations.
abstract class PointsRemoteDatasource {
  /// Fetches the current customer's total points balance.
  Future<int> getPointsBalance();

  /// Fetches the customer's points transaction history.
  Future<List<PointsTransactionModel>> getPointsHistory({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches points transactions filtered by type.
  Future<List<PointsTransactionModel>> getPointsHistoryByType({
    required String type,
    int page = 1,
    int perPage = 20,
  });
}

/// Implementation of [PointsRemoteDatasource] using [ApiClient].
@LazySingleton(as: PointsRemoteDatasource)
class PointsRemoteDatasourceImpl implements PointsRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [PointsRemoteDatasourceImpl].
  PointsRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<int> getPointsBalance() async {
    final response = await _apiClient.get(
      ApiEndpoints.customerPoints,
      fromJson: (json) => json['balance'] as int,
    );
    return response.data ?? 0;
  }

  @override
  Future<List<PointsTransactionModel>> getPointsHistory({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<PointsTransactionModel>>(
      ApiEndpoints.customerPointsHistory,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, PointsTransactionModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<PointsTransactionModel>> getPointsHistoryByType({
    required String type,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<PointsTransactionModel>>(
      ApiEndpoints.customerPointsHistory,
      queryParameters: {
        'type': type,
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, PointsTransactionModel.fromJson),
    );
    return response.data ?? [];
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