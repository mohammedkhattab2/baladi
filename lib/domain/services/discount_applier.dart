// Domain - Service for applying discounts to orders.
//
// Injectable service that coordinates points redemption and
// free delivery promotions using DiscountRules and PointsRules.

import '../rules/discount_rules.dart';
import '../rules/points_rules.dart';
import 'commission_calculator.dart';

/// Immutable result of applying all discounts to an order.
class DiscountResult {
  /// Number of points actually redeemed.
  final int pointsUsed;

  /// Monetary value of redeemed points in EGP.
  final double pointsDiscount;

  /// Whether free delivery was applied.
  final bool isFreeDelivery;

  /// Delivery fee absorbed by the platform (0 if not free).
  final double freeDeliveryCost;

  /// Total discount deducted from platform commission.
  final double totalPlatformDiscount;

  /// Final amount the customer pays.
  final double customerPayableAmount;

  /// Creates a [DiscountResult].
  const DiscountResult({
    required this.pointsUsed,
    required this.pointsDiscount,
    required this.isFreeDelivery,
    required this.freeDeliveryCost,
    required this.totalPlatformDiscount,
    required this.customerPayableAmount,
  });

  /// No discounts applied.
  const DiscountResult.none({
    required double subtotal,
    required double deliveryFee,
  })  : pointsUsed = 0,
        pointsDiscount = 0.0,
        isFreeDelivery = false,
        freeDeliveryCost = 0.0,
        totalPlatformDiscount = 0.0,
        customerPayableAmount = subtotal + deliveryFee;
}

/// Domain service for applying discounts to orders.
///
/// Coordinates points redemption and free delivery promotions.
/// Ensures that all discounts are within platform commission limits
/// so shop earnings are never affected.
class DiscountApplier {
  final CommissionCalculator _commissionCalculator;

  /// Creates a [DiscountApplier] with the required [CommissionCalculator].
  const DiscountApplier({
    required CommissionCalculator commissionCalculator,
  }) : _commissionCalculator = commissionCalculator;

  /// Applies all applicable discounts to an order.
  ///
  /// - [subtotal]: Sum of item prices × quantities.
  /// - [deliveryFee]: Standard delivery fee.
  /// - [commissionRate]: Shop's commission rate.
  /// - [requestedPoints]: Points the customer wants to redeem (0 for none).
  /// - [customerPointsBalance]: Customer's current points balance.
  /// - [isFreeDelivery]: Whether free delivery promotion applies.
  ///
  /// Returns a [DiscountResult] with all computed discount details.
  DiscountResult apply({
    required double subtotal,
    required double deliveryFee,
    required double commissionRate,
    required int requestedPoints,
    required int customerPointsBalance,
    required bool isFreeDelivery,
  }) {
    // Calculate shop commission to determine discount cap
    final breakdown = _commissionCalculator.calculate(
      subtotal: subtotal,
      commissionRate: commissionRate,
    );

    final shopCommission = breakdown.shopCommission;

    // Calculate free delivery cost first (it reduces available commission)
    final freeDeliveryCost = DiscountRules.calculateFreeDeliveryCost(
      isFreeDelivery: isFreeDelivery,
      deliveryFee: deliveryFee,
    );

    // Remaining commission after free delivery
    final remainingCommission = shopCommission - freeDeliveryCost;
    final effectiveRemainingCommission =
        remainingCommission < 0 ? 0.0 : remainingCommission;

    // Calculate effective redeemable points against remaining commission
    int pointsUsed = 0;
    double pointsDiscount = 0.0;

    if (requestedPoints > 0 && customerPointsBalance > 0) {
      // Cap by customer balance
      int effectivePoints = requestedPoints.clamp(0, customerPointsBalance);

      // Cap by remaining commission
      final maxPointsFromCommission =
          PointsRules.currencyToPoints(effectiveRemainingCommission);
      if (effectivePoints > maxPointsFromCommission) {
        effectivePoints = maxPointsFromCommission;
      }

      pointsUsed = effectivePoints;
      pointsDiscount = PointsRules.calculateDiscountValue(pointsUsed);
    }

    // Calculate total platform discount
    final totalPlatformDiscount = DiscountRules.calculateTotalPlatformDiscount(
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );

    // Calculate what the customer actually pays
    final customerPayableAmount = DiscountRules.calculateCustomerPayableAmount(
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      isFreeDelivery: isFreeDelivery,
      pointsDiscount: pointsDiscount,
    );

    return DiscountResult(
      pointsUsed: pointsUsed,
      pointsDiscount: pointsDiscount,
      isFreeDelivery: isFreeDelivery,
      freeDeliveryCost: freeDeliveryCost,
      totalPlatformDiscount: totalPlatformDiscount,
      customerPayableAmount: customerPayableAmount,
    );
  }

  /// Validates whether a points redemption request is valid for an order.
  ///
  /// Returns `null` if valid, or an Arabic error message if invalid.
  String? validateRedemption({
    required int requestedPoints,
    required int customerBalance,
    required double shopCommission,
    double freeDeliveryCost = 0.0,
  }) {
    final remainingCommission = shopCommission - freeDeliveryCost;
    if (remainingCommission <= 0 && requestedPoints > 0) {
      return 'لا يمكن استخدام النقاط مع التوصيل المجاني في هذا الطلب';
    }

    return DiscountRules.validateRedemption(
      requestedPoints: requestedPoints,
      customerBalance: customerBalance,
      shopCommission: remainingCommission < 0 ? 0.0 : remainingCommission,
    );
  }
}