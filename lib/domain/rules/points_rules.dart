/// Business rules for points calculation.
///
/// All points-related business rules are defined here.
/// This is pure Dart with no external dependencies.
///
/// Architecture note: Business rules live in the domain layer.
/// They define the "what" of business logic, not "how" to execute it.
library;

/// Business rules for the loyalty points system.
///
/// Points Earning Rules:
/// - Orders ≤ 200 EGP → 2 points (minimum)
/// - Orders > 200 EGP → proportional points with minimum 2
///
/// Points Redemption Rules:
/// - 1 point = 1 EGP discount
/// - Discount does NOT reduce store or rider earnings
/// - Platform bears the discount cost
/// - Points value is added to store's weekly commission account
class PointsRules {
  PointsRules._();

  /// Minimum points earned per order.
  static const int minimumPointsPerOrder = 2;

  /// Threshold for minimum points (orders at or below this get minimum points).
  static const double minimumPointsThreshold = 200.0;

  /// Points earned per currency unit above threshold.
  /// For every 100 EGP above 200, earn 1 additional point.
  static const double currencyPerAdditionalPoint = 100.0;

  /// Point value in currency.
  /// 1 point = 1 EGP
  static const double pointValueInCurrency = 1.0;

  /// Referral bonus points awarded when referred user completes first order.
  static const int referralBonusPoints = 2;

  /// Minimum order amount to earn points.
  static const double minimumOrderForPoints = 0.0;

  /// Maximum points that can be redeemed per order (as percentage of order).
  /// null means no limit based on order amount.
  static const double? maxRedemptionPercentage = null;

  /// Calculate points earned from order amount.
  ///
  /// Rules:
  /// - Orders ≤ 200 EGP → 2 points (minimum)
  /// - Orders > 200 EGP → 2 + floor((amount - 200) / 100) points
  ///
  /// Examples:
  /// - 100 EGP = 2 points (minimum)
  /// - 200 EGP = 2 points (minimum)
  /// - 250 EGP = 2 points (2 + floor(50/100) = 2)
  /// - 350 EGP = 3 points (2 + floor(150/100) = 3)
  /// - 500 EGP = 5 points (2 + floor(300/100) = 5)
  static int calculatePointsEarned(double orderAmount) {
    if (orderAmount < minimumOrderForPoints) return 0;
    
    // Orders at or below threshold get minimum points
    if (orderAmount <= minimumPointsThreshold) {
      return minimumPointsPerOrder;
    }
    
    // Orders above threshold: minimum + proportional additional points
    final amountAboveThreshold = orderAmount - minimumPointsThreshold;
    final additionalPoints = (amountAboveThreshold / currencyPerAdditionalPoint).floor();
    
    return minimumPointsPerOrder + additionalPoints;
  }

  /// Calculate discount value from points.
  /// 
  /// Formula: points * 1.0
  /// Example: 10 points = 10 EGP discount
  static double calculateDiscountValue(int points) {
    if (points <= 0) return 0;
    return points * pointValueInCurrency;
  }

  /// Calculate maximum points that can be redeemed for an order.
  /// 
  /// The discount cannot exceed the platform commission.
  static int calculateMaxRedeemablePoints({
    required double platformCommission,
    required int availablePoints,
  }) {
    // Points discount cannot exceed platform commission
    final maxByCommission = platformCommission.floor();
    
    // Cannot use more than available
    return maxByCommission < availablePoints ? maxByCommission : availablePoints;
  }

  /// Validate if points redemption is valid.
  static PointsValidationResult validateRedemption({
    required int pointsToUse,
    required int availablePoints,
    required double platformCommission,
  }) {
    if (pointsToUse <= 0) {
      return PointsValidationResult.invalid('Points must be greater than 0');
    }

    if (pointsToUse > availablePoints) {
      return PointsValidationResult.invalid(
        'Insufficient points. Available: $availablePoints',
      );
    }

    final discountValue = calculateDiscountValue(pointsToUse);
    if (discountValue > platformCommission) {
      final maxPoints = calculateMaxRedeemablePoints(
        platformCommission: platformCommission,
        availablePoints: availablePoints,
      );
      return PointsValidationResult.invalid(
        'Maximum points allowed for this order: $maxPoints',
      );
    }

    return PointsValidationResult.valid(discountValue);
  }
}

/// Result of points validation.
class PointsValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? discountValue;

  const PointsValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.discountValue,
  });

  factory PointsValidationResult.valid(double discountValue) {
    return PointsValidationResult._(
      isValid: true,
      discountValue: discountValue,
    );
  }

  factory PointsValidationResult.invalid(String message) {
    return PointsValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}