// Domain - Settlement calculator service.
//
// Encapsulates all settlement-related business logic for computing
// shop and rider settlement summaries for a weekly period.

import '../rules/settlement_rules.dart';

/// Domain service for weekly settlement calculations.
///
/// Computes shop settlement breakdowns and rider earnings
/// summaries based on completed orders in a given period.
class SettlementCalculator {
  /// Calculates a shop's settlement summary for a weekly period.
  ShopSettlementSummary calculateShopSettlement({
    required double grossSales,
    required double commissionRate,
    required double pointsDiscountsGiven,
    required double freeDeliveryCosts,
    required double adsCost,
    required int totalOrders,
    required int completedOrders,
    required int cancelledOrders,
  }) {
    final totalCommission = grossSales * commissionRate;
    final netPayable = SettlementRules.calculateShopNetPayable(
      grossSales: grossSales,
      totalCommission: totalCommission,
      pointsDiscounts: pointsDiscountsGiven,
      freeDeliveryCost: freeDeliveryCosts,
      adsCost: adsCost,
    );
    final adminNet = SettlementRules.calculateAdminNetCommission(
      totalCommission: totalCommission,
      pointsDiscounts: pointsDiscountsGiven,
      freeDeliveryCost: freeDeliveryCosts,
      adsRevenue: adsCost,
    );

    return ShopSettlementSummary(
      grossSales: grossSales,
      totalCommission: totalCommission,
      pointsDiscounts: pointsDiscountsGiven,
      freeDeliveryCost: freeDeliveryCosts,
      adsCost: adsCost,
      netPayable: netPayable,
      adminNetCommission: adminNet,
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
    );
  }

  /// Calculates a rider's settlement summary for a weekly period.
  RiderSettlementSummary calculateRiderSettlement({
    required int totalDeliveries,
    required double totalDeliveryFees,
    required double totalCashHandled,
    required double commissionDeducted,
  }) {
    final netEarnings = SettlementRules.calculateRiderNetEarnings(
      totalDeliveryFees: totalDeliveryFees,
      commissionDeducted: commissionDeducted,
    );

    return RiderSettlementSummary(
      totalDeliveries: totalDeliveries,
      totalDeliveryFees: totalDeliveryFees,
      totalCashHandled: totalCashHandled,
      commissionDeducted: commissionDeducted,
      netEarnings: netEarnings,
    );
  }

  /// Calculates the admin summary across all shops and riders for a period.
  AdminSettlementSummary calculateAdminSummary({
    required List<ShopSettlementSummary> shopSettlements,
    required List<RiderSettlementSummary> riderSettlements,
    required double totalAdsRevenue,
    required int totalPointsRedeemed,
  }) {
    final totalOrders =
        shopSettlements.fold<int>(0, (sum, s) => sum + s.totalOrders);
    final completedOrders =
        shopSettlements.fold<int>(0, (sum, s) => sum + s.completedOrders);
    final cancelledOrders =
        shopSettlements.fold<int>(0, (sum, s) => sum + s.cancelledOrders);
    final grossSales =
        shopSettlements.fold<double>(0, (sum, s) => sum + s.grossSales);
    final totalCommissions =
        shopSettlements.fold<double>(0, (sum, s) => sum + s.totalCommission);
    final totalPointsDiscounts =
        shopSettlements.fold<double>(0, (sum, s) => sum + s.pointsDiscounts);
    final totalFreeDelivery =
        shopSettlements.fold<double>(0, (sum, s) => sum + s.freeDeliveryCost);
    final totalDeliveryFees =
        riderSettlements.fold<double>(0, (sum, r) => sum + r.totalDeliveryFees);

    final adminNetRevenue = SettlementRules.calculateAdminNetCommission(
      totalCommission: totalCommissions,
      pointsDiscounts: totalPointsDiscounts,
      freeDeliveryCost: totalFreeDelivery,
      adsRevenue: totalAdsRevenue,
    );

    return AdminSettlementSummary(
      totalOrders: totalOrders,
      completedOrders: completedOrders,
      cancelledOrders: cancelledOrders,
      grossSales: grossSales,
      totalDeliveryFees: totalDeliveryFees,
      totalShopCommissions: totalCommissions,
      totalPointsRedeemed: totalPointsRedeemed,
      pointsDiscountValue: totalPointsDiscounts,
      freeDeliveryCost: totalFreeDelivery,
      totalAdsRevenue: totalAdsRevenue,
      adminNetRevenue: adminNetRevenue,
    );
  }
}

/// Summary of a shop's settlement for a weekly period.
class ShopSettlementSummary {
  final double grossSales;
  final double totalCommission;
  final double pointsDiscounts;
  final double freeDeliveryCost;
  final double adsCost;
  final double netPayable;
  final double adminNetCommission;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;

  const ShopSettlementSummary({
    required this.grossSales,
    required this.totalCommission,
    required this.pointsDiscounts,
    required this.freeDeliveryCost,
    required this.adsCost,
    required this.netPayable,
    required this.adminNetCommission,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
  });
}

/// Summary of a rider's settlement for a weekly period.
class RiderSettlementSummary {
  final int totalDeliveries;
  final double totalDeliveryFees;
  final double totalCashHandled;
  final double commissionDeducted;
  final double netEarnings;

  const RiderSettlementSummary({
    required this.totalDeliveries,
    required this.totalDeliveryFees,
    required this.totalCashHandled,
    required this.commissionDeducted,
    required this.netEarnings,
  });
}

/// Admin-wide summary across all shops and riders for a weekly period.
class AdminSettlementSummary {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double grossSales;
  final double totalDeliveryFees;
  final double totalShopCommissions;
  final int totalPointsRedeemed;
  final double pointsDiscountValue;
  final double freeDeliveryCost;
  final double totalAdsRevenue;
  final double adminNetRevenue;

  const AdminSettlementSummary({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.grossSales,
    required this.totalDeliveryFees,
    required this.totalShopCommissions,
    required this.totalPointsRedeemed,
    required this.pointsDiscountValue,
    required this.freeDeliveryCost,
    required this.totalAdsRevenue,
    required this.adminNetRevenue,
  });
}