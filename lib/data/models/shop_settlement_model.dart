// Data - Shop settlement model with JSON serialization.
//
// Maps between the API JSON representation and the domain ShopSettlement entity.

import '../../domain/entities/shop_settlement.dart';
import '../../domain/enums/settlement_status.dart';

/// Data model for [ShopSettlement] with JSON serialization support.
class ShopSettlementModel extends ShopSettlement {
  const ShopSettlementModel({
    required super.id,
    required super.shopId,
    required super.periodId,
    super.totalOrders,
    super.completedOrders,
    super.cancelledOrders,
    super.grossSales,
    super.totalCommission,
    super.pointsDiscounts,
    super.freeDeliveryCost,
    super.adsCost,
    super.netAmount,
    super.status,
    super.settledAt,
    super.notes,
    required super.createdAt,
  });

  /// Creates a [ShopSettlementModel] from a JSON map.
  factory ShopSettlementModel.fromJson(Map<String, dynamic> json) {
    return ShopSettlementModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      periodId: json['period_id'] as String,
      totalOrders: json['total_orders'] as int? ?? 0,
      completedOrders: json['completed_orders'] as int? ?? 0,
      cancelledOrders: json['cancelled_orders'] as int? ?? 0,
      grossSales: (json['gross_sales'] as num?)?.toDouble() ?? 0,
      totalCommission: (json['total_commission'] as num?)?.toDouble() ?? 0,
      pointsDiscounts: (json['points_discounts'] as num?)?.toDouble() ?? 0,
      freeDeliveryCost: (json['free_delivery_cost'] as num?)?.toDouble() ?? 0,
      adsCost: (json['ads_cost'] as num?)?.toDouble() ?? 0,
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0,
      status: json['status'] != null
          ? SettlementStatus.fromValue(json['status'] as String)
          : SettlementStatus.pending,
      settledAt: json['settled_at'] != null
          ? DateTime.parse(json['settled_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Creates a [ShopSettlementModel] from a domain [ShopSettlement] entity.
  factory ShopSettlementModel.fromEntity(ShopSettlement settlement) {
    return ShopSettlementModel(
      id: settlement.id,
      shopId: settlement.shopId,
      periodId: settlement.periodId,
      totalOrders: settlement.totalOrders,
      completedOrders: settlement.completedOrders,
      cancelledOrders: settlement.cancelledOrders,
      grossSales: settlement.grossSales,
      totalCommission: settlement.totalCommission,
      pointsDiscounts: settlement.pointsDiscounts,
      freeDeliveryCost: settlement.freeDeliveryCost,
      adsCost: settlement.adsCost,
      netAmount: settlement.netAmount,
      status: settlement.status,
      settledAt: settlement.settledAt,
      notes: settlement.notes,
      createdAt: settlement.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'period_id': periodId,
      'total_orders': totalOrders,
      'completed_orders': completedOrders,
      'cancelled_orders': cancelledOrders,
      'gross_sales': grossSales,
      'total_commission': totalCommission,
      'points_discounts': pointsDiscounts,
      'free_delivery_cost': freeDeliveryCost,
      'ads_cost': adsCost,
      'net_amount': netAmount,
      'status': status.value,
      'settled_at': settledAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}