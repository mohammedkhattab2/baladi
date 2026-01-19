/// Business rules for commission calculation.
/// 
/// All commission-related business rules are defined here.
/// This is pure Dart with no external dependencies.
/// 
/// Architecture note: Commission rules are critical for financial
/// integrity. Points discounts ONLY affect platform commission,
/// NEVER store or rider earnings.
library;
/// Business rules for commission calculations.
class CommissionRules {
  CommissionRules._();

  /// Default store commission rate (10%).
  static const double defaultStoreCommissionRate = 0.10;

  /// Minimum store commission rate.
  static const double minStoreCommissionRate = 0.05;

  /// Maximum store commission rate.
  static const double maxStoreCommissionRate = 0.30;

  /// Minimum platform commission (cannot go below 0).
  static const double minimumPlatformCommission = 0.0;

  /// Calculate store commission amount.
  /// 
  /// Formula: subtotal × commissionRate
  /// Example: 200 EGP × 10% = 20 EGP
  static double calculateStoreCommission(double subtotal, double rate) {
    if (subtotal <= 0) return 0;
    if (rate <= 0) return 0;
    return subtotal * rate;
  }

  /// Calculate platform commission after deductions.
  /// 
  /// CRITICAL RULE: Points discount and free delivery cost
  /// are deducted ONLY from platform commission, NEVER from
  /// store earnings.
  /// 
  /// Formula: storeCommission - pointsDiscount - freeDeliveryCost
  static double calculatePlatformCommission({
    required double storeCommission,
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    final commission = storeCommission - pointsDiscount - freeDeliveryCost;
    return commission < minimumPlatformCommission
        ? minimumPlatformCommission
        : commission;
  }

  /// Calculate store earnings (what store receives).
  /// 
  /// Formula: subtotal - storeCommission
  /// This is NEVER affected by points discount or free delivery.
  static double calculateStoreEarnings(double subtotal, double storeCommission) {
    return subtotal - storeCommission;
  }

  /// Validate if commission rate is within allowed bounds.
  static bool isValidCommissionRate(double rate) {
    return rate >= minStoreCommissionRate && rate <= maxStoreCommissionRate;
  }

  /// Validate if discount can be applied.
  /// 
  /// Discount cannot exceed the platform commission amount.
  static bool canApplyDiscount(double storeCommission, double discount) {
    return discount <= storeCommission;
  }

  /// Calculate full commission breakdown for an order.
  static CommissionBreakdown calculateBreakdown({
    required double subtotal,
    required double commissionRate,
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    final storeCommission = calculateStoreCommission(subtotal, commissionRate);
    final platformCommission = calculatePlatformCommission(
      storeCommission: storeCommission,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );
    final storeEarnings = calculateStoreEarnings(subtotal, storeCommission);

    return CommissionBreakdown(
      subtotal: subtotal,
      commissionRate: commissionRate,
      storeCommission: storeCommission,
      platformCommission: platformCommission,
      storeEarnings: storeEarnings,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );
  }
}

/// Result of commission calculation.
class CommissionBreakdown {
  /// Order subtotal.
  final double subtotal;

  /// Commission rate applied.
  final double commissionRate;

  /// Commission amount (before deductions).
  final double storeCommission;

  /// Platform commission (after deductions).
  final double platformCommission;

  /// Store earnings (subtotal - commission).
  final double storeEarnings;

  /// Points discount deducted from platform commission.
  final double pointsDiscount;

  /// Free delivery cost deducted from platform commission.
  final double freeDeliveryCost;

  const CommissionBreakdown({
    required this.subtotal,
    required this.commissionRate,
    required this.storeCommission,
    required this.platformCommission,
    required this.storeEarnings,
    required this.pointsDiscount,
    required this.freeDeliveryCost,
  });

  /// Total deductions from platform commission.
  double get totalDeductions => pointsDiscount + freeDeliveryCost;

  @override
  String toString() => 'CommissionBreakdown('
      'subtotal: $subtotal, '
      'storeCommission: $storeCommission, '
      'platformCommission: $platformCommission, '
      'storeEarnings: $storeEarnings)';
}