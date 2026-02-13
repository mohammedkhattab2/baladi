// Data - Rider remote datasource.
//
// Abstract interface and implementation for rider-related API calls.
// Handles rider profile, availability, orders, dashboard, earnings,
// and settlements.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/order_model.dart';
import '../../models/rider_model.dart';
import '../../models/rider_settlement_model.dart';

/// Remote datasource contract for rider operations.
abstract class RiderRemoteDatasource {
  /// Fetches the current rider's profile.
  Future<RiderModel> getRiderProfile();

  /// Updates the rider's availability status.
  Future<RiderModel> updateAvailability({required bool isAvailable});

  /// Fetches orders available for pickup.
  Future<List<OrderModel>> getAvailableOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches the rider's assigned/completed orders.
  Future<List<OrderModel>> getRiderOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches the rider's dashboard statistics.
  Future<Map<String, dynamic>> getRiderDashboard();

  /// Fetches the rider's total earnings.
  Future<double> getTotalEarnings();

  /// Fetches the rider's settlement history.
  Future<List<RiderSettlementModel>> getSettlements({
    int page = 1,
    int perPage = 20,
  });
}

/// Implementation of [RiderRemoteDatasource] using [ApiClient].
@LazySingleton(as: RiderRemoteDatasource)
class RiderRemoteDatasourceImpl implements RiderRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [RiderRemoteDatasourceImpl].
  RiderRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<RiderModel> getRiderProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.riderProfile,
      fromJson: (json) => RiderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<RiderModel> updateAvailability({required bool isAvailable}) async {
    final response = await _apiClient.put(
      ApiEndpoints.riderStatus,
      body: {'is_available': isAvailable},
      fromJson: (json) => RiderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<List<OrderModel>> getAvailableOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<OrderModel>>(
      ApiEndpoints.riderAvailableOrders,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, OrderModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<OrderModel>> getRiderOrders({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<OrderModel>>(
      ApiEndpoints.riderOrders,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, OrderModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<Map<String, dynamic>> getRiderDashboard() async {
    final response = await _apiClient.get(
      ApiEndpoints.riderDashboard,
      fromJson: (json) => json,
    );
    return response.data!;
  }

  @override
  Future<double> getTotalEarnings() async {
    final response = await _apiClient.get(
      ApiEndpoints.riderEarnings,
      fromJson: (json) => (json['total_earnings'] as num).toDouble(),
    );
    return response.data!;
  }

  @override
  Future<List<RiderSettlementModel>> getSettlements({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<RiderSettlementModel>>(
      ApiEndpoints.riderSettlements,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, RiderSettlementModel.fromJson),
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