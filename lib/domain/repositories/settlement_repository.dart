// Domain - Settlement repository interface.
//
// Defines the contract for settlement-related operations
// including weekly periods, shop settlements, and rider settlements.

import '../../core/result/result.dart';
import '../entities/rider_settlement.dart';
import '../entities/shop_settlement.dart';
import '../entities/weekly_period.dart';

/// Repository contract for settlement-related operations.
///
/// Handles weekly period management and settlement queries
/// for both shops and riders. Used primarily by admin role.
abstract class SettlementRepository {
  /// Fetches all weekly periods.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<WeeklyPeriod>>> getWeeklyPeriods({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches the current active weekly period.
  Future<Result<WeeklyPeriod>> getCurrentPeriod();

  /// Fetches shop settlements for a specific period.
  ///
  /// - [periodId]: The weekly period's unique identifier.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<ShopSettlement>>> getShopSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches rider settlements for a specific period.
  ///
  /// - [periodId]: The weekly period's unique identifier.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<RiderSettlement>>> getRiderSettlements({
    required String periodId,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches a single shop settlement by ID.
  Future<Result<ShopSettlement>> getShopSettlementById(String settlementId);

  /// Fetches a single rider settlement by ID.
  Future<Result<RiderSettlement>> getRiderSettlementById(String settlementId);
}