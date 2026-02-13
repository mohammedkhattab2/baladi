// Domain - Rider repository interface.
//
// Defines the contract for rider-related operations including
// profile, availability, orders, dashboard, and settlements.

import '../../core/result/result.dart';
import '../entities/order.dart';
import '../entities/rider.dart';
import '../entities/rider_settlement.dart';

/// Dashboard statistics for a rider.
class RiderDashboard {
  /// Total deliveries completed in the current period.
  final int totalDeliveries;

  /// Total earnings in the current period.
  final double totalEarnings;

  /// Total cash handled (collected from customers) in the current period.
  final double totalCashHandled;

  /// Number of available orders waiting to be picked up.
  final int availableOrdersCount;

  /// Creates a [RiderDashboard].
  const RiderDashboard({
    required this.totalDeliveries,
    required this.totalEarnings,
    required this.totalCashHandled,
    required this.availableOrdersCount,
  });
}

/// Repository contract for rider-related operations.
///
/// Handles rider profile, availability toggling, order pickup/delivery,
/// dashboard stats, and settlement history.
abstract class RiderRepository {
  /// Fetches the current rider's profile.
  Future<Result<Rider>> getRiderProfile();

  /// Toggles the rider's availability status.
  ///
  /// - [isAvailable]: Whether the rider is available for deliveries.
  Future<Result<Rider>> updateAvailability({required bool isAvailable});

  /// Fetches orders available for pickup (status: preparing).
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Order>>> getAvailableOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches the rider's assigned/completed orders.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Order>>> getRiderOrders({
    int page = 1,
    int perPage = 20,
  });

  /// Fetches the rider's dashboard statistics.
  Future<Result<RiderDashboard>> getRiderDashboard();

  /// Fetches the rider's earnings summary.
  Future<Result<double>> getTotalEarnings();

  /// Fetches the rider's settlement history.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<RiderSettlement>>> getSettlements({
    int page = 1,
    int perPage = 20,
  });
}