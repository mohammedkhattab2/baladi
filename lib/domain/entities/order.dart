/// Order entity in the Baladi application.
///
/// This is a pure domain entity representing a customer order.
/// It is the aggregate root for order-related operations.
///
/// Architecture note: Order is an aggregate root that contains
/// OrderItems. All business rules related to orders are validated
/// through domain services, not in this entity.
library;

import '../enums/order_status.dart';
import '../enums/payment_method.dart';
import 'order_item.dart';

/// Represents a customer order in the system.
class Order {
  /// Unique identifier for the order.
  final String id;

  /// Human-readable order number (e.g., "ORD-2026-00123").
  final String orderNumber;

  /// Customer ID who placed the order.
  final String customerId;

  /// Store ID that receives the order.
  final String storeId;

  /// Rider ID assigned to deliver (null if not assigned).
  final String? riderId;

  /// Current status of the order.
  final OrderStatus status;

  /// Items in the order.
  final List<OrderItem> items;

  /// Subtotal of all items (before delivery and discounts).
  final double subtotal;

  /// Delivery fee charged to customer.
  final double deliveryFee;

  /// Whether this is a free delivery order.
  final bool isFreeDelivery;

  /// Points used by customer for discount.
  final int pointsUsed;

  /// Discount amount from points redemption.
  final double pointsDiscount;

  /// Total amount to be paid by customer.
  final double total;

  /// Commission amount for the store.
  final double storeCommission;

  /// Commission amount for the platform (admin).
  final double platformCommission;

  /// Points earned by customer from this order.
  final int pointsEarned;

  /// Payment method used.
  final PaymentMethod paymentMethod;

  /// Delivery address text.
  final String deliveryAddress;

  /// Delivery landmark.
  final String? deliveryLandmark;

  /// Delivery area.
  final String? deliveryArea;

  /// Customer notes for the order.
  final String? customerNotes;

  /// Store notes for the order.
  final String? storeNotes;

  /// Reason for cancellation (if cancelled).
  final String? cancellationReason;

  /// Whether cash was collected by rider.
  final bool cashCollected;

  /// Whether cash was transferred to shop.
  final bool cashTransferredToShop;

  /// Whether shop confirmed cash receipt.
  final bool shopConfirmedCash;

  /// Weekly period ID for settlement.
  final String? weeklyPeriodId;

  /// When the order was created.
  final DateTime createdAt;

  /// When the order was accepted by store.
  final DateTime? acceptedAt;

  /// When the store started preparing.
  final DateTime? preparingAt;

  /// When the rider picked up the order.
  final DateTime? pickedUpAt;

  /// When cash was transferred to shop.
  final DateTime? shopPaidAt;

  /// When the order was completed.
  final DateTime? completedAt;

  /// When the order was cancelled.
  final DateTime? cancelledAt;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.storeId,
    this.riderId,
    required this.status,
    required this.items,
    required this.subtotal,
    required this.deliveryFee,
    this.isFreeDelivery = false,
    this.pointsUsed = 0,
    this.pointsDiscount = 0,
    required this.total,
    required this.storeCommission,
    required this.platformCommission,
    this.pointsEarned = 0,
    this.paymentMethod = PaymentMethod.cash,
    required this.deliveryAddress,
    this.deliveryLandmark,
    this.deliveryArea,
    this.customerNotes,
    this.storeNotes,
    this.cancellationReason,
    this.cashCollected = false,
    this.cashTransferredToShop = false,
    this.shopConfirmedCash = false,
    this.weeklyPeriodId,
    required this.createdAt,
    this.acceptedAt,
    this.preparingAt,
    this.pickedUpAt,
    this.shopPaidAt,
    this.completedAt,
    this.cancelledAt,
  });

  /// Creates a copy of this order with the given fields replaced.
  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? storeId,
    String? riderId,
    OrderStatus? status,
    List<OrderItem>? items,
    double? subtotal,
    double? deliveryFee,
    bool? isFreeDelivery,
    int? pointsUsed,
    double? pointsDiscount,
    double? total,
    double? storeCommission,
    double? platformCommission,
    int? pointsEarned,
    PaymentMethod? paymentMethod,
    String? deliveryAddress,
    String? deliveryLandmark,
    String? deliveryArea,
    String? customerNotes,
    String? storeNotes,
    String? cancellationReason,
    bool? cashCollected,
    bool? cashTransferredToShop,
    bool? shopConfirmedCash,
    String? weeklyPeriodId,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? preparingAt,
    DateTime? pickedUpAt,
    DateTime? shopPaidAt,
    DateTime? completedAt,
    DateTime? cancelledAt,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      storeId: storeId ?? this.storeId,
      riderId: riderId ?? this.riderId,
      status: status ?? this.status,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isFreeDelivery: isFreeDelivery ?? this.isFreeDelivery,
      pointsUsed: pointsUsed ?? this.pointsUsed,
      pointsDiscount: pointsDiscount ?? this.pointsDiscount,
      total: total ?? this.total,
      storeCommission: storeCommission ?? this.storeCommission,
      platformCommission: platformCommission ?? this.platformCommission,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLandmark: deliveryLandmark ?? this.deliveryLandmark,
      deliveryArea: deliveryArea ?? this.deliveryArea,
      customerNotes: customerNotes ?? this.customerNotes,
      storeNotes: storeNotes ?? this.storeNotes,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cashCollected: cashCollected ?? this.cashCollected,
      cashTransferredToShop: cashTransferredToShop ?? this.cashTransferredToShop,
      shopConfirmedCash: shopConfirmedCash ?? this.shopConfirmedCash,
      weeklyPeriodId: weeklyPeriodId ?? this.weeklyPeriodId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      shopPaidAt: shopPaidAt ?? this.shopPaidAt,
      completedAt: completedAt ?? this.completedAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  /// Check if order can transition to a new status.
  bool canTransitionTo(OrderStatus newStatus) {
    return status.canTransitionTo(newStatus);
  }

  /// Returns true if the order is in a final state.
  bool get isFinal => status.isFinal;

  /// Returns true if the order is active.
  bool get isActive => status.isActive;

  /// Returns true if the order can be cancelled.
  bool get canBeCancelled => status.canBeCancelled;

  /// Returns true if a rider is needed.
  bool get needsRider => status.requiresRider && riderId == null;

  /// Returns the number of items in the order.
  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  /// Returns the store earnings (subtotal - commission).
  double get storeEarnings => subtotal - storeCommission;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Order(id: $id, number: $orderNumber, status: ${status.name})';
}