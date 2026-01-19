/// Settlement entity representing weekly settlement data.
/// 
/// Settlements are created when admin closes the week.
/// Week period: Saturday 00:00 → Friday 23:59.
/// 
/// Architecture note: This is a domain entity with no external dependencies.
library;
/// Settlement entity for weekly financial closure.
class Settlement {
  /// Unique identifier.
  final String id;

  /// Week start date (Saturday 00:00).
  final DateTime weekStart;

  /// Week end date (Friday 23:59).
  final DateTime weekEnd;

  /// Total number of completed orders.
  final int totalOrders;

  /// Total order revenue (subtotals).
  final double totalRevenue;

  /// Total store commissions collected.
  final double totalStoreCommissions;

  /// Total points redeemed (as discount).
  final double totalPointsRedeemed;

  /// Total free delivery costs absorbed.
  final double totalFreeDeliveryCost;

  /// Total ads revenue.
  final double totalAdsCost;

  /// Net platform commission after deductions.
  final double netPlatformCommission;

  /// Total amount to pay stores.
  final double totalStorePayout;

  /// Total amount to pay riders.
  final double totalRiderPayout;

  /// Settlement status.
  final SettlementStatus status;

  /// Admin who closed the week.
  final String? closedBy;

  /// Date when week was closed.
  final DateTime? closedAt;

  /// Payment reference (if paid).
  final String? paymentReference;

  /// Date when settlement was paid.
  final DateTime? paidAt;

  /// Any notes or comments.
  final String? note;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const Settlement({
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

  /// Create a copy with updated fields.
  Settlement copyWith({
    String? id,
    DateTime? weekStart,
    DateTime? weekEnd,
    int? totalOrders,
    double? totalRevenue,
    double? totalStoreCommissions,
    double? totalPointsRedeemed,
    double? totalFreeDeliveryCost,
    double? totalAdsCost,
    double? netPlatformCommission,
    double? totalStorePayout,
    double? totalRiderPayout,
    SettlementStatus? status,
    String? closedBy,
    DateTime? closedAt,
    String? paymentReference,
    DateTime? paidAt,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Settlement(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      weekEnd: weekEnd ?? this.weekEnd,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      totalStoreCommissions: totalStoreCommissions ?? this.totalStoreCommissions,
      totalPointsRedeemed: totalPointsRedeemed ?? this.totalPointsRedeemed,
      totalFreeDeliveryCost: totalFreeDeliveryCost ?? this.totalFreeDeliveryCost,
      totalAdsCost: totalAdsCost ?? this.totalAdsCost,
      netPlatformCommission: netPlatformCommission ?? this.netPlatformCommission,
      totalStorePayout: totalStorePayout ?? this.totalStorePayout,
      totalRiderPayout: totalRiderPayout ?? this.totalRiderPayout,
      status: status ?? this.status,
      closedBy: closedBy ?? this.closedBy,
      closedAt: closedAt ?? this.closedAt,
      paymentReference: paymentReference ?? this.paymentReference,
      paidAt: paidAt ?? this.paidAt,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if settlement is finalized.
  bool get isFinalized => status == SettlementStatus.paid;

  /// Check if settlement can be modified.
  bool get canModify => status == SettlementStatus.pending;

  /// Get week number for display.
  String get weekLabel {
    final weekNum = weekStart.difference(DateTime(weekStart.year, 1, 1)).inDays ~/ 7 + 1;
    return 'Week $weekNum, ${weekStart.year}';
  }

  /// Get formatted week period.
  String get periodLabel {
    final startStr = '${weekStart.day}/${weekStart.month}';
    final endStr = '${weekEnd.day}/${weekEnd.month}';
    return '$startStr - $endStr';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Settlement && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Settlement(id: $id, week: $periodLabel, status: $status)';
}

/// Settlement status enum.
enum SettlementStatus {
  /// Settlement is being prepared.
  pending,

  /// Settlement is being processed.
  processing,

  /// Settlement calculations are complete.
  completed,

  /// Settlement has a dispute.
  disputed,

  /// Settlement has been paid out.
  paid;

  /// Display name.
  String get displayName {
    return switch (this) {
      SettlementStatus.pending => 'Pending',
      SettlementStatus.processing => 'Processing',
      SettlementStatus.completed => 'Completed',
      SettlementStatus.disputed => 'Disputed',
      SettlementStatus.paid => 'Paid',
    };
  }

  /// Arabic display name.
  String get displayNameAr {
    return switch (this) {
      SettlementStatus.pending => 'قيد الانتظار',
      SettlementStatus.processing => 'جاري المعالجة',
      SettlementStatus.completed => 'مكتمل',
      SettlementStatus.disputed => 'متنازع عليه',
      SettlementStatus.paid => 'مدفوع',
    };
  }
}

/// Store settlement breakdown.
class StoreSettlement {
  final String storeId;
  final String storeName;
  final int orderCount;
  final double totalRevenue;
  final double commission;
  final double earnings;
  final double adsCost;
  final double netPayout;

  const StoreSettlement({
    required this.storeId,
    required this.storeName,
    required this.orderCount,
    required this.totalRevenue,
    required this.commission,
    required this.earnings,
    required this.adsCost,
    required this.netPayout,
  });
}

/// Rider settlement breakdown.
class RiderSettlement {
  final String riderId;
  final String riderName;
  final int deliveryCount;
  final double totalDeliveryFees;
  final double netPayout;

  const RiderSettlement({
    required this.riderId,
    required this.riderName,
    required this.deliveryCount,
    required this.totalDeliveryFees,
    required this.netPayout,
  });
}