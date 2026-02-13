// Domain - Business rules for discount application.
//
// Pure Dart — no external dependencies. Defines rules for
// applying points discounts and free delivery promotions.

import 'points_rules.dart';

/// Business rules governing discount application on orders.
///
/// Key rules:
/// - Points discount is deducted from admin commission, NOT from shop earnings
/// - Free delivery cost is absorbed by the platform (admin)
/// - Maximum discount cannot exceed the admin's commission share
/// - Points discount converts at 1 point = 1 EGP
/// - Customer must have enough points balance to redeem
class DiscountRules {
  DiscountRules._();

  /// Minimum points required to redeem (must have at least 1 point).
  static const int minimumRedeemablePoints = 1;

  /// Calculates the effective points discount that can be applied to an order.
  ///
  /// The discount cannot exceed the admin's commission share because
  /// points discounts are deducted from the platform commission.
  ///
  /// - [requestedPoints]: Points the customer wants to redeem.
  /// - [customerBalance]: Customer's current points balance.
  /// - [shopCommission]: The total shop commission (subtotal × rate).
  ///
  /// Returns the actual number of points that can be redeemed.
  static int calculateEffectiveRedeemablePoints({
    required int requestedPoints,
    required int customerBalance,
    required double shopCommission,
  }) {
    if (requestedPoints <= 0 || customerBalance <= 0) return 0;

    // Cannot redeem more than customer has
    int effective = requestedPoints.clamp(0, customerBalance);

    // Convert to currency to check against commission cap
    final discountValue = PointsRules.calculateDiscountValue(effective);

    // Discount cannot exceed admin commission
    if (discountValue > shopCommission) {
      // Reduce points to fit within commission
      effective = PointsRules.currencyToPoints(shopCommission);
    }

    return effective.clamp(0, customerBalance);
  }

  /// Calculates the monetary value of the points discount.
  ///
  /// - [points]: Number of points to redeem.
  /// Returns the discount amount in EGP.
  static double calculatePointsDiscountValue(int points) {
    return PointsRules.calculateDiscountValue(points);
  }

  /// Determines if free delivery should be applied.
  ///
  /// In the MVP, free delivery can be granted through promotions
  /// or admin decisions. The cost is absorbed by the platform.
  ///
  /// - [isFreeDelivery]: Whether free delivery flag is set.
  /// - [deliveryFee]: The standard delivery fee.
  ///
  /// Returns the delivery fee cost absorbed by the platform (0 if not free).
  static double calculateFreeDeliveryCost({
    required bool isFreeDelivery,
    required double deliveryFee,
  }) {
    return isFreeDelivery ? deliveryFee : 0.0;
  }

  /// Calculates the total discount value (points + free delivery).
  ///
  /// - [pointsDiscount]: Monetary value of redeemed points.
  /// - [freeDeliveryCost]: Delivery fee absorbed by platform.
  ///
  /// Returns the combined discount amount deducted from admin commission.
  static double calculateTotalPlatformDiscount({
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    return pointsDiscount + freeDeliveryCost;
  }

  /// Calculates the final amount the customer pays.
  ///
  /// - [subtotal]: Sum of item prices × quantities.
  /// - [deliveryFee]: Standard delivery fee.
  /// - [isFreeDelivery]: Whether delivery is free.
  /// - [pointsDiscount]: Monetary value of redeemed points.
  ///
  /// Returns the total amount the customer must pay in cash.
  static double calculateCustomerPayableAmount({
    required double subtotal,
    required double deliveryFee,
    required bool isFreeDelivery,
    required double pointsDiscount,
  }) {
    final effectiveDeliveryFee = isFreeDelivery ? 0.0 : deliveryFee;
    final total = subtotal + effectiveDeliveryFee - pointsDiscount;
    // Ensure non-negative
    return total < 0 ? 0.0 : total;
  }

  /// Validates whether a points redemption request is valid.
  ///
  /// Returns `null` if valid, or an Arabic error message if invalid.
  static String? validateRedemption({
    required int requestedPoints,
    required int customerBalance,
    required double shopCommission,
  }) {
    if (requestedPoints <= 0) {
      return 'عدد النقاط يجب أن يكون أكبر من صفر';
    }

    if (requestedPoints > customerBalance) {
      return 'رصيد النقاط غير كافٍ (المتاح: $customerBalance نقطة)';
    }

    final discountValue = PointsRules.calculateDiscountValue(requestedPoints);
    if (discountValue > shopCommission) {
      final maxPoints = PointsRules.currencyToPoints(shopCommission);
      return 'الحد الأقصى للاستبدال $maxPoints نقطة في هذا الطلب';
    }

    return null;
  }
}