// Domain - Business rules for loyalty points calculation.
//
// Pure Dart — no external dependencies. All points-related
// constants and calculation logic lives here.

/// Business rules governing the loyalty points system.
///
/// Points are earned from completed orders and can be redeemed
/// as discounts on future orders. Referral bonuses also award points.
///
/// Key rules:
/// - 100 EGP spent = 1 point earned
/// - 1 point = 1 EGP discount
/// - Referral bonus = 2 points to the referrer
/// - Points discount is deducted from admin commission ONLY
class PointsRules {
  PointsRules._();

  /// Currency units spent per point earned (100 EGP = 1 point).
  static const double currencyPerPoint = 100.0;

  /// Monetary value of a single point in EGP.
  static const double pointValueInCurrency = 1.0;

  /// Points awarded to the referrer when a referred user completes first order.
  static const int referralBonusPoints = 2;

  /// Minimum order subtotal required to earn points.
  static const double minimumOrderForPoints = 0.0;

  /// Maximum percentage of order subtotal that can be paid with points.
  /// Set to 1.0 (100%) — but actual limit is the platform commission.
  static const double maxPointsRedemptionRatio = 1.0;

  /// Calculates the number of points earned from an order subtotal.
  ///
  /// Points = floor(subtotal / 100).
  /// Example: 350 EGP → 3 points, 99 EGP → 0 points.
  static int calculatePointsEarned(double orderSubtotal) {
    if (orderSubtotal < minimumOrderForPoints) return 0;
    return (orderSubtotal / currencyPerPoint).floor();
  }

  /// Converts points to their monetary discount value in EGP.
  ///
  /// Example: 10 points → 10.0 EGP discount.
  static double calculateDiscountValue(int points) {
    if (points <= 0) return 0.0;
    return points * pointValueInCurrency;
  }

  /// Converts a monetary amount to the equivalent number of points.
  ///
  /// Example: 10.0 EGP → 10 points.
  static int currencyToPoints(double amount) {
    if (amount <= 0) return 0;
    return (amount / pointValueInCurrency).floor();
  }

  /// Returns the maximum number of points that can be redeemed on an order.
  ///
  /// The limit is the smaller of:
  /// - Available points
  /// - Platform commission converted to points (discount cannot exceed commission)
  static int maxRedeemablePoints({
    required int availablePoints,
    required double platformCommission,
  }) {
    final maxFromCommission = currencyToPoints(platformCommission);
    return availablePoints < maxFromCommission
        ? availablePoints
        : maxFromCommission;
  }

  /// Validates whether a points redemption is allowed.
  ///
  /// Returns `null` if valid, or an error message string if invalid.
  static String? validateRedemption({
    required int pointsToUse,
    required int availablePoints,
    required double platformCommission,
  }) {
    if (pointsToUse <= 0) {
      return 'عدد النقاط يجب أن يكون أكبر من صفر';
    }

    if (pointsToUse > availablePoints) {
      return 'رصيد النقاط غير كافي. المتاح: $availablePoints نقطة';
    }

    final discountValue = calculateDiscountValue(pointsToUse);
    if (discountValue > platformCommission) {
      final maxPoints = currencyToPoints(platformCommission);
      return 'الحد الأقصى للاستخدام: $maxPoints نقطة';
    }

    return null; // Valid
  }
}