// Domain - Service for commission calculations.
//
// Injectable service that wraps CommissionRules for calculating
// shop commissions, platform commissions, and shop earnings.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../rules/commission_rules.dart';

/// Immutable breakdown of all commission-related amounts for an order.
class CommissionBreakdown extends Equatable {
  /// The gross commission owed by the shop (subtotal × rate).
  final double shopCommission;

  /// The net platform (admin) commission after deductions.
  final double platformCommission;

  /// The shop's net earnings (subtotal − shopCommission).
  final double shopEarnings;

  /// Points discount absorbed by the platform.
  final double pointsDiscount;

  /// Free delivery cost absorbed by the platform.
  final double freeDeliveryCost;

  /// Creates a [CommissionBreakdown].
  const CommissionBreakdown({
    required this.shopCommission,
    required this.platformCommission,
    required this.shopEarnings,
    required this.pointsDiscount,
    required this.freeDeliveryCost,
  });

  @override
  List<Object?> get props => [
        shopCommission,
        platformCommission,
        shopEarnings,
        pointsDiscount,
        freeDeliveryCost,
      ];
}

/// Domain service for commission calculations.
///
/// Wraps [CommissionRules] to provide an injectable, testable interface
/// for commission-related business logic. Returns a [CommissionBreakdown]
/// containing all financial details for an order.
@injectable
class CommissionCalculator {
  /// Creates a [CommissionCalculator] instance.
  const CommissionCalculator();

  /// Calculates the full commission breakdown for an order.
  ///
  /// - [subtotal]: Sum of all item prices × quantities.
  /// - [commissionRate]: The shop's commission rate (e.g. 0.10).
  /// - [pointsDiscount]: Monetary value of redeemed points (default 0).
  /// - [freeDeliveryCost]: Delivery fee absorbed by platform (default 0).
  ///
  /// Returns a [CommissionBreakdown] with all computed amounts.
  CommissionBreakdown calculate({
    required double subtotal,
    required double commissionRate,
    double pointsDiscount = 0.0,
    double freeDeliveryCost = 0.0,
  }) {
    final shopCommission = CommissionRules.calculateShopCommission(
      subtotal,
      commissionRate,
    );

    final platformCommission = CommissionRules.calculatePlatformCommission(
      shopCommission: shopCommission,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );

    final shopEarnings = CommissionRules.calculateShopEarnings(
      subtotal,
      shopCommission,
    );

    return CommissionBreakdown(
      shopCommission: shopCommission,
      platformCommission: platformCommission,
      shopEarnings: shopEarnings,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );
  }

  /// Checks whether a given total discount can be applied without
  /// making the platform commission negative.
  ///
  /// - [shopCommission]: The gross commission amount.
  /// - [totalDiscount]: Combined points discount + free delivery cost.
  bool canApplyDiscount({
    required double shopCommission,
    required double totalDiscount,
  }) {
    return CommissionRules.canApplyDiscount(shopCommission, totalDiscount);
  }

  /// Returns the default commission rate.
  double get defaultRate => CommissionRules.defaultCommissionRate;
}