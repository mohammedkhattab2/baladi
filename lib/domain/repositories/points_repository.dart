/// Repository interface for loyalty points operations.
/// 
/// This defines the contract for points-related data access.
/// Includes earning, redeeming, and tracking loyalty points.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/points.dart';

/// Points repository interface.
abstract class PointsRepository {
  /// Get customer's current points balance.
  Future<Result<Points>> getPointsBalance(String customerId);

  /// Get points transaction history.
  Future<Result<List<PointsTransaction>>> getPointsHistory({
    required String customerId,
    PointsTransactionType? type,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Add points for order completion.
  Future<Result<Points>> addPointsForOrder({
    required String customerId,
    required String orderId,
    required int points,
  });

  /// Add referral bonus points.
  Future<Result<Points>> addReferralBonus({
    required String referrerId,
    required String referredCustomerId,
    required String orderId,
  });

  /// Redeem points for discount.
  Future<Result<Points>> redeemPoints({
    required String customerId,
    required String orderId,
    required int points,
  });

  /// Reverse redeemed points (order cancelled).
  Future<Result<Points>> reverseRedemption({
    required String customerId,
    required String orderId,
    required int points,
  });

  /// Get referral code for customer.
  Future<Result<String>> getReferralCode(String customerId);

  /// Apply referral code.
  Future<Result<void>> applyReferralCode({
    required String customerId,
    required String referralCode,
  });

  /// Get referral statistics.
  Future<Result<ReferralStats>> getReferralStats(String customerId);

  /// Watch points balance updates.
  Stream<Points> watchPointsBalance(String customerId);
}

/// Points transaction types.
enum PointsTransactionType {
  earned,
  redeemed,
  referralBonus,
  reversed,
  expired,
  adjustment,
}

/// Points transaction record.
class PointsTransaction {
  final String id;
  final String customerId;
  final PointsTransactionType type;
  final int points;
  final int balanceAfter;
  final String? orderId;
  final String? description;
  final DateTime createdAt;

  const PointsTransaction({
    required this.id,
    required this.customerId,
    required this.type,
    required this.points,
    required this.balanceAfter,
    this.orderId,
    this.description,
    required this.createdAt,
  });
}

/// Referral statistics.
class ReferralStats {
  final String customerId;
  final String referralCode;
  final int totalReferrals;
  final int successfulReferrals;
  final int pointsEarned;

  const ReferralStats({
    required this.customerId,
    required this.referralCode,
    required this.totalReferrals,
    required this.successfulReferrals,
    required this.pointsEarned,
  });
}