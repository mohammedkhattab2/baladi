/// Order Data Transfer Object.
///
/// Used for serialization/deserialization of Order data
/// between API/database and domain entities.
library;

import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/enums/payment_method.dart';
import 'order_item_dto.dart';

/// DTO for Order entity.
class OrderDto {
  final String id;
  final String orderNumber;
  final String customerId;
  final String storeId;
  final String? riderId;
  final String status;
  final List<OrderItemDto> items;
  final double subtotal;
  final double deliveryFee;
  final bool isFreeDelivery;
  final int pointsUsed;
  final double pointsDiscount;
  final double total;
  final double storeCommission;
  final double platformCommission;
  final int pointsEarned;
  final String paymentMethod;
  final String deliveryAddress;
  final String? deliveryLandmark;
  final String? deliveryArea;
  final String? customerNotes;
  final String? storeNotes;
  final String? cancellationReason;
  final bool cashCollected;
  final bool cashTransferredToShop;
  final bool shopConfirmedCash;
  final String? weeklyPeriodId;
  final String createdAt;
  final String? acceptedAt;
  final String? preparingAt;
  final String? pickedUpAt;
  final String? shopPaidAt;
  final String? completedAt;
  final String? cancelledAt;

  const OrderDto({
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
    this.paymentMethod = 'cash',
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

  /// Create from JSON map.
  factory OrderDto.fromJson(Map<String, dynamic> json) {
    return OrderDto(
      id: json['id'] as String,
      orderNumber: json['order_number'] as String,
      customerId: json['customer_id'] as String,
      storeId: json['store_id'] as String,
      riderId: json['rider_id'] as String?,
      status: json['status'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItemDto.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      subtotal: (json['subtotal'] as num).toDouble(),
      deliveryFee: (json['delivery_fee'] as num).toDouble(),
      isFreeDelivery: json['is_free_delivery'] as bool? ?? false,
      pointsUsed: json['points_used'] as int? ?? 0,
      pointsDiscount: (json['points_discount'] as num?)?.toDouble() ?? 0,
      total: (json['total'] as num).toDouble(),
      storeCommission: (json['store_commission'] as num).toDouble(),
      platformCommission: (json['platform_commission'] as num).toDouble(),
      pointsEarned: json['points_earned'] as int? ?? 0,
      paymentMethod: json['payment_method'] as String? ?? 'cash',
      deliveryAddress: json['delivery_address'] as String,
      deliveryLandmark: json['delivery_landmark'] as String?,
      deliveryArea: json['delivery_area'] as String?,
      customerNotes: json['customer_notes'] as String?,
      storeNotes: json['store_notes'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      cashCollected: json['cash_collected'] as bool? ?? false,
      cashTransferredToShop: json['cash_transferred_to_shop'] as bool? ?? false,
      shopConfirmedCash: json['shop_confirmed_cash'] as bool? ?? false,
      weeklyPeriodId: json['weekly_period_id'] as String?,
      createdAt: json['created_at'] as String,
      acceptedAt: json['accepted_at'] as String?,
      preparingAt: json['preparing_at'] as String?,
      pickedUpAt: json['picked_up_at'] as String?,
      shopPaidAt: json['shop_paid_at'] as String?,
      completedAt: json['completed_at'] as String?,
      cancelledAt: json['cancelled_at'] as String?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_number': orderNumber,
      'customer_id': customerId,
      'store_id': storeId,
      'rider_id': riderId,
      'status': status,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'delivery_fee': deliveryFee,
      'is_free_delivery': isFreeDelivery,
      'points_used': pointsUsed,
      'points_discount': pointsDiscount,
      'total': total,
      'store_commission': storeCommission,
      'platform_commission': platformCommission,
      'points_earned': pointsEarned,
      'payment_method': paymentMethod,
      'delivery_address': deliveryAddress,
      'delivery_landmark': deliveryLandmark,
      'delivery_area': deliveryArea,
      'customer_notes': customerNotes,
      'store_notes': storeNotes,
      'cancellation_reason': cancellationReason,
      'cash_collected': cashCollected,
      'cash_transferred_to_shop': cashTransferredToShop,
      'shop_confirmed_cash': shopConfirmedCash,
      'weekly_period_id': weeklyPeriodId,
      'created_at': createdAt,
      'accepted_at': acceptedAt,
      'preparing_at': preparingAt,
      'picked_up_at': pickedUpAt,
      'shop_paid_at': shopPaidAt,
      'completed_at': completedAt,
      'cancelled_at': cancelledAt,
    };
  }

  /// Convert to domain entity.
  Order toEntity() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      storeId: storeId,
      riderId: riderId,
      status: OrderStatus.fromString(status) ?? OrderStatus.pending,
      items: items.map((item) => item.toEntity()).toList(),
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      isFreeDelivery: isFreeDelivery,
      pointsUsed: pointsUsed,
      pointsDiscount: pointsDiscount,
      total: total,
      storeCommission: storeCommission,
      platformCommission: platformCommission,
      pointsEarned: pointsEarned,
      paymentMethod: PaymentMethod.values.firstWhere(
        (p) => p.name == paymentMethod,
        orElse: () => PaymentMethod.cash,
      ),
      deliveryAddress: deliveryAddress,
      deliveryLandmark: deliveryLandmark,
      deliveryArea: deliveryArea,
      customerNotes: customerNotes,
      storeNotes: storeNotes,
      cancellationReason: cancellationReason,
      cashCollected: cashCollected,
      cashTransferredToShop: cashTransferredToShop,
      shopConfirmedCash: shopConfirmedCash,
      weeklyPeriodId: weeklyPeriodId,
      createdAt: DateTime.parse(createdAt),
      acceptedAt: acceptedAt != null ? DateTime.parse(acceptedAt!) : null,
      preparingAt: preparingAt != null ? DateTime.parse(preparingAt!) : null,
      pickedUpAt: pickedUpAt != null ? DateTime.parse(pickedUpAt!) : null,
      shopPaidAt: shopPaidAt != null ? DateTime.parse(shopPaidAt!) : null,
      completedAt: completedAt != null ? DateTime.parse(completedAt!) : null,
      cancelledAt: cancelledAt != null ? DateTime.parse(cancelledAt!) : null,
    );
  }

  /// Create from domain entity.
  factory OrderDto.fromEntity(Order entity) {
    return OrderDto(
      id: entity.id,
      orderNumber: entity.orderNumber,
      customerId: entity.customerId,
      storeId: entity.storeId,
      riderId: entity.riderId,
      status: entity.status.name,
      items: entity.items.map((item) => OrderItemDto.fromEntity(item)).toList(),
      subtotal: entity.subtotal,
      deliveryFee: entity.deliveryFee,
      isFreeDelivery: entity.isFreeDelivery,
      pointsUsed: entity.pointsUsed,
      pointsDiscount: entity.pointsDiscount,
      total: entity.total,
      storeCommission: entity.storeCommission,
      platformCommission: entity.platformCommission,
      pointsEarned: entity.pointsEarned,
      paymentMethod: entity.paymentMethod.name,
      deliveryAddress: entity.deliveryAddress,
      deliveryLandmark: entity.deliveryLandmark,
      deliveryArea: entity.deliveryArea,
      customerNotes: entity.customerNotes,
      storeNotes: entity.storeNotes,
      cancellationReason: entity.cancellationReason,
      cashCollected: entity.cashCollected,
      cashTransferredToShop: entity.cashTransferredToShop,
      shopConfirmedCash: entity.shopConfirmedCash,
      weeklyPeriodId: entity.weeklyPeriodId,
      createdAt: entity.createdAt.toIso8601String(),
      acceptedAt: entity.acceptedAt?.toIso8601String(),
      preparingAt: entity.preparingAt?.toIso8601String(),
      pickedUpAt: entity.pickedUpAt?.toIso8601String(),
      shopPaidAt: entity.shopPaidAt?.toIso8601String(),
      completedAt: entity.completedAt?.toIso8601String(),
      cancelledAt: entity.cancelledAt?.toIso8601String(),
    );
  }
}