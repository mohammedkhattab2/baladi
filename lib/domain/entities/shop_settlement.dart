// Domain - Shop settlement entity.
//
// Represents a weekly financial settlement for a shop,
// summarizing orders, commissions, and net payable amount.

import 'package:equatable/equatable.dart';

import '../enums/settlement_status.dart';

/// Weekly financial settlement for a shop.
///
/// Generated when the admin closes a weekly period. Summarizes
/// all completed orders, commissions, discounts, and ads costs
/// to calculate the net amount owed to the shop.
class ShopSettlement extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The shop this settlement is for.
  final String shopId;

  /// The weekly period this settlement covers.
  final String periodId;

  /// Total number of orders in the period.
  final int totalOrders;

  /// Number of completed orders.
  final int completedOrders;

  /// Number of cancelled orders.
  final int cancelledOrders;

  /// Gross sales (sum of subtotals for completed orders).
  final double grossSales;

  /// Total commission charged (grossSales × commissionRate).
  final double totalCommission;

  /// Total points discounts absorbed by the platform.
  final double pointsDiscounts;

  /// Cost of free deliveries absorbed by the platform.
  final double freeDeliveryCost;

  /// Total ads cost charged to the shop.
  final double adsCost;

  /// Net amount: grossSales - totalCommission (shop keeps this).
  final double netAmount;

  /// Settlement payment status.
  final SettlementStatus status;

  /// When the settlement was paid.
  final DateTime? settledAt;

  /// Admin notes about the settlement.
  final String? notes;

  /// When the settlement record was created.
  final DateTime createdAt;

  const ShopSettlement({
    required this.id,
    required this.shopId,
    required this.periodId,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.grossSales = 0,
    this.totalCommission = 0,
    this.pointsDiscounts = 0,
    this.freeDeliveryCost = 0,
    this.adsCost = 0,
    this.netAmount = 0,
    this.status = SettlementStatus.pending,
    this.settledAt,
    this.notes,
    required this.createdAt,
  });

  /// Returns `true` if the settlement has been paid.
  bool get isPaid => status == SettlementStatus.settled;

  @override
  List<Object?> get props => [
        id,
        shopId,
        periodId,
        totalOrders,
        completedOrders,
        cancelledOrders,
        grossSales,
        totalCommission,
        pointsDiscounts,
        freeDeliveryCost,
        adsCost,
        netAmount,
        status,
        settledAt,
        notes,
        createdAt,
      ];
}