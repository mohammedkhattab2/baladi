// Presentation - Checkout cubit states.
//
// Defines all possible states for the checkout flow including
// summary calculation, points redemption, and order placement.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';

/// Base state for the checkout cubit.
abstract class CheckoutState extends Equatable {
  const CheckoutState();

  @override
  List<Object?> get props => [];
}

/// Initial state — checkout not yet started.
class CheckoutInitial extends CheckoutState {
  const CheckoutInitial();
}

/// Checkout summary is being calculated.
class CheckoutCalculating extends CheckoutState {
  const CheckoutCalculating();
}

/// Checkout summary loaded with all calculations.
class CheckoutSummaryLoaded extends CheckoutState {
  /// Order subtotal (sum of item prices × quantities).
  final double subtotal;

  /// Delivery fee to be charged.
  final double deliveryFee;

  /// Whether free delivery is applied.
  final bool isFreeDelivery;

  /// Points available to the customer.
  final int availablePoints;

  /// Points the customer wants to redeem.
  final int pointsToRedeem;

  /// Discount value from redeemed points.
  final double pointsDiscount;

  /// Total amount to be paid (subtotal + deliveryFee - pointsDiscount).
  final double totalAmount;

  /// Points that will be earned from this order.
  final int pointsToEarn;

  /// Customer's delivery address.
  final String deliveryAddress;

  /// Landmark near the delivery address.
  final String? deliveryLandmark;

  /// Customer notes for the order.
  final String? customerNotes;

  /// The shop ID the order is being placed at.
  final String shopId;

  /// Shop commission rate.
  final double commissionRate;

  const CheckoutSummaryLoaded({
    required this.subtotal,
    required this.deliveryFee,
    required this.isFreeDelivery,
    required this.availablePoints,
    required this.pointsToRedeem,
    required this.pointsDiscount,
    required this.totalAmount,
    required this.pointsToEarn,
    required this.deliveryAddress,
    this.deliveryLandmark,
    this.customerNotes,
    required this.shopId,
    required this.commissionRate,
  });

  /// Creates a copy of this state with updated values.
  CheckoutSummaryLoaded copyWith({
    double? subtotal,
    double? deliveryFee,
    bool? isFreeDelivery,
    int? availablePoints,
    int? pointsToRedeem,
    double? pointsDiscount,
    double? totalAmount,
    int? pointsToEarn,
    String? deliveryAddress,
    String? deliveryLandmark,
    String? customerNotes,
    String? shopId,
    double? commissionRate,
  }) {
    return CheckoutSummaryLoaded(
      subtotal: subtotal ?? this.subtotal,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      isFreeDelivery: isFreeDelivery ?? this.isFreeDelivery,
      availablePoints: availablePoints ?? this.availablePoints,
      pointsToRedeem: pointsToRedeem ?? this.pointsToRedeem,
      pointsDiscount: pointsDiscount ?? this.pointsDiscount,
      totalAmount: totalAmount ?? this.totalAmount,
      pointsToEarn: pointsToEarn ?? this.pointsToEarn,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryLandmark: deliveryLandmark ?? this.deliveryLandmark,
      customerNotes: customerNotes ?? this.customerNotes,
      shopId: shopId ?? this.shopId,
      commissionRate: commissionRate ?? this.commissionRate,
    );
  }

  @override
  List<Object?> get props => [
        subtotal,
        deliveryFee,
        isFreeDelivery,
        availablePoints,
        pointsToRedeem,
        pointsDiscount,
        totalAmount,
        pointsToEarn,
        deliveryAddress,
        deliveryLandmark,
        customerNotes,
        shopId,
        commissionRate,
      ];
}

/// Order is being placed.
class CheckoutPlacingOrder extends CheckoutState {
  const CheckoutPlacingOrder();
}

/// Order has been placed successfully.
class CheckoutOrderPlaced extends CheckoutState {
  /// The placed order details.
  final Order order;

  /// Points earned from this order.
  final int pointsEarned;

  const CheckoutOrderPlaced({
    required this.order,
    required this.pointsEarned,
  });

  @override
  List<Object?> get props => [order, pointsEarned];
}

/// An error occurred during checkout.
class CheckoutError extends CheckoutState {
  /// The error message to display.
  final String message;

  const CheckoutError({required this.message});

  @override
  List<Object?> get props => [message];
}