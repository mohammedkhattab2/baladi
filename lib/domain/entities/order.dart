// Domain - Order entity.
//
// Represents a customer order with full lifecycle tracking,
// financial breakdown, and delivery information.

import 'package:equatable/equatable.dart';

import '../enums/order_status.dart';
import 'order_item.dart';

/// A customer order placed at a shop for delivery.
///
/// Contains the full financial breakdown (subtotal, delivery fee,
/// points discount, commission) and lifecycle timestamps.
class Order extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// Human-readable order number (e.g. `ORD-2026-48391`).
  final String orderNumber;

  /// The customer who placed the order.
  final String customerId;

  /// The shop fulfilling the order.
  final String shopId;

  /// The rider assigned to deliver (null until assigned).
  final String? riderId;

  /// The weekly period this order belongs to.
  final String? periodId;

  /// Current status in the order lifecycle.
  final OrderStatus status;

  /// Delivery address text.
  final String deliveryAddress;

  /// Nearby landmark for delivery.
  final String? deliveryLandmark;

  /// Delivery area/neighborhood.
  final String? deliveryArea;

  /// Customer notes for the order.
  final String? customerNotes;

  // ─── Financial Breakdown ────────────────────────────────────

  /// Sum of all item prices × quantities.
  final double subtotal;

  /// Delivery fee charged to the customer (0 if free delivery).
  final double deliveryFee;

  /// Whether this order qualifies for free delivery.
  final bool isFreeDelivery;

  /// Number of loyalty points redeemed.
  final int pointsUsed;

  /// Monetary value of redeemed points (in EGP).
  final double pointsDiscount;

  /// Final amount the customer pays: subtotal + deliveryFee - pointsDiscount.
  final double totalAmount;

  /// Commission amount owed to the platform by the shop.
  final double shopCommission;

  /// Net admin commission after deducting points discounts and free delivery costs.
  final double adminCommission;

  /// Loyalty points earned from this order.
  final int pointsEarned;

  // ─── Cash Flow Tracking ─────────────────────────────────────

  /// Whether cash has been collected from the customer by the rider.
  final bool cashCollected;

  /// Whether the rider has handed cash to the shop.
  final bool cashToShop;

  /// Whether the shop confirmed receiving cash.
  final bool shopConfirmedCash;

  // ─── Cancellation ───────────────────────────────────────────

  /// Reason for cancellation (null if not cancelled).
  final String? cancellationReason;

  // ─── Line Items ─────────────────────────────────────────────

  /// The ordered products (may be empty if not loaded with details).
  final List<OrderItem> items;

  // ─── Timestamps ─────────────────────────────────────────────

  /// When the order was created.
  final DateTime createdAt;

  /// When the shop accepted the order.
  final DateTime? acceptedAt;

  /// When the shop started preparing.
  final DateTime? preparingAt;

  /// When the rider picked up the order.
  final DateTime? pickedUpAt;

  /// When the rider handed cash to shop.
  final DateTime? shopPaidAt;

  /// When the order was fully completed.
  final DateTime? completedAt;

  /// When the order was cancelled.
  final DateTime? cancelledAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.shopId,
    this.riderId,
    this.periodId,
    required this.status,
    required this.deliveryAddress,
    this.deliveryLandmark,
    this.deliveryArea,
    this.customerNotes,
    required this.subtotal,
    this.deliveryFee = 0,
    this.isFreeDelivery = false,
    this.pointsUsed = 0,
    this.pointsDiscount = 0,
    required this.totalAmount,
    this.shopCommission = 0,
    this.adminCommission = 0,
    this.pointsEarned = 0,
    this.cashCollected = false,
    this.cashToShop = false,
    this.shopConfirmedCash = false,
    this.cancellationReason,
    this.items = const [],
    required this.createdAt,
    this.acceptedAt,
    this.preparingAt,
    this.pickedUpAt,
    this.shopPaidAt,
    this.completedAt,
    this.cancelledAt,
  });

  /// Returns `true` if the order is still active (not completed/cancelled).
  bool get isActive => status.isActive;

  /// Returns `true` if the order can be cancelled.
  bool get isCancellable => status.isCancellable;

  /// Returns `true` if a rider has been assigned.
  bool get hasRider => riderId != null;

  /// Returns the total number of items in the order.
  int get totalItems =>
      items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        id,
        orderNumber,
        customerId,
        shopId,
        riderId,
        periodId,
        status,
        deliveryAddress,
        deliveryLandmark,
        deliveryArea,
        customerNotes,
        subtotal,
        deliveryFee,
        isFreeDelivery,
        pointsUsed,
        pointsDiscount,
        totalAmount,
        shopCommission,
        adminCommission,
        pointsEarned,
        cashCollected,
        cashToShop,
        shopConfirmedCash,
        cancellationReason,
        items,
        createdAt,
        acceptedAt,
        preparingAt,
        pickedUpAt,
        shopPaidAt,
        completedAt,
        cancelledAt,
      ];
}