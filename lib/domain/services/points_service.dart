/// Domain service for loyalty points operations.
///
/// This service encapsulates all points-related business logic including:
/// - Points earning calculation
/// - Points redemption and discount application
/// - Recording points usage for store weekly settlement
///
/// Key Business Rules:
/// - Points earning: ≤200 EGP = 2 points, >200 EGP = proportional with min 2
/// - Points redemption: 1 point = 1 EGP discount
/// - Discount does NOT reduce store or rider earnings
/// - Platform bears the discount cost
/// - Points value is added to store's weekly commission account
///
/// Architecture note: Domain services contain complex logic that
/// doesn't fit in entities or use cases. They are orchestrated by use cases.
library;

import '../rules/points_rules.dart';

/// Result of applying points to an order.
class PointsApplicationResult {
  /// The original order total before points discount.
  final double originalTotal;

  /// Number of points actually used.
  final int pointsUsed;

  /// Monetary value of the points discount (1 point = 1 EGP).
  final double discountAmount;

  /// New order total after applying points discount.
  final double newTotal;

  /// Amount to be added to store's weekly commission account.
  /// This equals the discount amount - platform bears the cost.
  final double storeWeeklyCommissionCredit;

  const PointsApplicationResult({
    required this.originalTotal,
    required this.pointsUsed,
    required this.discountAmount,
    required this.newTotal,
    required this.storeWeeklyCommissionCredit,
  });

  /// Whether any points were applied.
  bool get hasDiscount => pointsUsed > 0;

  @override
  String toString() =>
      'PointsApplicationResult(pointsUsed: $pointsUsed, discount: $discountAmount, newTotal: $newTotal)';
}

/// Record of points usage for settlement.
class PointsUsageRecord {
  /// Order ID this usage is associated with.
  final String orderId;

  /// Store ID that receives the weekly commission credit.
  final String storeId;

  /// Number of points used.
  final int pointsUsed;

  /// Monetary value of the points (equals discount given to customer).
  final double monetaryValue;

  /// Timestamp of the usage.
  final DateTime usedAt;

  const PointsUsageRecord({
    required this.orderId,
    required this.storeId,
    required this.pointsUsed,
    required this.monetaryValue,
    required this.usedAt,
  });
}

/// Service for managing loyalty points operations.
///
/// This service ensures that:
/// 1. Points are earned correctly based on order amounts
/// 2. Points redemption only affects customer payment, not store/rider earnings
/// 3. Platform bears the cost of points discounts
/// 4. Store receives credit in weekly settlement for points redeemed
class PointsService {
  /// Calculate points earned from an order subtotal.
  ///
  /// Rules:
  /// - Orders ≤ 200 EGP → 2 points (minimum)
  /// - Orders > 200 EGP → 2 + floor((amount - 200) / 100) points
  ///
  /// [orderSubtotal] The order subtotal (items only, before delivery/discounts).
  /// Returns the number of points to be earned.
  int calculateEarnedPoints(double orderSubtotal) {
    return PointsRules.calculatePointsEarned(orderSubtotal);
  }

