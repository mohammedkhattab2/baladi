/// Local data source for points operations.
///
/// This interface defines the contract for local points data storage.
/// Implementation will use SQLite or Hive for structured local storage.
library;

import '../../dto/points_dto.dart';

/// Local data source interface for points.
abstract class PointsLocalDataSource {
  /// Cache points balance.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cachePointsBalance(PointsDto points);

  /// Get cached points balance for user.
  /// 
  /// Returns [PointsDto] if found.
  /// Returns null if not cached.
  /// Throws [CacheException] on storage failure.
  Future<PointsDto?> getCachedPointsBalance(String userId);

  /// Cache points transactions.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cachePointsTransactions(
    String userId,
    List<PointsTransactionDto> transactions,
  );

  /// Get cached points transactions for user.
  /// 
  /// Returns list of [PointsTransactionDto].
  /// Throws [CacheException] on storage failure.
  Future<List<PointsTransactionDto>> getCachedPointsTransactions(String userId);

  /// Update cached points balance.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateCachedPointsBalance(PointsDto points);

  /// Clear all cached points data for user.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearCachedPointsData(String userId);

  /// Clear all cached points data.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearAllCachedPointsData();

  /// Get last cache update timestamp.
  /// 
  /// Returns DateTime if available.
  Future<DateTime?> getLastCacheUpdate(String userId);

  /// Update last cache timestamp.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateLastCacheTimestamp(String userId);

  /// Cache referral code.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheReferralCode(String userId, String code);

  /// Get cached referral code.
  /// 
  /// Returns referral code if cached.
  /// Returns null if not cached.
  Future<String?> getCachedReferralCode(String userId);
}