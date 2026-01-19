/// Remote data source for order operations.
///
/// This interface defines the contract for order API calls.
/// Implementation will use Supabase or similar service.
library;

import '../../dto/order_dto.dart';
import '../../dto/order_item_dto.dart';

/// Remote data source interface for orders.
abstract class OrderRemoteDataSource {
  /// Create a new order.
  ///
  /// Returns [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<OrderDto> createOrder({
    required String customerId,
    required String storeId,
    required List<OrderItemDto> items,
    required double subtotal,
    required double deliveryFee,
    required double total,
    required String deliveryAddress,
    String? deliveryAddressDetails,
    int pointsToRedeem = 0,
    double pointsDiscount = 0,
    String? note,
  });

  /// Get order by ID.
  ///
  /// Returns [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [NotFoundException] if order not found.
  Future<OrderDto> getOrderById(String orderId);

  /// Get orders for a customer.
  ///
  /// Returns list of [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<OrderDto>> getCustomerOrders({
    required String customerId,
    int page = 1,
    int limit = 20,
  });

  /// Get orders for a store.
  ///
  /// Returns list of [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<OrderDto>> getStoreOrders({
    required String storeId,
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Get orders assigned to a rider.
  ///
  /// Returns list of [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<OrderDto>> getRiderOrders({
    required String riderId,
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Get available orders for rider pickup.
  ///
  /// Returns list of [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<OrderDto>> getAvailableOrdersForRider({
    int page = 1,
    int limit = 20,
  });

  /// Update order status.
  ///
  /// Returns updated [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [InvalidStatusTransitionException] if status change not allowed.
  Future<OrderDto> updateOrderStatus({
    required String orderId,
    required String newStatus,
    String? riderId,
    String? note,
  });

  /// Assign rider to order.
  ///
  /// Returns updated [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<OrderDto> assignRider({
    required String orderId,
    required String riderId,
  });

  /// Confirm cash received by rider.
  ///
  /// Returns updated [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<OrderDto> confirmCashReceived({
    required String orderId,
    required String riderId,
  });

  /// Confirm cash transferred to shop.
  ///
  /// Returns updated [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<OrderDto> confirmCashToShop({
    required String orderId,
    required String storeId,
  });

  /// Cancel order.
  ///
  /// Returns updated [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<OrderDto> cancelOrder({required String orderId, String? reason});

  /// Get orders by date range (for settlement).
  ///
  /// Returns list of [OrderDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<OrderDto>> getOrdersByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? storeId,
    String? riderId,
  });

  /// Get order statistics for dashboard.
  ///
  /// Returns map of statistics.
  /// Throws [ServerException] on API failure.
  Future<Map<String, dynamic>> getOrderStatistics({
    required String entityId,
    required String entityType, // 'customer', 'store', 'rider', 'admin'
    DateTime? startDate,
    DateTime? endDate,
  });
}
