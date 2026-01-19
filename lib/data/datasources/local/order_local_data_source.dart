/// Local data source for order operations.
///
/// This interface defines the contract for local order data storage.
/// Implementation will use SQLite or Hive for structured local storage.
library;

import '../../dto/order_dto.dart';

/// Local data source interface for orders.
abstract class OrderLocalDataSource {
  /// Cache order data.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheOrder(OrderDto order);

  /// Cache multiple orders.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheOrders(List<OrderDto> orders);

  /// Get cached order by ID.
  /// 
  /// Returns [OrderDto] if found.
  /// Returns null if not cached.
  /// Throws [CacheException] on storage failure.
  Future<OrderDto?> getCachedOrder(String orderId);

  /// Get all cached orders for a customer.
  /// 
  /// Returns list of [OrderDto].
  /// Throws [CacheException] on storage failure.
  Future<List<OrderDto>> getCachedCustomerOrders(String customerId);

  /// Get all cached orders for a store.
  /// 
  /// Returns list of [OrderDto].
  /// Throws [CacheException] on storage failure.
  Future<List<OrderDto>> getCachedStoreOrders(String storeId);

  /// Get all cached orders for a rider.
  /// 
  /// Returns list of [OrderDto].
  /// Throws [CacheException] on storage failure.
  Future<List<OrderDto>> getCachedRiderOrders(String riderId);

  /// Update cached order.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateCachedOrder(OrderDto order);

  /// Delete cached order.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> deleteCachedOrder(String orderId);

  /// Clear all cached orders.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearAllCachedOrders();

  /// Get pending offline orders (orders created while offline).
  /// 
  /// Returns list of [OrderDto] that need to be synced.
  Future<List<OrderDto>> getPendingOfflineOrders();

  /// Mark order as synced with server.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> markOrderSynced(String orderId);

  /// Get last cache update timestamp.
  /// 
  /// Returns DateTime if available.
  Future<DateTime?> getLastCacheUpdate();

  /// Update last cache timestamp.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateLastCacheTimestamp();

  /// Get orders by status (for filtering).
  /// 
  /// Returns list of [OrderDto] matching status.
  Future<List<OrderDto>> getCachedOrdersByStatus(String status);
}