  /// Apply points to an order total and calculate the discount.
  ///
  /// This method:
  /// 1. Validates the points can be used
  /// 2. Calculates the discount (1 point = 1 EGP)
  /// 3. Returns the new order total
  /// 4. Calculates the store weekly commission credit
  ///
  /// Important: The discount does NOT affect store or rider earnings.
  /// The store and rider still receive their full amounts.
  /// The platform bears the cost, which is tracked as a credit
  /// to the store's weekly commission account.
  ///
  /// [orderTotal] The original order total (after delivery fee).
  /// [pointsToUse] Number of points the customer wants to use.
  /// [availablePoints] Customer's available points balance.
  /// [maxRedeemablePoints] Maximum points allowed (based on platform commission).
  ///
  /// Returns [PointsApplicationResult] with discount details.
  PointsApplicationResult applyPoints({
    required double orderTotal,
    required int pointsToUse,
    required int availablePoints,
    int? maxRedeemablePoints,
  }) {
    // Validate points to use
    if (pointsToUse <= 0) {
      return PointsApplicationResult(
        originalTotal: orderTotal,
        pointsUsed: 0,
        discountAmount: 0,
        newTotal: orderTotal,
        storeWeeklyCommissionCredit: 0,
      );
    }

    // Cannot use more than available
    int actualPointsToUse = pointsToUse;
    if (actualPointsToUse > availablePoints) {
      actualPointsToUse = availablePoints;
    }

    // Cannot exceed maximum redeemable (based on platform commission)
    if (maxRedeemablePoints != null && actualPointsToUse > maxRedeemablePoints) {
      actualPointsToUse = maxRedeemablePoints;
    }

    // Calculate discount value (1 point = 1 EGP)
    final discountAmount = PointsRules.calculateDiscountValue(actualPointsToUse);

    // Discount cannot exceed order total
    final finalDiscount = discountAmount > orderTotal ? orderTotal : discountAmount;
    final finalPointsUsed =
        finalDiscount < discountAmount ? (finalDiscount / PointsRules.pointValueInCurrency).floor() : actualPointsToUse;

    // Calculate new total
    final newTotal = orderTotal - finalDiscount;

    // Store receives credit for the discount amount in weekly settlement
    // This ensures the store doesn't lose money from customer's points usage
    final storeCredit = finalDiscount;

    return PointsApplicationResult(
      originalTotal: orderTotal,
      pointsUsed: finalPointsUsed,
      discountAmount: finalDiscount,
      newTotal: newTotal,
      storeWeeklyCommissionCredit: storeCredit,
    );
  }

  /// Create a points usage record for settlement tracking.
  ///
  /// This record is used during weekly settlement to credit the store
  /// with the monetary value of points redeemed on their orders.
  ///
  /// [orderId] The order where points were redeemed.
  /// [storeId] The store that will receive the weekly credit.
  /// [pointsUsed] Number of points redeemed.
  /// [monetaryValue] Monetary value of the points (discount amount).
  ///
  /// Returns [PointsUsageRecord] for settlement processing.
  PointsUsageRecord recordPointsUsage({
    required String orderId,
    required String storeId,
    required int pointsUsed,
    required double monetaryValue,
  }) {
    return PointsUsageRecord(
      orderId: orderId,
      storeId: storeId,
      pointsUsed: pointsUsed,
      monetaryValue: monetaryValue,
      usedAt: DateTime.now(),
    );
  }

  /// Calculate the store's weekly commission credit from points redemptions.
  ///
  /// When customers use points, the store still receives their full earnings.
  /// The platform covers the discount, which is tracked as a credit
  /// to be paid to the store in the weekly settlement.
  ///
  /// [pointsUsageRecords] All points usage records for the week.
  /// [storeId] The store to calculate credit for.
  ///
  /// Returns total credit amount for the store.
  double calculateStoreWeeklyPointsCredit({
    required List<PointsUsageRecord> pointsUsageRecords,
    required String storeId,
  }) {
    return pointsUsageRecords
        .where((record) => record.storeId == storeId)
        .fold(0.0, (sum, record) => sum + record.monetaryValue);
  }

  /// Validate if points redemption is allowed for an order.
  ///
  /// [pointsToUse] Number of points to validate.
  /// [availablePoints] Customer's available balance.
  /// [platformCommission] Platform commission amount (max redeemable limit).
  ///
  /// Returns validation result with error message if invalid.
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

  /// Get maximum redeemable points for an order.
  ///
  /// [platformCommission] Platform commission amount.
  /// [availablePoints] Customer's available balance.
  ///
  /// Returns maximum points that can be redeemed.
  int getMaxRedeemablePoints({
    required double platformCommission,
    required int availablePoints,
  }) {
    return PointsRules.calculateMaxRedeemablePoints(
      platformCommission: platformCommission,
      availablePoints: availablePoints,
    );
  }
}