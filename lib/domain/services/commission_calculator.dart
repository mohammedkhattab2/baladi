/// Domain service for commission calculations.
///
/// This service handles all commission-related calculations including
/// store commissions, delivery fees, and platform commissions.
///
/// Critical business rule: Points discounts are ONLY deducted from
/// platform commission - never from store or rider earnings.
library;
import '../rules/commission_rules.dart';

/// Service for calculating commissions and fees.
class CommissionCalculator {
  /// Base delivery fee (fixed for MVP).
  static const double baseDeliveryFee = 10.0;

  /// Per-kilometer delivery fee.
  static const double perKmDeliveryFee = 2.0;

  /// Calculate store commission for an order.
  double calculateStoreCommission(
    double orderSubtotal, {
    double? commissionRate,
  }) {
    return CommissionRules.calculateStoreCommission(
      orderSubtotal,
      commissionRate ?? CommissionRules.defaultStoreCommissionRate,
    );
  }

  /// Calculate delivery fee based on distance.
  ///
  /// Formula: baseDeliveryFee + (distanceKm × perKmDeliveryFee)
  /// Example: 10 + (3 × 2) = 16 EGP
  double calculateDeliveryFee(double distanceKm) {
    if (distanceKm <= 0) return baseDeliveryFee;
    return baseDeliveryFee + (distanceKm * perKmDeliveryFee);
  }

  /// Calculate platform commission after discounts.
  ///
  /// This is a critical calculation that ensures:
  /// 1. Points discounts come from platform only
  /// 2. Free delivery costs come from platform only
  /// 3. Store and rider earnings are never affected
  double calculatePlatformCommission({
    required double storeCommission,
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    return CommissionRules.calculatePlatformCommission(
      storeCommission: storeCommission,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );
  }

  /// Calculate complete order breakdown.
  OrderBreakdown calculateOrderBreakdown({
    required double orderSubtotal,
    required double distanceKm,
    required int pointsUsed,
    required bool isFreeDelivery,
    double? commissionRate,
  }) {
    final rate = commissionRate ?? CommissionRules.defaultStoreCommissionRate;
    final storeCommission = calculateStoreCommission(orderSubtotal, commissionRate: rate);
    final deliveryFee = calculateDeliveryFee(distanceKm);
    final pointsDiscount = pointsUsed.toDouble(); // 1 point = 1 EGP
    final freeDeliveryCost = isFreeDelivery ? deliveryFee : 0.0;

    final platformCommission = calculatePlatformCommission(
      storeCommission: storeCommission,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );

    final storeEarnings = CommissionRules.calculateStoreEarnings(orderSubtotal, storeCommission);
    final riderEarnings = deliveryFee;
    final customerPays = orderSubtotal + (isFreeDelivery ? 0 : deliveryFee) - pointsDiscount;

    return OrderBreakdown(
      orderSubtotal: orderSubtotal,
      deliveryFee: deliveryFee,
      pointsDiscount: pointsDiscount,
      storeCommission: storeCommission,
      platformCommission: platformCommission,
      storeEarnings: storeEarnings,
      riderEarnings: riderEarnings,
      customerPays: customerPays < 0 ? 0 : customerPays,
      isFreeDelivery: isFreeDelivery,
    );
  }

  /// Get minimum platform commission.
  double get minimumPlatformCommission => CommissionRules.minimumPlatformCommission;

  /// Get default store commission rate.
  double get defaultStoreCommissionRate => CommissionRules.defaultStoreCommissionRate;
}

/// Complete breakdown of order financials.
class OrderBreakdown {
  final double orderSubtotal;
  final double deliveryFee;
  final double pointsDiscount;
  final double storeCommission;
  final double platformCommission;
  final double storeEarnings;
  final double riderEarnings;
  final double customerPays;
  final bool isFreeDelivery;

  const OrderBreakdown({
    required this.orderSubtotal,
    required this.deliveryFee,
    required this.pointsDiscount,
    required this.storeCommission,
    required this.platformCommission,
    required this.storeEarnings,
    required this.riderEarnings,
    required this.customerPays,
    required this.isFreeDelivery,
  });

  @override
  String toString() {
    return '''
OrderBreakdown:
  Subtotal: $orderSubtotal EGP
  Delivery Fee: $deliveryFee EGP${isFreeDelivery ? ' (FREE)' : ''}
  Points Discount: $pointsDiscount EGP
  ---
  Customer Pays: $customerPays EGP
  ---
  Store Earnings: $storeEarnings EGP
  Rider Earnings: $riderEarnings EGP
  Platform Commission: $platformCommission EGP
''';
  }
}