// Data - Rider settlement model with JSON serialization.
//
// Maps between the API JSON representation and the domain RiderSettlement entity.

import '../../domain/entities/rider_settlement.dart';
import '../../domain/enums/settlement_status.dart';

/// Data model for [RiderSettlement] with JSON serialization support.
class RiderSettlementModel extends RiderSettlement {
  const RiderSettlementModel({
    required super.id,
    required super.riderId,
    required super.periodId,
    super.totalDeliveries,
    super.totalEarnings,
    super.totalCashHandled,
    super.status,
    super.settledAt,
    super.notes,
    required super.createdAt,
  });

  /// Creates a [RiderSettlementModel] from a JSON map.
  factory RiderSettlementModel.fromJson(Map<String, dynamic> json) {
    return RiderSettlementModel(
      id: json['id'] as String,
      riderId: json['rider_id'] as String,
      periodId: json['period_id'] as String,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      totalEarnings: (json['total_earnings'] as num?)?.toDouble() ?? 0,
      totalCashHandled: (json['total_cash_handled'] as num?)?.toDouble() ?? 0,
      status: json['status'] != null
          ? SettlementStatus.fromValue(json['status'] as String)
          : SettlementStatus.pending,
      settledAt: json['settled_at'] != null
          ? DateTime.parse(json['settled_at'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Creates a [RiderSettlementModel] from a domain [RiderSettlement] entity.
  factory RiderSettlementModel.fromEntity(RiderSettlement settlement) {
    return RiderSettlementModel(
      id: settlement.id,
      riderId: settlement.riderId,
      periodId: settlement.periodId,
      totalDeliveries: settlement.totalDeliveries,
      totalEarnings: settlement.totalEarnings,
      totalCashHandled: settlement.totalCashHandled,
      status: settlement.status,
      settledAt: settlement.settledAt,
      notes: settlement.notes,
      createdAt: settlement.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rider_id': riderId,
      'period_id': periodId,
      'total_deliveries': totalDeliveries,
      'total_earnings': totalEarnings,
      'total_cash_handled': totalCashHandled,
      'status': status.value,
      'settled_at': settledAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}