/// Repository interface for weekly settlement operations.
///
/// This defines the contract for settlement-related data access.
/// Handles weekly closures, commission calculations, and payouts.
///
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/settlement.dart';

// Re-export SettlementStatus for convenience
export '../entities/settlement.dart' show SettlementStatus;

/// Settlement repository interface.
abstract class SettlementRepository {
  /// Get settlement by ID.
  Future<Result<Settlement>> getSettlementById(String settlementId);

  /// Get current week's settlement (in progress).
  Future<Result<Settlement?>> getCurrentWeekSettlement();

  /// Get settlements for a store.
  Future<Result<List<Settlement>>> getStoreSettlements({
    required String storeId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get settlements for a rider.
  Future<Result<List<Settlement>>> getRiderSettlements({
    required String riderId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get all settlements (admin only).
  Future<Result<List<Settlement>>> getAllSettlements({
    DateTime? fromDate,
    DateTime? toDate,
    SettlementStatus? status,
    int page = 1,
    int pageSize = 20,
  });

  /// Get settlement details with breakdown.
  Future<Result<SettlementDetails>> getSettlementDetails(String settlementId);

  /// Close current week and create settlement.
  ///
  /// This is an admin-only operation.
  /// Week period: Saturday 00:00 → Friday 23:59.
  Future<Result<Settlement>> closeWeek({
    required String adminId,
    String? note,
  });

  /// Get preview of current week settlement.
  ///
  /// Shows what would be settled if week was closed now.
  Future<Result<SettlementPreview>> getSettlementPreview();

  /// Mark settlement as paid.
  Future<Result<Settlement>> markAsPaid({
    required String settlementId,
    required String adminId,
    String? paymentReference,
  });

  /// Add dispute to settlement.
  Future<Result<Settlement>> addDispute({
    required String settlementId,
    required String disputedBy,
    required String reason,
  });

  /// Resolve dispute.
  Future<Result<Settlement>> resolveDispute({
    required String settlementId,
    required String resolvedBy,
    required String resolution,
    double? adjustmentAmount,
  });

  /// Get settlement summary for period.
  Future<Result<SettlementSummary>> getSettlementSummary({
    required DateTime fromDate,
    required DateTime toDate,
    String? storeId,
    String? riderId,
  });

  /// Watch current week settlement.
  Stream<Settlement?> watchCurrentSettlement();
}

/// Detailed settlement breakdown.
class SettlementDetails {
  final Settlement settlement;
  final List<SettlementOrderItem> orders;
  final List<SettlementAdsItem> ads;
  final List<SettlementAdjustment> adjustments;

  const SettlementDetails({
    required this.settlement,
    required this.orders,
    required this.ads,
    required this.adjustments,
  });
}

/// Order item in settlement.
class SettlementOrderItem {
  final String orderId;
  final String orderNumber;
  final DateTime completedAt;
  final double subtotal;
  final double deliveryFee;
  final double storeCommission;
  final double platformCommission;
  final double pointsDiscount;
  final bool isFreeDelivery;

  const SettlementOrderItem({
    required this.orderId,
    required this.orderNumber,
    required this.completedAt,
    required this.subtotal,
    required this.deliveryFee,
    required this.storeCommission,
    required this.platformCommission,
    required this.pointsDiscount,
    required this.isFreeDelivery,
  });
}

/// Ads item in settlement.
class SettlementAdsItem {
  final String adId;
  final String storeId;
  final String storeName;
  final int days;
  final double costPerDay;
  final double totalCost;

  const SettlementAdsItem({
    required this.adId,
    required this.storeId,
    required this.storeName,
    required this.days,
    required this.costPerDay,
    required this.totalCost,
  });
}

/// Manual adjustment in settlement.
class SettlementAdjustment {
  final String id;
  final String reason;
  final double amount;
  final String adjustedBy;
  final DateTime createdAt;

  const SettlementAdjustment({
    required this.id,
    required this.reason,
    required this.amount,
    required this.adjustedBy,
    required this.createdAt,
  });
}

/// Settlement preview (before closing).
class SettlementPreview {
  final DateTime weekStart;
  final DateTime weekEnd;
  final int totalOrders;
  final double totalRevenue;
  final double totalCommissions;
  final double totalPointsRedeemed;
  final double totalFreeDeliveryCost;
  final double totalAdsCost;
  final double netPlatformCommission;
  final Map<String, double> storeEarnings;
  final Map<String, double> riderEarnings;

  const SettlementPreview({
    required this.weekStart,
    required this.weekEnd,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCommissions,
    required this.totalPointsRedeemed,
    required this.totalFreeDeliveryCost,
    required this.totalAdsCost,
    required this.netPlatformCommission,
    required this.storeEarnings,
    required this.riderEarnings,
  });
}

/// Settlement summary for reporting.
class SettlementSummary {
  final DateTime periodStart;
  final DateTime periodEnd;
  final int settlementCount;
  final int totalOrders;
  final double totalRevenue;
  final double totalCommissions;
  final double totalPointsRedeemed;
  final double totalAdsCost;
  final double netPlatformEarnings;

  const SettlementSummary({
    required this.periodStart,
    required this.periodEnd,
    required this.settlementCount,
    required this.totalOrders,
    required this.totalRevenue,
    required this.totalCommissions,
    required this.totalPointsRedeemed,
    required this.totalAdsCost,
    required this.netPlatformEarnings,
  });
}