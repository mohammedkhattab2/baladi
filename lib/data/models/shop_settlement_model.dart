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
  ///
  /// Backend may return:
  /// - Plain string IDs: `shop_id: "..."`, `period_id: "..."`, `id: "..."`.
  /// - Nested objects: `shop_id: { id/_id: "..." }`, `period_id: { id/_id: "..." }`.
  /// - Different timestamp keys or missing fields.
  factory ShopSettlementModel.fromJson(Map<String, dynamic> json) {
    String _extractId(dynamic value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map<String, dynamic>) {
        final dynamic inner =
            value['id'] ?? value['_id'] ?? value['value'] ?? value['code'];
        return inner?.toString() ?? '';
      }
      return value.toString();
    }

    // Support both `id` and `_id` for settlement identifier.
    final String id = _extractId(json['id'] ?? json['_id']);

    // shopId and periodId might be plain strings or nested objects.
    final String shopId = _extractId(json['shop_id']);
    final String periodId = _extractId(json['period_id']);

    final int totalOrders = json['total_orders'] as int? ?? 0;
    final int completedOrders = json['completed_orders'] as int? ?? 0;
    final int cancelledOrders = json['cancelled_orders'] as int? ?? 0;

    final double grossSales = (json['gross_sales'] as num?)?.toDouble() ?? 0;
    final double totalCommission =
        (json['total_commission'] as num?)?.toDouble() ?? 0;
    final double pointsDiscounts =
        (json['points_discounts'] as num?)?.toDouble() ?? 0;
    final double freeDeliveryCost =
        (json['free_delivery_cost'] as num?)?.toDouble() ?? 0;
    final double adsCost = (json['ads_cost'] as num?)?.toDouble() ?? 0;
    final double netAmount = (json['net_amount'] as num?)?.toDouble() ?? 0;

    // Status might be a string or a nested object; handle both safely.
    SettlementStatus status = SettlementStatus.pending;
    final dynamic rawStatus = json['status'];
    if (rawStatus is String) {
      status = SettlementStatus.fromValue(rawStatus);
    } else if (rawStatus is Map<String, dynamic>) {
      final dynamic statusValue =
          rawStatus['value'] ?? rawStatus['code'] ?? rawStatus['status'];
      if (statusValue is String) {
        status = SettlementStatus.fromValue(statusValue);
      }
    }

    DateTime? settledAt;
    final dynamic settledAtRaw = json['settled_at'] ?? json['settledAt'];
    if (settledAtRaw is String) {
      settledAt = DateTime.tryParse(settledAtRaw);
    }

    final String? notes = json['notes'] as String?;

    // createdAt may be under different keys and might be absent.
    DateTime createdAt;
    final dynamic createdAtRaw = json['created_at'] ?? json['createdAt'];
    if (createdAtRaw is String) {
      createdAt = DateTime.parse(createdAtRaw);
    } else {
      createdAt = DateTime.now();
    }

    return ShopSettlementModel(
      id: id,
      shopId: shopId,
      periodId: periodId,
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      grossSales: grossSales,
      totalCommission: totalCommission,
      pointsDiscounts: pointsDiscounts,
      freeDeliveryCost: freeDeliveryCost,
      adsCost: adsCost,
      netAmount: netAmount,
      status: status,
      settledAt: settledAt,
      notes: notes,
      createdAt: createdAt,
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