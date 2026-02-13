// Domain - Rider settlement entity.
//
// Represents a weekly financial settlement for a rider,
// summarizing deliveries, earnings, and cash handled.

import 'package:equatable/equatable.dart';

import '../enums/settlement_status.dart';

/// Weekly financial settlement for a rider.
///
/// Generated when the admin closes a weekly period. Summarizes
/// all deliveries made, earnings from delivery fees, and total
/// cash handled during the period.
class RiderSettlement extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The rider this settlement is for.
  final String riderId;

  /// The weekly period this settlement covers.
  final String periodId;

  /// Total number of deliveries completed.
  final int totalDeliveries;

  /// Total earnings from delivery fees.
  final double totalEarnings;

  /// Total cash collected from customers and handled.
  final double totalCashHandled;

  /// Settlement payment status.
  final SettlementStatus status;

  /// When the settlement was paid.
  final DateTime? settledAt;

  /// Admin notes about the settlement.
  final String? notes;

  /// When the settlement record was created.
  final DateTime createdAt;

  const RiderSettlement({
    required this.id,
    required this.riderId,
    required this.periodId,
    this.totalDeliveries = 0,
    this.totalEarnings = 0,
    this.totalCashHandled = 0,
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
        riderId,
        periodId,
        totalDeliveries,
        totalEarnings,
        totalCashHandled,
        status,
        settledAt,
        notes,
        createdAt,
      ];
}