/// Personal Commission Service.
///
/// This service calculates personal commissions that are tracked separately
/// from store earnings, delivery rider earnings, and platform revenue.
///
/// Architecture note: This is a domain service containing pure business logic.
/// It should be called by use cases and does NOT affect other financial calculations.
///
/// IMPORTANT: Personal commissions are for internal tracking only and
/// do NOT reduce payments to stores or delivery riders.
library;
/// Personal commission calculation result.
class PersonalCommissionResult {
  /// Commission from store (5% of order subtotal).
  final double fromStore;

  /// Commission from delivery (15% of delivery fee).
  final double fromDelivery;

  /// Total personal commission.
  final double total;

  /// Order subtotal used for calculation.
  final double orderSubtotal;

  /// Delivery fee used for calculation.
  final double deliveryFee;

  const PersonalCommissionResult({
    required this.fromStore,
    required this.fromDelivery,
    required this.total,
    required this.orderSubtotal,
    required this.deliveryFee,
  });

  @override
  String toString() => 'PersonalCommissionResult('
      'fromStore: $fromStore, '
      'fromDelivery: $fromDelivery, '
      'total: $total)';
}

/// Service for calculating personal commissions.
///
/// Personal commissions are tracked separately and do NOT affect:
/// - Store earnings
/// - Delivery rider earnings
/// - Platform commission calculations
class PersonalCommissionService {
  /// Personal commission rate from store earnings.
  /// 5% of order subtotal.
  static const double storeCommissionRate = 0.05;

  /// Personal commission rate from delivery fee.
  /// 15% of the fixed delivery fee.
  static const double deliveryCommissionRate = 0.15;

  /// Fixed delivery fee in EGP.
  static const double defaultDeliveryFee = 10.0;

  /// Calculate personal commission from store.
  ///
  /// Returns 5% of the order subtotal.
  ///
  /// [orderSubtotal] - Total value of items in the order (before delivery).
  ///
  /// Example:
  /// ```dart
  /// final commission = commissionFromStore(200.0); // Returns 10.0 EGP
  /// ```
  double commissionFromStore(double orderSubtotal) {
    if (orderSubtotal < 0) return 0;
    return _roundToTwoDecimals(orderSubtotal * storeCommissionRate);
  }

  /// Calculate personal commission from delivery.
  ///
  /// Returns 15% of the delivery fee (default 10 EGP = 1.5 EGP).
  ///
  /// [fixedDeliveryFee] - The delivery fee charged (default: 10 EGP).
  ///
  /// Example:
  /// ```dart
  /// final commission = commissionFromDelivery(); // Returns 1.5 EGP
  /// ```
  double commissionFromDelivery([double fixedDeliveryFee = defaultDeliveryFee]) {
    if (fixedDeliveryFee < 0) return 0;
    return _roundToTwoDecimals(fixedDeliveryFee * deliveryCommissionRate);
  }

  /// Calculate total personal commission for an order.
  ///
  /// Combines store commission (5% of subtotal) and delivery commission (1.5 EGP).
  ///
  /// [orderSubtotal] - Total value of items in the order.
  /// [deliveryFee] - The delivery fee charged (default: 10 EGP).
  /// [isFreeDelivery] - If true, no delivery commission is calculated.
  ///
  /// Returns a [PersonalCommissionResult] with detailed breakdown.
  PersonalCommissionResult calculateTotalCommission({
    required double orderSubtotal,
    double deliveryFee = defaultDeliveryFee,
    bool isFreeDelivery = false,
  }) {
    final fromStore = commissionFromStore(orderSubtotal);
    final fromDelivery = isFreeDelivery ? 0.0 : commissionFromDelivery(deliveryFee);
    final total = _roundToTwoDecimals(fromStore + fromDelivery);

    return PersonalCommissionResult(
      fromStore: fromStore,
      fromDelivery: fromDelivery,
      total: total,
      orderSubtotal: orderSubtotal,
      deliveryFee: deliveryFee,
    );
  }

  /// Round to 2 decimal places for currency precision.
  double _roundToTwoDecimals(double value) {
    return (value * 100).round() / 100;
  }
}

/// Extension to easily access personal commission from order data.
extension PersonalCommissionExtension on PersonalCommissionService {
  /// Calculate personal commission breakdown for an order.
  ///
  /// This is a convenience method that shows the full breakdown
  /// without affecting any other financial calculations.
  ///
  /// Example:
  /// ```dart
  /// final service = PersonalCommissionService();
  /// final breakdown = service.getOrderCommissionBreakdown(
  ///   orderSubtotal: 200.0,
  ///   deliveryFee: 10.0,
  /// );
  /// print(breakdown);
  /// // Output:
  /// // Order Subtotal: 200.0 EGP
  /// // Store Commission (5%): 10.0 EGP
  /// // Delivery Commission (15% of 10): 1.5 EGP
  /// // Total Personal Commission: 11.5 EGP
  /// ```
  String getOrderCommissionBreakdown({
    required double orderSubtotal,
    double deliveryFee = PersonalCommissionService.defaultDeliveryFee,
    bool isFreeDelivery = false,
  }) {
    final result = calculateTotalCommission(
      orderSubtotal: orderSubtotal,
      deliveryFee: deliveryFee,
      isFreeDelivery: isFreeDelivery,
    );

    return '''
Order Subtotal: ${orderSubtotal.toStringAsFixed(2)} EGP
Store Commission (${(PersonalCommissionService.storeCommissionRate * 100).toStringAsFixed(0)}%): ${result.fromStore.toStringAsFixed(2)} EGP
Delivery Commission (${(PersonalCommissionService.deliveryCommissionRate * 100).toStringAsFixed(0)}% of ${deliveryFee.toStringAsFixed(2)}): ${result.fromDelivery.toStringAsFixed(2)} EGP
Total Personal Commission: ${result.total.toStringAsFixed(2)} EGP
''';
  }
}