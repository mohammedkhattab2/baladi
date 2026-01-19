/// RedeemPoints use case.
///
/// Handles points redemption for order discounts.
/// Critical: Points discounts ONLY affect platform commission.
///
/// Architecture note: Use cases orchestrate domain services and
/// repositories. Points calculations use domain rules.
library;

import '../../core/result/result.dart' as result;
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/points.dart';
import '../repositories/points_repository.dart';
import '../services/points_calculator.dart';

/// Parameters for redeeming points.
class RedeemPointsParams {
  final String customerId;
  final String orderId;
  final int pointsToRedeem;
  final double platformCommission;

  const RedeemPointsParams({
    required this.customerId,
    required this.orderId,
    required this.pointsToRedeem,
    required this.platformCommission,
  });
}

/// Result of points redemption.
class RedeemPointsResult {
  final Points updatedBalance;
  final int pointsRedeemed;
  final double discountValue;

  const RedeemPointsResult({
    required this.updatedBalance,
    required this.pointsRedeemed,
    required this.discountValue,
  });
}

/// Use case for redeeming loyalty points.
class RedeemPoints implements UseCase<RedeemPointsResult, RedeemPointsParams> {
  final PointsRepository _pointsRepository;
  final PointsCalculator _pointsCalculator;

  RedeemPoints({
    required PointsRepository pointsRepository,
    PointsCalculator? pointsCalculator,
  })  : _pointsRepository = pointsRepository,
        _pointsCalculator = pointsCalculator ?? PointsCalculator();

  @override
  Future<result.Result<RedeemPointsResult>> call(RedeemPointsParams params) async {
    // Step 1: Get current balance
    final balanceResult = await _pointsRepository.getPointsBalance(params.customerId);

    return balanceResult.fold(
      onSuccess: (currentPoints) async {
        // Step 2: Validate redemption
        final validationResult = _pointsCalculator.validatePointsRedemption(
          pointsToUse: params.pointsToRedeem,
          availablePoints: currentPoints.balance,
          platformCommission: params.platformCommission,
        );

        if (!validationResult.isValid) {
          return result.Failure(
            ValidationFailure(message: validationResult.errorMessage ?? 'Invalid points redemption'),
          );
        }

        // Step 3: Calculate actual points to redeem
        final maxRedeemable = _pointsCalculator.calculateMaxRedeemablePoints(
          platformCommission: params.platformCommission,
          availablePoints: currentPoints.balance,
        );

        final actualPointsToRedeem = params.pointsToRedeem > maxRedeemable 
            ? maxRedeemable 
            : params.pointsToRedeem;

        if (actualPointsToRedeem <= 0) {
          return result.Failure(
            ValidationFailure(message: 'No points available to redeem'),
          );
        }

        // Step 4: Redeem points
        final redeemResult = await _pointsRepository.redeemPoints(
          customerId: params.customerId,
          orderId: params.orderId,
          points: actualPointsToRedeem,
        );

        return redeemResult.fold(
          onSuccess: (updatedPoints) {
            final discountValue = _pointsCalculator.calculateDiscountValue(actualPointsToRedeem);

            return result.Success(RedeemPointsResult(
              updatedBalance: updatedPoints,
              pointsRedeemed: actualPointsToRedeem,
              discountValue: discountValue,
            ));
          },
          onFailure: (failure) => result.Failure(failure),
        );
      },
      onFailure: (failure) => result.Failure(failure),
    );
  }
}

/// Use case for applying referral code.
class ApplyReferralCode implements UseCase<void, ApplyReferralCodeParams> {
  final PointsRepository _pointsRepository;

  ApplyReferralCode({
    required PointsRepository pointsRepository,
  }) : _pointsRepository = pointsRepository;

  @override
  Future<result.Result<void>> call(ApplyReferralCodeParams params) async {
    return _pointsRepository.applyReferralCode(
      customerId: params.customerId,
      referralCode: params.referralCode,
    );
  }
}

/// Parameters for applying referral code.
class ApplyReferralCodeParams {
  final String customerId;
  final String referralCode;

  const ApplyReferralCodeParams({
    required this.customerId,
    required this.referralCode,
  });
}

/// Use case for awarding referral bonus.
class AwardReferralBonus implements UseCase<Points, AwardReferralBonusParams> {
  final PointsRepository _pointsRepository;

  AwardReferralBonus({
    required PointsRepository pointsRepository,
  }) : _pointsRepository = pointsRepository;

  @override
  Future<result.Result<Points>> call(AwardReferralBonusParams params) async {
    return _pointsRepository.addReferralBonus(
      referrerId: params.referrerId,
      referredCustomerId: params.referredCustomerId,
      orderId: params.orderId,
    );
  }
}

/// Parameters for awarding referral bonus.
class AwardReferralBonusParams {
  final String referrerId;
  final String referredCustomerId;
  final String orderId;

  const AwardReferralBonusParams({
    required this.referrerId,
    required this.referredCustomerId,
    required this.orderId,
  });
}