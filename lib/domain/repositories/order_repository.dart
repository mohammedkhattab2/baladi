// Domain - Order repository interface.
//
// Defines the contract for order-related operations including
// placing orders, fetching order lists, status updates, and cancellation.

import '../../core/result/result.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../enums/order_status.dart';

/// Parameters for placing a new order.
class PlaceOrderParams {
  /// The shop to order from.
  final String shopId;

  /// List of items with product details and quantities.
  final List<OrderItem> items;

  /// Customer's delivery address.
  final String deliveryAddress;

  /// Optional landmark near the address.
  final String? landmark;

  /// Optional area/district.
  final String? area;

  /// Optional customer notes.
  final String? notes;

  /// Number of points to redeem (0 for none).
  final int pointsToRedeem;

  /// Whether free delivery promotion applies.
  final bool isFreeDelivery;

  /// Creates a [PlaceOrderParams].
  const PlaceOrderParams({
    required this.shopId,
    required this.items,
    required this.deliveryAddress,
    this.landmark,
    this.area,
    this.notes,
    this.pointsToRedeem = 0,
    this.isFreeDelivery = false,
  });
}

/// Repository contract for order-related operations.
///
/// Handles order creation, retrieval, status updates, and cancellation.
/// Used by customers, shops, and riders with role-appropriate methods.
abstract class OrderRepository {
  /// Places a new order.
  ///
  /// Validates items, calculates totals, applies discounts,
  /// and submits the order to the backend.
  Future<Result<Order>> placeOrder(PlaceOrderParams params);

  /// Fetches orders for the current user (filtered by role on backend).
  ///
  /// - [status]: Optional filter by order status.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Order>>> getOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches details of a specific order.
  ///
  /// - [orderId]: The order's unique identifier.
  Future<Result<Order>> getOrderDetails(String orderId);

  /// Accepts a pending order (shop action).
  ///
  /// Transitions: pending → accepted.
  Future<Result<Order>> acceptOrder(String orderId);

  /// Marks an order as being prepared (shop action).
  ///
  /// Transitions: accepted → preparing.
  Future<Result<Order>> markPreparing(String orderId);

  /// Marks an order as picked up by rider (rider action).
  ///
  /// Transitions: preparing → picked_up.
  Future<Result<Order>> markPickedUp(String orderId);

  /// Marks an order as delivered (rider action).
  ///
  /// Transitions: picked_up → shop_paid (rider confirms cash handover).
  Future<Result<Order>> markDelivered(String orderId);

  /// Confirms cash received from rider (shop action).
  ///
  /// Transitions: shop_paid → completed.
  Future<Result<Order>> confirmCashReceived(String orderId);

  /// Cancels an order.
  ///
  /// Only allowed from pending or accepted status.
  /// - [orderId]: The order's unique identifier.
  /// - [reason]: Optional cancellation reason.
  Future<Result<Order>> cancelOrder({
    required String orderId,
    String? reason,
  });

  /// Fetches shop-specific orders (shop owner view).
  ///
  /// - [status]: Optional filter by order status.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Order>>> getShopOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 20,
  });

  /// Returns locally cached orders, or empty list if none.
  Future<List<Order>> getCachedOrders();

  /// Caches orders locally for offline access.
  Future<void> cacheOrders(List<Order> orders);

  /// Clears the cached orders.
  Future<void> clearCache();
}