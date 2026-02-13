// Data - Admin remote datasource.
//
// Abstract interface and implementation for admin-related API calls.
// Handles dashboard, user management, period closing, settlements,
// and points adjustments.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/order_model.dart';
import '../../models/rider_model.dart';
import '../../models/shop_model.dart';
import '../../models/user_model.dart';
import '../../models/weekly_period_model.dart';

/// Remote datasource contract for admin operations.
abstract class AdminRemoteDatasource {
  /// Fetches the admin dashboard with aggregated statistics.
  Future<Map<String, dynamic>> getAdminDashboard();

  /// Fetches all users with optional role filter.
  Future<List<UserModel>> getUsers({
    String? role,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches all registered shops.
  Future<List<ShopModel>> getShops({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches all registered riders.
  Future<List<RiderModel>> getRiders({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches all orders (admin view).
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches weekly periods.
  Future<List<WeeklyPeriodModel>> getPeriods({
    int page = 1,
    int perPage = 20,
  });

  /// Closes the current active weekly period.
  Future<WeeklyPeriodModel> closeCurrentPeriod();

  /// Adjusts a customer's points balance.
  Future<void> adjustPoints({
    required String customerId,
    required int points,
    required String reason,
  });

  /// Toggles a user's active status.
  Future<UserModel> toggleUserStatus({
    required String userId,
    required bool isActive,
  });
}

/// Implementation of [AdminRemoteDatasource] using [ApiClient].
@LazySingleton(as: AdminRemoteDatasource)
class AdminRemoteDatasourceImpl implements AdminRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates an [AdminRemoteDatasourceImpl].
  AdminRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> getAdminDashboard() async {
    final response = await _apiClient.get(
      ApiEndpoints.adminDashboard,
      fromJson: (json) => json,
    );
    return response.data!;
  }

  @override
  Future<List<UserModel>> getUsers({
    String? role,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<UserModel>>(
      ApiEndpoints.adminUsers,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (role != null) 'role': role,
      },
      fromJson: (json) => _parseList(json, UserModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<ShopModel>> getShops({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<ShopModel>>(
      ApiEndpoints.adminShops,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, ShopModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<RiderModel>> getRiders({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<RiderModel>>(
      ApiEndpoints.adminRiders,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, RiderModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<OrderModel>>(
      ApiEndpoints.adminOrders,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null) 'status': status,
      },
      fromJson: (json) => _parseList(json, OrderModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<List<WeeklyPeriodModel>> getPeriods({
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
  Future<WeeklyPeriodModel> closeCurrentPeriod() async {
    final response = await _apiClient.post(
      ApiEndpoints.adminPeriodsClose,
      fromJson: (json) => WeeklyPeriodModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<void> adjustPoints({
    required String customerId,
    required int points,
    required String reason,
  }) async {
    await _apiClient.post(
      ApiEndpoints.adminPointsAdjust,
      body: {
        'customer_id': customerId,
        'points': points,
        'reason': reason,
      },
    );
  }

  @override
  Future<UserModel> toggleUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    final response = await _apiClient.put(
      '${ApiEndpoints.adminUsers}/$userId',
      body: {'is_active': isActive},
      fromJson: (json) => UserModel.fromJson(json),
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