// Data - Order remote datasource.
//
// Abstract interface and implementation for order-related API calls.
// Handles order creation, retrieval, status transitions, and cancellation.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/order_item_model.dart';
import '../../models/order_model.dart';

/// Remote datasource contract for order operations.
abstract class OrderRemoteDatasource {
  /// Places a new order.
  Future<OrderModel> placeOrder({
    required String shopId,
    required List<OrderItemModel> items,
    required String deliveryAddress,
    String? landmark,
    String? area,
    String? notes,
    int pointsToRedeem = 0,
    bool isFreeDelivery = false,
  });

  /// Fetches orders for the current user.
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches details of a specific order.
  Future<OrderModel> getOrderDetails(String orderId);

  /// Accepts a pending order (shop action).
  Future<OrderModel> acceptOrder(String orderId);

  /// Marks an order as being prepared (shop action).
  Future<OrderModel> markPreparing(String orderId);

  /// Marks an order as picked up by rider (rider action).
  Future<OrderModel> markPickedUp(String orderId);

  /// Marks an order as delivered (rider action).
  Future<OrderModel> markDelivered(String orderId);

  /// Confirms cash received from rider (shop action).
  Future<OrderModel> confirmCashReceived(String orderId);

  /// Cancels an order.
  Future<OrderModel> cancelOrder({
    required String orderId,
    String? reason,
  });

  /// Fetches shop-specific orders (shop owner view).
  Future<List<OrderModel>> getShopOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  });
}

/// Implementation of [OrderRemoteDatasource] using [ApiClient].
@LazySingleton(as: OrderRemoteDatasource)
class OrderRemoteDatasourceImpl implements OrderRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates an [OrderRemoteDatasourceImpl].
  OrderRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<OrderModel> placeOrder({
    required String shopId,
    required List<OrderItemModel> items,
    required String deliveryAddress,
    String? landmark,
    String? area,
    String? notes,
    int pointsToRedeem = 0,
    bool isFreeDelivery = false,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      body: {
        'shop_id': shopId,
        'items': items.map((item) => {
          'product_id': item.productId,
          'product_name': item.productName,
          'price': item.price,
          'quantity': item.quantity,
          if (item.notes != null) 'notes': item.notes,
        }).toList(),
        'delivery_address': deliveryAddress,
        if (landmark != null) 'landmark': landmark,
        if (area != null) 'area': area,
        if (notes != null) 'customer_notes': notes,
        'points_to_redeem': pointsToRedeem,
        'is_free_delivery': isFreeDelivery,
      },
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<List<OrderModel>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<OrderModel>>(
      ApiEndpoints.orders,
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
  Future<OrderModel> getOrderDetails(String orderId) async {
    final response = await _apiClient.get(
      ApiEndpoints.orderDetails(orderId),
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<OrderModel> acceptOrder(String orderId) async {
    final response = await _apiClient.put(
      ApiEndpoints.orderAccept(orderId),
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<OrderModel> markPreparing(String orderId) async {
    final response = await _apiClient.put(
      ApiEndpoints.orderPreparing(orderId),
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<OrderModel> markPickedUp(String orderId) async {
    final response = await _apiClient.put(
      ApiEndpoints.orderPickup(orderId),
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<OrderModel> markDelivered(String orderId) async {
    final response = await _apiClient.put(
      ApiEndpoints.orderDeliver(orderId),
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<OrderModel> confirmCashReceived(String orderId) async {
    final response = await _apiClient.put(
      ApiEndpoints.orderConfirmCash(orderId),
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<OrderModel> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.orderCancel(orderId),
      body: {
        if (reason != null) 'reason': reason,
      },
      fromJson: (json) => OrderModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<List<OrderModel>> getShopOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<OrderModel>>(
      ApiEndpoints.shopOrders,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
        if (status != null) 'status': status,
      },
      fromJson: (json) => _parseList(json, OrderModel.fromJson),
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