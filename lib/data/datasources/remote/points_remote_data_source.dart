/// Remote data source for points and loyalty operations.
///
/// This interface defines the contract for points API calls.
/// Implementation will use Supabase or similar service.
library;

import '../../dto/points_dto.dart';

/// Remote data source interface for points.
abstract class PointsRemoteDataSource {
  /// Get user's points balance.
  ///
  /// Returns [PointsDto] on success.
  /// Throws [ServerException] on API failure.
  Future<PointsDto> getPointsBalance(String userId);

  /// Get points transaction history.
  ///
  /// Returns list of [PointsTransactionDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<PointsTransactionDto>> getPointsHistory({
    required String userId,
    int page = 1,
    int limit = 20,
  });

  /// Add points to user account.
  ///
  /// Returns updated [PointsDto] on success.
  /// Throws [ServerException] on API failure.
  Future<PointsDto> addPoints({
    required String userId,
    required int amount,
    required String type,
    String? orderId,
    String? referredUserId,
    String? note,
  });

  /// Redeem points for discount.
  ///
  /// Returns updated [PointsDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [InsufficientPointsException] if not enough points.
  Future<PointsDto> redeemPoints({
    required String userId,
    required int amount,
    required String orderId,
    required double discountValue,
  });

  /// Process referral points (when referred user places first order).
  ///
  /// Returns updated [PointsDto] for referrer on success.
  /// Throws [ServerException] on API failure.
  Future<PointsDto> processReferralPoints({
    required String referrerId,
    required String referredUserId,
    required String orderId,
  });

  /// Get referral code for user.
  ///
  /// Returns referral code string.
  /// Throws [ServerException] on API failure.
  Future<String> getReferralCode(String userId);

  /// Apply referral code to new user.
  ///
  /// Returns referrer's user ID on success.
  /// Throws [ServerException] on API failure.
  /// Throws [InvalidReferralCodeException] if code is invalid.
  Future<String> applyReferralCode({
    required String userId,
    required String referralCode,
  });

  /// Check if user has used referral code.
  ///
  /// Returns true if already used a referral code.
  /// Throws [ServerException] on API failure.
  Future<bool> hasUsedReferralCode(String userId);

  /// Get total points statistics (for admin).
  ///
  /// Returns map of statistics.
  /// Throws [ServerException] on API failure.
  Future<Map<String, dynamic>> getPointsStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Adjust points manually (admin only).
  ///
  /// Returns updated [PointsDto] on success.
  /// Throws [ServerException] on API failure.
  Future<PointsDto> adjustPoints({
    required String userId,
    required int amount,
    required String reason,
    required String adminId,
  });
}
