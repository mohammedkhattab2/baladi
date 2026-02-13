// Domain - Business rules for commission calculation.
//
// Pure Dart — no external dependencies. Defines how platform
// commissions are calculated and distributed.

/// Business rules governing commission calculations.
///
/// Commission flow:
/// 1. Shop pays a percentage of subtotal as commission
/// 2. Platform commission = shop commission - points discount - free delivery cost
/// 3. Platform commission cannot go below zero
///
/// Example for a 200 EGP order with 10% commission:
/// - Shop commission: 200 × 0.10 = 20 EGP
/// - If 10 EGP points discount applied: admin gets 20 - 10 = 10 EGP
/// - Shop receives: 200 - 20 = 180 EGP
class CommissionRules {
  CommissionRules._();

  /// Default commission rate (10%).
  static const double defaultCommissionRate = 0.10;

  /// Minimum platform commission (cannot go below zero).
  static const double minimumPlatformCommission = 0.0;

  /// Calculates the commission amount owed by the shop.
  ///
  /// [subtotal] is the sum of all item prices × quantities.
  /// [rate] is the shop's commission rate (e.g. 0.10 for 10%).
  static double calculateShopCommission(double subtotal, double rate) {
    if (subtotal <= 0 || rate <= 0) return 0.0;
    return subtotal * rate;
  }

  /// Calculates the net platform (admin) commission after deductions.
  ///
  /// Points discounts and free delivery costs are absorbed by the
  /// platform, reducing admin revenue — NOT the shop's earnings.
  static double calculatePlatformCommission({
    required double shopCommission,
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    final commission = shopCommission - pointsDiscount - freeDeliveryCost;
    return commission < minimumPlatformCommission
        ? minimumPlatformCommission
        : commission;
  }

  /// Calculates the shop's net earnings from an order.
  ///
  /// Shop earnings = subtotal - shop commission.
  static double calculateShopEarnings(double subtotal, double shopCommission) {
    return subtotal - shopCommission;
  }

  /// Validates whether a discount can be applied without
  /// making the platform commission negative.
  static bool canApplyDiscount(double shopCommission, double totalDiscount) {
    return totalDiscount <= shopCommission;
  }
}