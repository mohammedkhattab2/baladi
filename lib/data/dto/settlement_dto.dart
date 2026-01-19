/// Settlement Data Transfer Object for API/database serialization.
///
/// Maps between JSON data and the Settlement domain entities.
library;

import '../../domain/entities/settlement.dart';

/// DTO for Settlement entity serialization.
class SettlementDto {
  final String id;
  final String weekStart;
  final String weekEnd;
  final int totalOrders;
  final double totalRevenue;
  final double totalStoreCommissions;
  final double totalPointsRedeemed;
  final double totalFreeDeliveryCost;
  final double totalAdsCost;
  final double netPlatformCommission;
  final double totalStorePayout;
  final double totalRiderPayout;
  final String status;
  final String? closedBy;
  final String? closedAt;
  final String? paymentReference;
  final String? paidAt;
  final String? note;
  final String createdAt;
  final String updatedAt;

  const SettlementDto({
    required this.id,
    required this.weekStart,
    required this.weekEnd,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalStoreCommissions,
    required this.totalPointsRedeemed,
    required this.totalFreeDeliveryCost,
    required this.totalAdsCost,
    required this.netPlatformCommission,
    required this.totalStorePayout,
    required this.totalRiderPayout,
    required this.status,
    this.closedBy,
    this.closedAt,
    this.paymentReference,
    this.paidAt,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a SettlementDto from JSON map.
  factory SettlementDto.fromJson(Map<String, dynamic> json) {
    return SettlementDto(
      id: json['id'] as String,
      weekStart: json['week_start'] as String,
      weekEnd: json['week_end'] as String,
      totalOrders: json['total_orders'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      totalStoreCommissions: (json['total_store_commissions'] as num?)?.toDouble() ?? 0,
      totalPointsRedeemed: (json['total_points_redeemed'] as num?)?.toDouble() ?? 0,
      totalFreeDeliveryCost: (json['total_free_delivery_cost'] as num?)?.toDouble() ?? 0,
      totalAdsCost: (json['total_ads_cost'] as num?)?.toDouble() ?? 0,
      netPlatformCommission: (json['net_platform_commission'] as num?)?.toDouble() ?? 0,
      totalStorePayout: (json['total_store_payout'] as num?)?.toDouble() ?? 0,
      totalRiderPayout: (json['total_rider_payout'] as num?)?.toDouble() ?? 0,
      status: json['status'] as String? ?? 'pending',
      closedBy: json['closed_by'] as String?,
      closedAt: json['closed_at'] as String?,
      paymentReference: json['payment_reference'] as String?,
      paidAt: json['paid_at'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Converts this DTO to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'week_start': weekStart,
      'week_end': weekEnd,
      'total_orders': totalOrders,
      'total_revenue': totalRevenue,
      'total_store_commissions': totalStoreCommissions,
      'total_points_redeemed': totalPointsRedeemed,
      'total_free_delivery_cost': totalFreeDeliveryCost,
      'total_ads_cost': totalAdsCost,
      'net_platform_commission': netPlatformCommission,
      'total_store_payout': totalStorePayout,
      'total_rider_payout': totalRiderPayout,
      'status': status,
      'closed_by': closedBy,
      'closed_at': closedAt,
      'payment_reference': paymentReference,
      'paid_at': paidAt,
      'note': note,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Converts this DTO to a JSON map for insert (without id).
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Convert to domain entity.
  Settlement toEntity() {
    return Settlement(
      id: id,
      weekStart: DateTime.parse(weekStart),
      weekEnd: DateTime.parse(weekEnd),
      totalOrders: totalOrders,
      totalRevenue: totalRevenue,
      totalStoreCommissions: totalStoreCommissions,
      totalPointsRedeemed: totalPointsRedeemed,
      totalFreeDeliveryCost: totalFreeDeliveryCost,
      totalAdsCost: totalAdsCost,
      netPlatformCommission: netPlatformCommission,
      totalStorePayout: totalStorePayout,
      totalRiderPayout: totalRiderPayout,
      status: _parseStatus(status),
      closedBy: closedBy,
      closedAt: closedAt != null ? DateTime.parse(closedAt!) : null,
      paymentReference: paymentReference,
      paidAt: paidAt != null ? DateTime.parse(paidAt!) : null,
      note: note,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Create DTO from domain entity.
  factory SettlementDto.fromEntity(Settlement entity) {
    return SettlementDto(
      id: entity.id,
      weekStart: entity.weekStart.toIso8601String(),
      weekEnd: entity.weekEnd.toIso8601String(),
      totalOrders: entity.totalOrders,
      totalRevenue: entity.totalRevenue,
      totalStoreCommissions: entity.totalStoreCommissions,
      totalPointsRedeemed: entity.totalPointsRedeemed,
      totalFreeDeliveryCost: entity.totalFreeDeliveryCost,
      totalAdsCost: entity.totalAdsCost,
      netPlatformCommission: entity.netPlatformCommission,
      totalStorePayout: entity.totalStorePayout,
      totalRiderPayout: entity.totalRiderPayout,
      status: entity.status.name,
      closedBy: entity.closedBy,
      closedAt: entity.closedAt?.toIso8601String(),
      paymentReference: entity.paymentReference,
      paidAt: entity.paidAt?.toIso8601String(),
      note: entity.note,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }

  /// Parse status string to enum.
  static SettlementStatus _parseStatus(String status) {
    return SettlementStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => SettlementStatus.pending,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SettlementDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'SettlementDto(id: $id, status: $status)';
}

/// DTO for StoreSettlement entity serialization.
class StoreSettlementDto {
  final String storeId;
  final String storeName;
  final int orderCount;
  final double totalRevenue;
  final double commission;
  final double earnings;
  final double adsCost;
  final double netPayout;

  const StoreSettlementDto({
    required this.storeId,
    required this.storeName,
    required this.orderCount,
    required this.totalRevenue,
    required this.commission,
    required this.earnings,
    required this.adsCost,
    required this.netPayout,
  });

  /// Creates from JSON map.
  factory StoreSettlementDto.fromJson(Map<String, dynamic> json) {
    return StoreSettlementDto(
      storeId: json['store_id'] as String,
      storeName: json['store_name'] as String,
      orderCount: json['order_count'] as int? ?? 0,
      totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
      commission: (json['commission'] as num?)?.toDouble() ?? 0,
      earnings: (json['earnings'] as num?)?.toDouble() ?? 0,
      adsCost: (json['ads_cost'] as num?)?.toDouble() ?? 0,
      netPayout: (json['net_payout'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'store_id': storeId,
      'store_name': storeName,
      'order_count': orderCount,
      'total_revenue': totalRevenue,
      'commission': commission,
      'earnings': earnings,
      'ads_cost': adsCost,
      'net_payout': netPayout,
    };
  }

  /// Convert to domain entity.
  StoreSettlement toEntity() {
    return StoreSettlement(
      storeId: storeId,
      storeName: storeName,
      orderCount: orderCount,
      totalRevenue: totalRevenue,
      commission: commission,
      earnings: earnings,
      adsCost: adsCost,
      netPayout: netPayout,
    );
  }

  /// Create DTO from domain entity.
  factory StoreSettlementDto.fromEntity(StoreSettlement entity) {
    return StoreSettlementDto(
      storeId: entity.storeId,
      storeName: entity.storeName,
      orderCount: entity.orderCount,
      totalRevenue: entity.totalRevenue,
      commission: entity.commission,
      earnings: entity.earnings,
      adsCost: entity.adsCost,
      netPayout: entity.netPayout,
    );
  }
}

/// DTO for RiderSettlement entity serialization.
class RiderSettlementDto {
  final String riderId;
  final String riderName;
  final int deliveryCount;
  final double totalDeliveryFees;
  final double netPayout;

  const RiderSettlementDto({
    required this.riderId,
    required this.riderName,
    required this.deliveryCount,
    required this.totalDeliveryFees,
    required this.netPayout,
  });

  /// Creates from JSON map.
  factory RiderSettlementDto.fromJson(Map<String, dynamic> json) {
    return RiderSettlementDto(
      riderId: json['rider_id'] as String,
      riderName: json['rider_name'] as String,
      deliveryCount: json['delivery_count'] as int? ?? 0,
      totalDeliveryFees: (json['total_delivery_fees'] as num?)?.toDouble() ?? 0,
      netPayout: (json['net_payout'] as num?)?.toDouble() ?? 0,
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'rider_id': riderId,
      'rider_name': riderName,
      'delivery_count': deliveryCount,
      'total_delivery_fees': totalDeliveryFees,
      'net_payout': netPayout,
    };
  }

  /// Convert to domain entity.
  RiderSettlement toEntity() {
    return RiderSettlement(
      riderId: riderId,
      riderName: riderName,
      deliveryCount: deliveryCount,
      totalDeliveryFees: totalDeliveryFees,
      netPayout: netPayout,
    );
  }

  /// Create DTO from domain entity.
  factory RiderSettlementDto.fromEntity(RiderSettlement entity) {
    return RiderSettlementDto(
      riderId: entity.riderId,
      riderName: entity.riderName,
      deliveryCount: entity.deliveryCount,
      totalDeliveryFees: entity.totalDeliveryFees,
      netPayout: entity.netPayout,
    );
  }
}