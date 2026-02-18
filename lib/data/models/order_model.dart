// Data - Order model with JSON serialization.
//
// Maps between the API JSON representation and the domain Order entity.
// Handles nested OrderItem list and all lifecycle timestamps.

import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/enums/order_status.dart';
import 'order_item_model.dart';

/// Data model for [Order] with JSON serialization support.
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.orderNumber,
    required super.customerId,
    required super.shopId,
    super.riderId,
    super.periodId,
    required super.status,
    required super.deliveryAddress,
    super.deliveryLandmark,
    super.deliveryArea,
    super.customerNotes,
    required super.subtotal,
    super.deliveryFee,
    super.isFreeDelivery,
    super.pointsUsed,
    super.pointsDiscount,
    required super.totalAmount,
    super.shopCommission,
    super.adminCommission,
    super.pointsEarned,
    super.cashCollected,
    super.cashToShop,
    super.shopConfirmedCash,
    super.cancellationReason,
    super.items,
    required super.createdAt,
    super.acceptedAt,
    super.preparingAt,
    super.pickedUpAt,
    super.shopPaidAt,
    super.completedAt,
    super.cancelledAt,
  });

  /// Creates an [OrderModel] from a JSON map.
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    // Support both `id` and `_id` for the order identifier.
    final String orderId =
        (json['id'] ?? json['_id'])?.toString() ?? '';

    // customer_id can be a String or an embedded object.
    final dynamic rawCustomer = json['customer_id'];
    final String customerId = rawCustomer is String
        ? rawCustomer
        : rawCustomer is Map<String, dynamic>
            ? (rawCustomer['id'] ?? rawCustomer['_id'])?.toString() ?? ''
            : '';

    // shop_id can be a String or an embedded object.
    final dynamic rawShop = json['shop_id'];
    final String shopId = rawShop is String
        ? rawShop
        : rawShop is Map<String, dynamic>
            ? (rawShop['id'] ?? rawShop['_id'])?.toString() ?? ''
            : '';

    // rider_id can be a String, an embedded object, or null.
    final dynamic rawRider = json['rider_id'];
    final String? riderId = rawRider == null
        ? null
        : rawRider is String
            ? rawRider
            : rawRider is Map<String, dynamic>
                ? (rawRider['id'] ?? rawRider['_id'])?.toString()
                : null;

    // Items list; ensure each item gets an order_id so OrderItemModel works.
    final itemsList = json['items'] as List<dynamic>? ?? const [];
    final List<OrderItem> items = itemsList
        .map((e) {
          final itemJson = e as Map<String, dynamic>;
          final merged = <String, dynamic>{
            ...itemJson,
            'order_id': itemJson['order_id'] ?? orderId,
          };
          return OrderItemModel.fromJson(merged);
        })
        .toList();

    // createdAt may be `created_at` or `createdAt`.
    final String? createdAtRaw =
        (json['created_at'] ?? json['createdAt']) as String?;
    final DateTime createdAt = createdAtRaw != null
        ? DateTime.parse(createdAtRaw)
        : DateTime.now();

    return OrderModel(
      id: orderId,
      orderNumber: json['order_number'] as String? ?? '',
      customerId: customerId,
      shopId: shopId,
      riderId: riderId,
      periodId: json['period_id']?.toString(),
      status: OrderStatus.fromValue(json['status'] as String),
      deliveryAddress: json['delivery_address'] as String? ?? '',
      deliveryLandmark: json['delivery_landmark'] as String?,
      deliveryArea: json['delivery_area'] as String?,
      customerNotes: json['customer_notes'] as String?,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 0,
      isFreeDelivery: json['is_free_delivery'] as bool? ?? false,
      pointsUsed: json['points_used'] as int? ?? 0,
      pointsDiscount: (json['points_discount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      shopCommission: (json['shop_commission'] as num?)?.toDouble() ?? 0,
      adminCommission: (json['admin_commission'] as num?)?.toDouble() ?? 0,
      pointsEarned: json['points_earned'] as int? ?? 0,
      cashCollected: json['cash_collected'] as bool? ?? false,
      cashToShop: json['cash_to_shop'] as bool? ?? false,
      shopConfirmedCash: json['shop_confirmed_cash'] as bool? ?? false,
      cancellationReason: json['cancellation_reason'] as String?,
      items: items,
      createdAt: createdAt,
      acceptedAt: json['accepted_at'] != null
          ? DateTime.parse(json['accepted_at'] as String)
          : null,
      preparingAt: json['preparing_at'] != null
          ? DateTime.parse(json['preparing_at'] as String)
          : null,
      pickedUpAt: json['picked_up_at'] != null
          ? DateTime.parse(json['picked_up_at'] as String)
          : null,
      shopPaidAt: json['shop_paid_at'] != null
          ? DateTime.parse(json['shop_paid_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.parse(json['cancelled_at'] as String)
          : null,
    );
  }

  /// Creates an [OrderModel] from a domain [Order] entity.
  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      shopId: order.shopId,
      riderId: order.riderId,
      periodId: order.periodId,
      status: order.status,
      deliveryAddress: order.deliveryAddress,
      deliveryLandmark: order.deliveryLandmark,
      deliveryArea: order.deliveryArea,
      customerNotes: order.customerNotes,
      subtotal: order.subtotal,
      deliveryFee: order.deliveryFee,
      isFreeDelivery: order.isFreeDelivery,
      pointsUsed: order.pointsUsed,
      pointsDiscount: order.pointsDiscount,
      totalAmount: order.totalAmount,
      shopCommission: order.shopCommission,
      adminCommission: order.adminCommission,
      pointsEarned: order.pointsEarned,
      cashCollected: order.cashCollected,
      cashToShop: order.cashToShop,
      shopConfirmedCash: order.shopConfirmedCash,
      cancellationReason: order.cancellationReason,
      items: order.items,
      createdAt: order.createdAt,
      acceptedAt: order.acceptedAt,
      preparingAt: order.preparingAt,
      pickedUpAt: order.pickedUpAt,
      shopPaidAt: order.shopPaidAt,
      completedAt: order.completedAt,
      cancelledAt: order.cancelledAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'shop_id': shopId,
      'rider_id': riderId,
      'period_id': periodId,
      'status': status.value,
      'delivery_address': deliveryAddress,
      'delivery_landmark': deliveryLandmark,
      'delivery_area': deliveryArea,
      'customer_notes': customerNotes,
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'is_free_delivery': isFreeDelivery,
      'points_used': pointsUsed,
      'points_discount': pointsDiscount,
      'total_amount': totalAmount,
      'shop_commission': shopCommission,
      'admin_commission': adminCommission,
      'points_earned': pointsEarned,
      'cash_collected': cashCollected,
      'cash_to_shop': cashToShop,
      'shop_confirmed_cash': shopConfirmedCash,
      'cancellation_reason': cancellationReason,
      'items': items
          .map((item) => OrderItemModel.fromEntity(item).toJson())
          .toList(),
      'created_at': createdAt.toIso8601String(),
      'accepted_at': acceptedAt?.toIso8601String(),
      'preparing_at': preparingAt?.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'shop_paid_at': shopPaidAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'cancelled_at': cancelledAt?.toIso8601String(),
    };
  }
}