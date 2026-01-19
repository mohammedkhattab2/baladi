/// Domain service for order processing.
///
/// This service orchestrates order-related business logic including
/// validation, status transitions, and financial calculations.
///
/// Architecture note: This service is used by use cases to handle
/// complex order operations that span multiple rules and calculations.
library;
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../enums/order_status.dart';
import '../rules/order_rules.dart';
import 'commission_calculator.dart';
import 'points_calculator.dart';

/// Service for processing orders.
class OrderProcessor {
  final CommissionCalculator _commissionCalculator;
  final PointsCalculator _pointsCalculator;

  OrderProcessor({
    CommissionCalculator? commissionCalculator,
    PointsCalculator? pointsCalculator,
  })  : _commissionCalculator = commissionCalculator ?? CommissionCalculator(),
        _pointsCalculator = pointsCalculator ?? PointsCalculator();

  /// Validate if an order can be placed using OrderItemInput.
  OrderProcessorValidationResult validateOrderInput({
    required List<OrderItemInput> items,
    required String? deliveryAddress,
    double? minimumOrder,
  }) {
    final result = OrderRules.validateOrder(
      items: items,
      deliveryAddress: deliveryAddress,
      minimumOrder: minimumOrder,
    );

    return OrderProcessorValidationResult(
      isValid: result.isValid,
      errors: result.isValid ? [] : [result.errorMessage!],
      subtotal: result.subtotal,
    );
  }

  /// Validate an existing order entity.
  OrderProcessorValidationResult validateOrder(Order order) {
    final errors = <String>[];

    // Check maximum items
    if (order.items.length > OrderRules.maximumItemsPerOrder) {
      errors.add('Order cannot have more than ${OrderRules.maximumItemsPerOrder} items');
    }

    // Check if order has items
    if (order.items.isEmpty) {
      errors.add('Order must have at least one item');
    }

    // Check delivery address
    final addressResult = OrderRules.validateDeliveryAddress(order.deliveryAddress);
    if (!addressResult.isValid) {
      errors.add(addressResult.errorMessage!);
    }

    return OrderProcessorValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      subtotal: order.subtotal,
    );
  }

  /// Validate status transition using OrderStatus.allowedTransitions.
  StatusTransitionResult validateStatusTransition(
    OrderStatus currentStatus,
    OrderStatus newStatus,
  ) {
    final allowed = currentStatus.allowedTransitions;
    final canTransition = allowed.contains(newStatus);

    if (!canTransition) {
      return StatusTransitionResult(
        canTransition: false,
        reason: 'Cannot transition from ${currentStatus.name} to ${newStatus.name}',
        allowedTransitions: allowed,
      );
    }

    return StatusTransitionResult(
      canTransition: true,
      allowedTransitions: allowed,
    );
  }

  /// Calculate complete order financials.
  OrderFinancials calculateFinancials({
    required double subtotal,
    required double distanceKm,
    required int pointsToUse,
    required int availablePoints,
    required bool isFreeDelivery,
    double? storeCommissionRate,
  }) {
    // Calculate base breakdown
    final breakdown = _commissionCalculator.calculateOrderBreakdown(
      orderSubtotal: subtotal,
      distanceKm: distanceKm,
      pointsUsed: 0, // Calculate without points first
      isFreeDelivery: isFreeDelivery,
      commissionRate: storeCommissionRate,
    );

    // Validate and calculate actual points to use
    final maxRedeemable = _pointsCalculator.calculateMaxRedeemablePoints(
      platformCommission: breakdown.platformCommission,
      availablePoints: availablePoints,
    );

    final actualPointsToUse = pointsToUse > maxRedeemable ? maxRedeemable : pointsToUse;

    // Recalculate with actual points
    final finalBreakdown = _commissionCalculator.calculateOrderBreakdown(
      orderSubtotal: subtotal,
      distanceKm: distanceKm,
      pointsUsed: actualPointsToUse,
      isFreeDelivery: isFreeDelivery,
      commissionRate: storeCommissionRate,
    );

    // Calculate points to be earned
    final pointsEarned = _pointsCalculator.calculateEarnedPoints(subtotal);

    return OrderFinancials(
      breakdown: finalBreakdown,
      pointsUsed: actualPointsToUse,
      pointsEarned: pointsEarned,
      maxRedeemablePoints: maxRedeemable,
    );
  }

  /// Check if order can be cancelled based on status.
  /// Cancellation is only allowed in pending or accepted states.
  bool canCancel(OrderStatus currentStatus) {
    return currentStatus.allowedTransitions.contains(OrderStatus.cancelled);
  }

  /// Get order timeout durations based on status.
  /// Returns null if no timeout applies.
  Duration? getTimeoutDuration(OrderStatus status) {
    return switch (status) {
      OrderStatus.pending => const Duration(minutes: 10),
      OrderStatus.accepted => const Duration(minutes: 30),
      OrderStatus.preparing => const Duration(hours: 1),
      OrderStatus.pickedUp => const Duration(hours: 2),
      OrderStatus.shopPaid => const Duration(minutes: 30),
      OrderStatus.completed => null,
      OrderStatus.cancelled => null,
    };
  }
}

/// Result of order validation from processor.
class OrderProcessorValidationResult {
  final bool isValid;
  final List<String> errors;
  final double? subtotal;

  const OrderProcessorValidationResult({
    required this.isValid,
    required this.errors,
    this.subtotal,
  });
}

/// Result of status transition validation.
class StatusTransitionResult {
  final bool canTransition;
  final String? reason;
  final List<OrderStatus> allowedTransitions;

  const StatusTransitionResult({
    required this.canTransition,
    this.reason,
    required this.allowedTransitions,
  });
}

/// Complete financial breakdown for an order.
class OrderFinancials {
  final OrderBreakdown breakdown;
  final int pointsUsed;
  final int pointsEarned;
  final int maxRedeemablePoints;

  const OrderFinancials({
    required this.breakdown,
    required this.pointsUsed,
    required this.pointsEarned,
    required this.maxRedeemablePoints,
  });

  /// Customer total to pay.
  double get customerPays => breakdown.customerPays;

  /// Store earnings.
  double get storeEarnings => breakdown.storeEarnings;

  /// Rider earnings.
  double get riderEarnings => breakdown.riderEarnings;

  /// Platform commission.
  double get platformCommission => breakdown.platformCommission;
}