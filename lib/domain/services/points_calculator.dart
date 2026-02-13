// Domain - Service for points calculations.
//
// Injectable service that wraps PointsRules for calculating
// earned points, discount values, and validating redemptions.

import '../rules/points_rules.dart';

/// Domain service for loyalty points calculations.
///
/// Wraps [PointsRules] to provide an injectable, testable interface
/// for points-related business logic. Use cases delegate to this
/// service rather than calling rules directly.
class PointsCalculator {
  /// Creates a [PointsCalculator] instance.
  const PointsCalculator();

  /// Calculates points earned from a completed order.
  ///
  /// - [orderTotal]: The total order amount in EGP (after discounts).
  /// Returns the number of points earned (1 point per 100 EGP).
  int calculateEarnedPoints(double orderTotal) {
    return PointsRules.calculatePointsEarned(orderTotal);
  }

  /// Calculates the monetary discount value for the given [points].
  ///
  /// - [points]: Number of points to convert.
  /// Returns the discount amount in EGP (1 point = 1 EGP).
  double calculateDiscountValue(int points) {
    return PointsRules.calculateDiscountValue(points);
  }

  /// Converts a currency amount to equivalent points.
  ///
  /// - [amount]: Amount in EGP to convert.
  /// Returns the number of points equivalent.
  int convertCurrencyToPoints(double amount) {
    return PointsRules.currencyToPoints(amount);
  }

  /// Calculates the maximum number of points redeemable for an order.
  ///
  /// Capped by the customer's balance and the platform commission share.
  ///
  /// - [availablePoints]: Customer's current points balance.
  /// - [platformCommission]: The platform's commission share on the order.
  /// Returns the maximum redeemable points.
  int calculateMaxRedeemablePoints({
    required int availablePoints,
    required double platformCommission,
  }) {
    return PointsRules.maxRedeemablePoints(
      availablePoints: availablePoints,
      platformCommission: platformCommission,
    );
  }

  /// Validates a points redemption request.
  ///
  /// Returns `null` if valid, or an Arabic error message if invalid.
  String? validateRedemption({
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

  /// Returns the referral bonus points amount.
  int get referralBonusPoints => PointsRules.referralBonusPoints;

  /// Returns the currency-per-point rate.
  double get currencyPerPoint => PointsRules.currencyPerPoint;

  /// Returns the point value in currency.
  double get pointValueInCurrency => PointsRules.pointValueInCurrency;
}