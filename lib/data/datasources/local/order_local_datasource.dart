// Data - Order local datasource.
//
// Abstract interface and implementation for local order caching.
// Uses Hive via CacheService for offline order access.

import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/cache_service.dart';
import '../../models/order_model.dart';

/// Local datasource contract for order caching operations.
abstract class OrderLocalDatasource {
  /// Retrieves all cached orders.
  Future<List<OrderModel>> getCachedOrders();

  /// Caches a list of orders.
  Future<void> cacheOrders(List<OrderModel> orders);

  /// Caches a single order (upsert by ID).
  Future<void> cacheOrder(OrderModel order);

  /// Retrieves a single cached order by ID.
  Future<OrderModel?> getCachedOrderById(String orderId);

  /// Clears all cached orders.
  Future<void> clearCache();
}

/// Implementation of [OrderLocalDatasource] using [CacheService].
@LazySingleton(as: OrderLocalDatasource)
class OrderLocalDatasourceImpl implements OrderLocalDatasource {
  final CacheService _cacheService;

  /// Creates an [OrderLocalDatasourceImpl].
  OrderLocalDatasourceImpl({required CacheService cacheService})
      : _cacheService = cacheService;

  @override
  Future<List<OrderModel>> getCachedOrders() async {
    final allValues = _cacheService.getAll(StorageKeys.ordersBox);
    final orders = <OrderModel>[];
    for (final value in allValues) {
      try {
        final json = jsonDecode(value as String) as Map<String, dynamic>;
        orders.add(OrderModel.fromJson(json));
      } catch (_) {
        // Skip corrupted entries.
      }
    }
    return orders;
  }

  @override
  Future<void> cacheOrders(List<OrderModel> orders) async {
    await _cacheService.clearBox(StorageKeys.ordersBox);
    for (final order in orders) {
      final jsonString = jsonEncode(order.toJson());
      await _cacheService.put(StorageKeys.ordersBox, order.id, jsonString);
    }
  }

  @override
  Future<void> cacheOrder(OrderModel order) async {
    final jsonString = jsonEncode(order.toJson());
    await _cacheService.put(StorageKeys.ordersBox, order.id, jsonString);
  }

  @override
  Future<OrderModel?> getCachedOrderById(String orderId) async {
    final value = _cacheService.get(StorageKeys.ordersBox, orderId);
    if (value == null) return null;
    try {
      final json = jsonDecode(value as String) as Map<String, dynamic>;
      return OrderModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearBox(StorageKeys.ordersBox);
  }
}