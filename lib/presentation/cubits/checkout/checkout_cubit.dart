// Presentation - Checkout cubit.
//
// Manages the checkout flow including summary calculation with
// points/commission via domain services, points redemption,
// and order placement via the PlaceOrder use case.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/services/commission_calculator.dart';
import '../../../domain/services/points_calculator.dart';
import '../../../domain/usecases/order/place_order.dart';
import '../../../domain/usecases/points/get_points_balance.dart';
import 'checkout_state.dart';

/// Cubit that manages the full checkout flow.
///
/// Delegates all business calculations to domain services
/// ([PointsCalculator], [CommissionCalculator]) and orchestrates
/// order placement via the [PlaceOrder] use case.
@injectable
class CheckoutCubit extends Cubit<CheckoutState> {
  final PlaceOrder _placeOrder;
  final GetPointsBalance _getPointsBalance;
  final PointsCalculator _pointsCalculator;
  final CommissionCalculator _commissionCalculator;

  /// Creates a [CheckoutCubit].
  CheckoutCubit({
    required PlaceOrder placeOrder,
    required GetPointsBalance getPointsBalance,
    required PointsCalculator pointsCalculator,
    required CommissionCalculator commissionCalculator,
  })  : _placeOrder = placeOrder,
        _getPointsBalance = getPointsBalance,
        _pointsCalculator = pointsCalculator,
        _commissionCalculator = commissionCalculator,
        super(const CheckoutInitial());

  /// Initializes the checkout summary from cart data.
  ///
  /// Calculates subtotal, delivery fee, commission, points to earn,
  /// and loads available points balance.
  Future<void> initCheckout({
    required String shopId,
    required List<OrderItem> items,
    required double deliveryFee,
    required double commissionRate,
    required String deliveryAddress,
    String? deliveryLandmark,
    String? customerNotes,
    bool isFreeDelivery = false,
  }) async {
    emit(const CheckoutCalculating());

    try {
      // Calculate subtotal from items
      final subtotal =
          items.fold<double>(0, (sum, item) => sum + item.subtotal);

      // Load available points using NoParams
      final pointsResult = await _getPointsBalance(const NoParams());
      final availablePoints = pointsResult.data ?? 0;

      // Calculate points to earn using domain service
      final pointsToEarn = _pointsCalculator.calculateEarnedPoints(subtotal);

      // Calculate effective delivery fee
      final effectiveDeliveryFee = isFreeDelivery ? 0.0 : deliveryFee;

      // Calculate total
      final totalAmount = subtotal + effectiveDeliveryFee;

      emit(CheckoutSummaryLoaded(
        subtotal: subtotal,
        deliveryFee: effectiveDeliveryFee,
        isFreeDelivery: isFreeDelivery,
        availablePoints: availablePoints,
        pointsToRedeem: 0,
        pointsDiscount: 0,
        totalAmount: totalAmount,
        pointsToEarn: pointsToEarn,
        deliveryAddress: deliveryAddress,
        deliveryLandmark: deliveryLandmark,
        customerNotes: customerNotes,
        shopId: shopId,
        commissionRate: commissionRate,
      ));
    } catch (e) {
      emit(CheckoutError(message: 'فشل في تحميل ملخص الطلب'));
    }
  }

  /// Updates the number of points to redeem.
  ///
  /// Validates using the domain [PointsCalculator] and recalculates
  /// the total amount.
  void updatePointsToRedeem(int points) {
    final currentState = state;
    if (currentState is! CheckoutSummaryLoaded) return;

    // Calculate commission using domain service (method is `calculate`)
    final commissions = _commissionCalculator.calculate(
      subtotal: currentState.subtotal,
      commissionRate: currentState.commissionRate,
      pointsDiscount: 0,
      freeDeliveryCost:
          currentState.isFreeDelivery ? currentState.deliveryFee : 0,
    );

    // Validate points redemption using domain service
    // Returns null if valid, or an error message string if invalid
    final validationError = _pointsCalculator.validateRedemption(
      pointsToUse: points,
      availablePoints: currentState.availablePoints,
      platformCommission: commissions.platformCommission,
    );

    if (validationError != null) {
      emit(CheckoutError(message: validationError));
      // Re-emit the summary so UI can recover
      emit(currentState);
      return;
    }

    final pointsDiscount = _pointsCalculator.calculateDiscountValue(points);
    final totalAmount =
        currentState.subtotal + currentState.deliveryFee - pointsDiscount;

    emit(currentState.copyWith(
      pointsToRedeem: points,
      pointsDiscount: pointsDiscount,
      totalAmount: totalAmount,
    ));
  }

  /// Updates the delivery address.
  void updateDeliveryAddress({
    required String address,
    String? landmark,
  }) {
    final currentState = state;
    if (currentState is! CheckoutSummaryLoaded) return;

    emit(currentState.copyWith(
      deliveryAddress: address,
      deliveryLandmark: landmark,
    ));
  }

  /// Updates customer notes.
  void updateCustomerNotes(String? notes) {
    final currentState = state;
    if (currentState is! CheckoutSummaryLoaded) return;

    emit(currentState.copyWith(customerNotes: notes));
  }

  /// Places the order using the [PlaceOrder] use case.
  ///
  /// Delegates all calculations and validation to the domain layer.
  Future<void> placeOrder({required List<OrderItem> items}) async {
    final currentState = state;
    if (currentState is! CheckoutSummaryLoaded) return;

    emit(const CheckoutPlacingOrder());

    final result = await _placeOrder(PlaceOrderParams(
      shopId: currentState.shopId,
      items: items,
      deliveryAddress: currentState.deliveryAddress,
      landmark: currentState.deliveryLandmark,
      notes: currentState.customerNotes,
      pointsToRedeem: currentState.pointsToRedeem,
      isFreeDelivery: currentState.isFreeDelivery,
    ));

    result.fold(
      onSuccess: (order) {
        emit(CheckoutOrderPlaced(
          order: order,
          pointsEarned: currentState.pointsToEarn,
        ));
      },
      onFailure: (failure) {
        emit(CheckoutError(message: failure.message));
      },
    );
  }

  /// Resets the checkout to initial state.
  void reset() {
    emit(const CheckoutInitial());
  }
}