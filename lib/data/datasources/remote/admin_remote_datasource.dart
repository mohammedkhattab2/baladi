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

  /// Creates a new shop (with associated user) from the admin panel.
  ///
  /// Backend:
  ///   POST /api/admin/shops
  ///   Body contains both shop profile and owner user data.
  Future<ShopModel> createShopAsAdmin({
    required Map<String, dynamic> body,
  });

  /// Updates an existing shop (and optionally its owner user) from admin.
  ///
  /// Backend:
  ///   PUT /api/admin/shops/:shopId
  Future<ShopModel> updateShopAsAdmin({
    required String shopId,
    required Map<String, dynamic> body,
  });

  /// Fetches all registered riders.
  Future<List<RiderModel>> getRiders({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new rider (with associated user) from the admin panel.
  ///
  /// Backend:
  ///   POST /api/admin/riders
  ///   Body contains both rider profile and user account data.
  Future<RiderModel> createRiderAsAdmin({
    required Map<String, dynamic> body,
  });

  /// Updates an existing rider (and optionally its user) from admin.
  ///
  /// Backend:
  ///   PUT /api/admin/riders/:riderId
  Future<RiderModel> updateRiderAsAdmin({
    required String riderId,
    required Map<String, dynamic> body,
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

  /// Resets a staff user's password (shop / rider / admin).
  ///
  /// Backend endpoint:
  ///   POST /api/admin/users/:userId/reset-password
  ///   { "new_password": "..." }
  Future<void> resetUserPassword({
    required String userId,
    required String newPassword,
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
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminUsers,
      queryParameters: {
        if (role != null) 'role': role,
      },
    );
    final data = response.data;

    // Handle direct list response
    if (data is List) {
      return data
          .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle wrapped response (Map)
    if (data is Map<String, dynamic>) {
      // Try different possible field names
      final List<dynamic>? usersList =
          data['data'] as List<dynamic>? ??
          data['users'] as List<dynamic>? ??
          data['items'] as List<dynamic>?;

      if (usersList != null) {
        return usersList
            .map((item) => UserModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    // Fallback to empty list if response format is not recognized
    return [];
  }

  @override
  Future<List<ShopModel>> getShops({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminShops,
      // Backend does not accept "per_page" as a query param, so we only send page.
      queryParameters: {
        'page': page,
      },
    );
    final data = response.data;

    // Handle direct list response
    if (data is List) {
      return data
          .map((item) => ShopModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle wrapped response: { success, data: [...], meta: {...} }
    if (data is Map<String, dynamic>) {
      final List<dynamic>? shopsList =
          data['data'] as List<dynamic>? ??
          data['shops'] as List<dynamic>? ??
          data['items'] as List<dynamic>?;

      if (shopsList != null) {
        return shopsList
            .map((item) => ShopModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<ShopModel> createShopAsAdmin({
    required Map<String, dynamic> body,
  }) async {
    // Backend route:
    //   POST /api/admin/shops
    //   Body includes both shop and owner user data.
    final response = await _apiClient.post(
      ApiEndpoints.adminShops,
      body: body,
      fromJson: (json) {
        // Support both wrapped and direct shop JSON:
        // { success, data: { shop: {...} } }
        final data = json['data'] as Map<String, dynamic>?;
        final shopJson =
            data?['shop'] as Map<String, dynamic>? ?? data ?? json;
        return ShopModel.fromJson(shopJson);
      },
    );
    return response.data!;
  }

  @override
  Future<ShopModel> updateShopAsAdmin({
    required String shopId,
    required Map<String, dynamic> body,
  }) async {
    // Backend route:
    //   PUT /api/admin/shops/:shopId
    final response = await _apiClient.put(
      '${ApiEndpoints.adminShops}/$shopId',
      body: body,
      fromJson: (json) {
        final data = json['data'] as Map<String, dynamic>?;
        final shopJson =
            data?['shop'] as Map<String, dynamic>? ?? data ?? json;
        return ShopModel.fromJson(shopJson);
      },
    );
    return response.data!;
  }

  @override
  Future<List<RiderModel>> getRiders({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminRiders,
      queryParameters: {
        'page': page,
      },
    );
    final data = response.data;

    // Handle direct list response
    if (data is List) {
      return data
          .map((item) => RiderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle wrapped response: { success, data: [...], meta: {...} }
    if (data is Map<String, dynamic>) {
      final List<dynamic>? ridersList =
          data['data'] as List<dynamic>? ??
          data['riders'] as List<dynamic>? ??
          data['items'] as List<dynamic>?;

      if (ridersList != null) {
        return ridersList
            .map((item) => RiderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<RiderModel> createRiderAsAdmin({
    required Map<String, dynamic> body,
  }) async {
    // Backend route:
    //   POST /api/admin/riders
    //   Body includes both rider and user account data.
    final response = await _apiClient.post(
      ApiEndpoints.adminRiders,
      body: body,
      fromJson: (json) {
        // Support both wrapped and direct rider JSON:
        // { success, data: { rider: {...} } }
        final data = json['data'] as Map<String, dynamic>?;
        final riderJson =
            data?['rider'] as Map<String, dynamic>? ?? data ?? json;
        return RiderModel.fromJson(riderJson);
      },
    );
    return response.data!;
  }

  @override
  Future<RiderModel> updateRiderAsAdmin({
    required String riderId,
    required Map<String, dynamic> body,
  }) async {
    // Backend route:
    //   PUT /api/admin/riders/:riderId
    final response = await _apiClient.put(
      '${ApiEndpoints.adminRiders}/$riderId',
      body: body,
      fromJson: (json) {
        final data = json['data'] as Map<String, dynamic>?;
        final riderJson =
            data?['rider'] as Map<String, dynamic>? ?? data ?? json;
        return RiderModel.fromJson(riderJson);
      },
    );
    return response.data!;
  }

  @override
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminOrders,
      // Backend accepts page (and optionally status), but list is wrapped:
      // { success: true, data: [...], meta: {...} }
      queryParameters: {
        'page': page,
        if (status != null) 'status': status,
      },
    );
    final data = response.data;

    // Handle direct list response
    if (data is List) {
      return data
          .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle wrapped response: { success, data: [...], meta: {...} }
    if (data is Map<String, dynamic>) {
      final List<dynamic>? ordersList =
          data['data'] as List<dynamic>? ??
          data['orders'] as List<dynamic>? ??
          data['items'] as List<dynamic>?;

      if (ordersList != null) {
        return ordersList
            .map((item) => OrderModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
  }

  @override
  Future<List<WeeklyPeriodModel>> getPeriods({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.dio.get(
      ApiEndpoints.adminPeriods,
      // Backend returns a wrapped response:
      // { success: true, data: [...], meta: {...} }
      queryParameters: {
        'page': page,
      },
    );
    final data = response.data;

    // Handle direct list response
    if (data is List) {
      return data
          .map((item) => WeeklyPeriodModel.fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Handle wrapped response: { success, data: [...], meta: {...} }
    if (data is Map<String, dynamic>) {
      final List<dynamic>? periodsList =
          data['data'] as List<dynamic>? ??
          data['periods'] as List<dynamic>? ??
          data['items'] as List<dynamic>?;

      if (periodsList != null) {
        return periodsList
            .map((item) => WeeklyPeriodModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }

    return [];
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
    // Backend route:
    //   PUT /api/admin/users/:userId/activate
    //   { "is_active": true/false }
    final response = await _apiClient.put(
      '${ApiEndpoints.adminUsers}/$userId/activate',
      body: {'is_active': isActive},
      fromJson: (json) {
        // admin.controller returns:
        // {
        //   success: true,
        //   data: {
        //     message: 'User ...',
        //     user: { id, role, is_active }
        //   }
        // }
        final data = (json['data'] as Map<String, dynamic>?);
        final userJson = data?['user'] as Map<String, dynamic>? ?? json;
        return UserModel.fromJson(userJson);
      },
    );
    return response.data!;
  }

  @override
  Future<void> resetUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    // Backend route:
    //   POST /api/admin/users/:userId/reset-password
    //   Body: { "new_password": "..." }
    await _apiClient.post<void>(
      '${ApiEndpoints.adminUsers}/$userId/reset-password',
      body: {
        'new_password': newPassword,
      },
    );
  }

}