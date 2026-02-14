// Domain - Use case for redeeming loyalty points.
//
// Validates and applies a points discount to an order,
// deducting from the customer's balance. The discount only
// affects the admin/platform commission.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/error/failures.dart';
import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/points_repository.dart';
import '../../services/points_calculator.dart';

/// Parameters for redeeming points.
class RedeemPointsParams extends Equatable {
  /// The customer redeeming points.
  final String customerId;

  /// The order to apply the discount to.
  final String orderId;

  /// Number of points to redeem.
  final int pointsToRedeem;

  /// The platform commission available for discount absorption.
  final double platformCommission;

  const RedeemPointsParams({
    required this.customerId,
    required this.orderId,
    required this.pointsToRedeem,
    required this.platformCommission,
  });

  @override
  List<Object?> get props => [customerId, orderId, pointsToRedeem, platformCommission];
}

/// Result of a successful points redemption.
class RedeemPointsResult {
  /// The monetary discount applied.
  final double discountAmount;

  /// Remaining points balance after redemption.
  final int remainingBalance;

  const RedeemPointsResult({
    required this.discountAmount,
    required this.remainingBalance,
  });
}

/// Redeems loyalty points as a discount on an order.
///
/// Validates the redemption against the customer's balance and
/// the available platform commission, then deducts points.
@lazySingleton
class RedeemPoints extends UseCase<RedeemPointsResult, RedeemPointsParams> {
  final PointsRepository _pointsRepository;
  final PointsCalculator _pointsCalculator;

  RedeemPoints(this._pointsRepository, this._pointsCalculator);

  @override
  Future<Result<RedeemPointsResult>> call(RedeemPointsParams params) async {
    // Step 1: Get current balance
    final balanceResult = await _pointsRepository.getPointsBalance();
    if (balanceResult.isFailure) {
      return ResultFailure(balanceResult.failure!);
    }

    final availablePoints = balanceResult.data!;

    // Step 2: Validate redemption using the calculator
    final validationError = _pointsCalculator.validateRedemption(
      pointsToUse: params.pointsToRedeem,
      availablePoints: availablePoints,
      platformCommission: params.platformCommission,
    );

    if (validationError != null) {
      return ResultFailure(
        ServerFailure(message: validationError, statusCode: 400),
      );
    }

    // Step 3: Calculate discount value
    final discountAmount = _pointsCalculator.calculateDiscountValue(params.pointsToRedeem);

    // Step 4: Apply redemption via repository
    final redeemResult = await _pointsRepository.redeemPoints(
      customerId: params.customerId,
      orderId: params.orderId,
      points: params.pointsToRedeem,
    );

    if (redeemResult.isFailure) {
      return ResultFailure(redeemResult.failure!);
    }

    return Success(RedeemPointsResult(
      discountAmount: discountAmount,
      remainingBalance: availablePoints - params.pointsToRedeem,
    ));
  }
}