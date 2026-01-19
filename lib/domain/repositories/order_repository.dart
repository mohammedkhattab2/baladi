/// Repository interface for order operations.
/// 
/// This defines the contract for order-related data access.
/// Supports offline-first strategy with local caching.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/order.dart';
import '../enums/order_status.dart';
import '../enums/user_role.dart';

/// Order repository interface.
abstract class OrderRepository {
  /// Create a new order.
  /// 
  /// Returns the created order with server-assigned ID.
  Future<Result<Order>> createOrder(Order order);

  /// Get order by ID.
  Future<Result<Order>> getOrderById(String orderId);

  /// Get orders for a customer.
  /// 
  /// Supports pagination and filtering by status.
  Future<Result<List<Order>>> getCustomerOrders({
    required String customerId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get orders for a store.
  /// 
  /// Supports pagination and filtering by status.
  Future<Result<List<Order>>> getStoreOrders({
    required String storeId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get orders assigned to a rider.
  /// 
  /// Supports pagination and filtering by status.
  Future<Result<List<Order>>> getRiderOrders({
    required String riderId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get all orders (admin only).
  /// 
  /// Supports pagination and filtering.
  Future<Result<List<Order>>> getAllOrders({
    OrderStatus? status,
    String? storeId,
    String? riderId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Update order status.
  /// 
  /// Validates status transition before updating.
  Future<Result<Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String updatedBy,
    required UserRole updaterRole,
    String? note,
  });

  /// Assign rider to order.
  Future<Result<Order>> assignRider({
    required String orderId,
    required String riderId,
  });

  /// Confirm cash received by store.
  /// 
  /// This transitions order to shopPaid status.
  Future<Result<Order>> confirmCashReceived({
    required String orderId,
    required String storeId,
    required double amount,
  });

  /// Cancel an order.
  /// 
  /// Includes reason for cancellation.
  Future<Result<Order>> cancelOrder({
    required String orderId,
    required String cancelledBy,
    required UserRole cancellerRole,
    required String reason,
  });

  /// Get active orders count by status.
  Future<Result<Map<OrderStatus, int>>> getOrderCountsByStatus({
    String? storeId,
    String? riderId,
  });

  /// Get orders for weekly settlement.
  Future<Result<List<Order>>> getOrdersForSettlement({
    required DateTime weekStart,
    required DateTime weekEnd,
    String? storeId,
    String? riderId,
  });

  /// Watch order updates in real-time.
  /// 
  /// Returns a stream of order updates.
  Stream<Order> watchOrder(String orderId);

  /// Watch orders list updates.
  /// 
  /// Returns a stream of order list updates.
  Stream<List<Order>> watchOrders({
    String? customerId,
    String? storeId,
    String? riderId,
    OrderStatus? status,
  });

  /// Sync local orders with remote.
  /// 
  /// Used for offline-first synchronization.
  Future<Result<void>> syncOrders();

  /// Get pending sync orders (offline-created).
  Future<Result<List<Order>>> getPendingSyncOrders();
}