/// Domain service for points calculations.
/// 
/// This service encapsulates all points-related business logic.
/// It uses the rules from PointsRules but provides a more
/// convenient interface for use cases.
/// 
/// Architecture note: Domain services contain complex logic that
/// doesn't fit in entities or use cases. They are orchestrated
/// by use cases.
library;
import '../rules/points_rules.dart';

/// Service for calculating and validating points operations.
class PointsCalculator {
  /// Calculate points earned from an order.
  int calculateEarnedPoints(double orderSubtotal) {
    return PointsRules.calculatePointsEarned(orderSubtotal);
  }

  /// Calculate discount value from points.
  double calculateDiscountValue(int pointsToUse) {
    return PointsRules.calculateDiscountValue(pointsToUse);
  }

  /// Calculate maximum redeemable points for an order.
  int calculateMaxRedeemablePoints({
    required double platformCommission,
    required int availablePoints,
  }) {
    return PointsRules.calculateMaxRedeemablePoints(
      platformCommission: platformCommission,
      availablePoints: availablePoints,
    );
  }

  /// Validate if points can be redeemed.
  PointsValidationResult validatePointsRedemption({
    required int pointsToUse,
    required int availablePoints,
    required double platformCommission,
  }) {
    return PointsRules.validateRedemption(
      pointsToUse: pointsToUse,
      availablePoints: availablePoints,
      platformCommission: platformCommission,
    );
  }

  /// Calculate referral bonus points.
  int getReferralBonusPoints() {
    return PointsRules.referralBonusPoints;
  }
}