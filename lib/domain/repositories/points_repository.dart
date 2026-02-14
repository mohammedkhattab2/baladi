// Domain - Points repository interface.
//
// Defines the contract for loyalty points operations including
// balance retrieval, history, and points transactions.

import '../../core/result/result.dart';
import '../entities/points_transaction.dart';

/// Repository contract for loyalty points operations.
///
/// Handles fetching points balance, transaction history,
/// and referral-related points queries.
abstract class PointsRepository {
  /// Fetches the current customer's total points balance.
  Future<Result<int>> getPointsBalance();

  /// Fetches the customer's points transaction history.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<PointsTransaction>>> getPointsHistory({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches points transactions filtered by type.
  ///
  /// - [type]: The transaction type to filter by.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<PointsTransaction>>> getPointsHistoryByType({
    required PointsTransactionType type,
    int page = 1,
    int perPage = 20,
  });

  /// Redeems points on an order, deducting from the customer's balance.
  ///
  /// - [customerId]: The customer redeeming points.
  /// - [orderId]: The order to apply the discount to.
  /// - [points]: Number of points to redeem.
  Future<Result<void>> redeemPoints({
    required String customerId,
    required String orderId,
    required int points,
  });
}