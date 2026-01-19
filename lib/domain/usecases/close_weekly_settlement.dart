/// CloseWeeklySettlement use case.
///
/// Handles the weekly settlement closure process.
/// Week period: Saturday 00:00 → Friday 23:59.
///
/// Key Points Handling:
/// - Points redeemed by customers are tracked per order
/// - The monetary value of redeemed points is credited to store's weekly settlement
/// - Platform bears the cost of points discounts (not store or rider)
/// - Store receives: earnings + points redemption credit
///
/// Architecture note: Use cases orchestrate domain services and
/// repositories. Settlement calculations use domain rules.
library;

import '../../core/result/result.dart' as result;
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/settlement.dart';
import '../repositories/settlement_repository.dart';
import '../repositories/order_repository.dart';
import '../repositories/ads_repository.dart';
import '../enums/order_status.dart';

/// Parameters for closing weekly settlement.
class CloseWeeklySettlementParams {
  final String adminId;
  final String? note;

  const CloseWeeklySettlementParams({
    required this.adminId,
    this.note,
  });
}

/// Result of closing weekly settlement.
class CloseWeeklySettlementResult {
  final Settlement settlement;
  final int ordersProcessed;
  final int storesSettled;
  final int ridersSettled;

  /// Total points redeemed during the week (monetary value).
  /// This amount is credited to stores in their weekly payouts.
  final double totalPointsRedeemedValue;

  /// Map of store ID to their points redemption credit.
  /// Each store receives credit for points redeemed on their orders.
  final Map<String, double> storePointsCredits;

  const CloseWeeklySettlementResult({
    required this.settlement,
    required this.ordersProcessed,
    required this.storesSettled,
    required this.ridersSettled,
    this.totalPointsRedeemedValue = 0,
    this.storePointsCredits = const {},
  });
}

/// Use case for closing the weekly settlement.
class CloseWeeklySettlement implements UseCase<CloseWeeklySettlementResult, CloseWeeklySettlementParams> {
  final SettlementRepository _settlementRepository;
  final OrderRepository _orderRepository;
  final AdsRepository _adsRepository;

  CloseWeeklySettlement({
    required SettlementRepository settlementRepository,
    required OrderRepository orderRepository,
    required AdsRepository adsRepository,
  })  : _settlementRepository = settlementRepository,
        _orderRepository = orderRepository,
        _adsRepository = adsRepository;

  @override
  Future<result.Result<CloseWeeklySettlementResult>> call(CloseWeeklySettlementParams params) async {
    // Step 1: Get current week boundaries
    final weekBoundaries = _getWeekBoundaries();
    final weekStart = weekBoundaries.start;
    final weekEnd = weekBoundaries.end;

    // Step 2: Check if settlement already exists for this week
    final existingResult = await _settlementRepository.getCurrentWeekSettlement();
    
    final existingCheck = existingResult.fold(
      onSuccess: (existing) {
        if (existing != null && existing.status == SettlementStatus.completed) {
          return 'Settlement already closed for this week';
        }
        return null;
      },
      onFailure: (_) => null,
    );

    if (existingCheck != null) {
      return result.Failure(
        BusinessRuleFailure(message: existingCheck),
      );
    }

    // Step 3: Get all completed orders for the week
    final ordersResult = await _orderRepository.getOrdersForSettlement(
      weekStart: weekStart,
      weekEnd: weekEnd,
    );

    return ordersResult.fold(
      onSuccess: (orders) async {
        // Filter only completed orders
        final completedOrders = orders.where(
          (o) => o.status == OrderStatus.completed
        ).toList();

        if (completedOrders.isEmpty) {
          return result.Failure(
            BusinessRuleFailure(message: 'No completed orders to settle for this week'),
          );
        }

        // Step 4: Calculate totals
        var totalStoreCommissions = 0.0;
        var totalPointsRedeemed = 0.0;
        var totalFreeDeliveryCost = 0.0;
        final storeIds = <String>{};
        final riderIds = <String>{};

        // Track points redemption per store for weekly credit
        // Stores receive credit for points redeemed on their orders
        // This ensures the store doesn't lose money from customer's points usage
        final storePointsCredits = <String, double>{};

        for (final order in completedOrders) {
          totalStoreCommissions += order.storeCommission;
          totalPointsRedeemed += order.pointsDiscount;
          if (order.isFreeDelivery) {
            totalFreeDeliveryCost += order.deliveryFee;
          }
          storeIds.add(order.storeId);
          if (order.riderId != null) {
            riderIds.add(order.riderId!);
          }

          // Accumulate points credit per store
          // The store receives the full discount value redeemed by customers
          if (order.pointsDiscount > 0) {
            storePointsCredits[order.storeId] =
                (storePointsCredits[order.storeId] ?? 0) + order.pointsDiscount;
          }
        }

        // Step 5: Get ads costs for the week
        double totalAdsCost = 0;
        final adsResult = await _adsRepository.getAdsCostForPeriod(
          startDate: weekStart,
          endDate: weekEnd,
        );

        adsResult.fold(
          onSuccess: (adsCosts) {
            for (final ad in adsCosts) {
              totalAdsCost += ad.totalCost;
            }
          },
          onFailure: (_) {
            // Proceed without ads cost if it fails
          },
        );

        // Step 6: Calculate platform commission (for logging/auditing purposes)
        // Formula: store commissions - points redeemed - free delivery costs + ads revenue
        final _ = totalStoreCommissions - totalPointsRedeemed - totalFreeDeliveryCost + totalAdsCost;

        // Step 7: Close the week
        final closeResult = await _settlementRepository.closeWeek(
          adminId: params.adminId,
          note: params.note,
        );

        return closeResult.fold(
          onSuccess: (settlement) {
            return result.Success(CloseWeeklySettlementResult(
              settlement: settlement,
              ordersProcessed: completedOrders.length,
              storesSettled: storeIds.length,
              ridersSettled: riderIds.length,
              totalPointsRedeemedValue: totalPointsRedeemed,
              storePointsCredits: storePointsCredits,
            ));
          },
          onFailure: (failure) => result.Failure(failure),
        );
      },
      onFailure: (failure) => result.Failure(failure),
    );
  }

  /// Get the current week boundaries (Saturday 00:00 → Friday 23:59).
  WeekBoundaries _getWeekBoundaries() {
    final now = DateTime.now();
    
    // Find the most recent Saturday
    int daysToSubtract = (now.weekday + 1) % 7; // Saturday is weekday 6
    if (now.weekday == DateTime.saturday) {
      daysToSubtract = 0;
    }
    
    final saturday = DateTime(
      now.year,
      now.month,
      now.day - daysToSubtract,
      0, 0, 0,
    );
    
    // Friday is 6 days after Saturday
    final friday = DateTime(
      saturday.year,
      saturday.month,
      saturday.day + 6,
      23, 59, 59,
    );

    return WeekBoundaries(start: saturday, end: friday);
  }
}

/// Week boundaries helper class.
class WeekBoundaries {
  final DateTime start;
  final DateTime end;

  const WeekBoundaries({
    required this.start,
    required this.end,
  });
}