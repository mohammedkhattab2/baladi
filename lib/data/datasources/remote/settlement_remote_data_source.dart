/// Remote data source for settlement operations.
///
/// This interface defines the contract for settlement API calls.
/// Implementation will use Supabase or similar service.
library;

import '../../dto/settlement_dto.dart';

/// Remote data source interface for settlements.
abstract class SettlementRemoteDataSource {
  /// Get current week's settlement (or create if not exists).
  /// 
  /// Returns [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<SettlementDto> getCurrentWeekSettlement();

  /// Get settlement by ID.
  /// 
  /// Returns [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [NotFoundException] if settlement not found.
  Future<SettlementDto> getSettlementById(String settlementId);

  /// Get settlement by week dates.
  /// 
  /// Returns [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [NotFoundException] if settlement not found.
  Future<SettlementDto> getSettlementByWeek({
    required DateTime weekStart,
    required DateTime weekEnd,
  });

  /// Get all settlements (paginated).
  /// 
  /// Returns list of [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<SettlementDto>> getAllSettlements({
    String? status,
    int page = 1,
    int limit = 20,
  });

  /// Close the current week and calculate settlement.
  /// 
  /// Returns [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [SettlementAlreadyClosedException] if already closed.
  Future<SettlementDto> closeWeek({
    required String adminId,
    String? note,
  });

  /// Get store settlement breakdown for a week.
  /// 
  /// Returns list of [StoreSettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<StoreSettlementDto>> getStoreSettlements(String settlementId);

  /// Get rider settlement breakdown for a week.
  /// 
  /// Returns list of [RiderSettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<RiderSettlementDto>> getRiderSettlements(String settlementId);

  /// Mark settlement as paid.
  /// 
  /// Returns updated [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<SettlementDto> markSettlementPaid({
    required String settlementId,
    required String paymentReference,
  });

  /// Get settlement statistics.
  /// 
  /// Returns map of statistics.
  /// Throws [ServerException] on API failure.
  Future<Map<String, dynamic>> getSettlementStatistics({
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Recalculate settlement (in case of disputes).
  /// 
  /// Returns updated [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<SettlementDto> recalculateSettlement({
    required String settlementId,
    required String adminId,
    required String reason,
  });

  /// Add dispute to settlement.
  /// 
  /// Returns updated [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<SettlementDto> addDispute({
    required String settlementId,
    required String disputeReason,
    required String raisedBy,
  });

  /// Resolve settlement dispute.
  /// 
  /// Returns updated [SettlementDto] on success.
  /// Throws [ServerException] on API failure.
  Future<SettlementDto> resolveDispute({
    required String settlementId,
    required String resolution,
    required String resolvedBy,
  });

  /// Get week dates for current period.
  /// 
  /// Returns map with 'weekStart' and 'weekEnd' DateTime values.
  Future<Map<String, DateTime>> getCurrentWeekDates();
}