// Domain - Points transaction entity.
//
// Represents a single loyalty points transaction (earn, redeem, referral, adjustment).

import 'package:equatable/equatable.dart';

/// Type of points transaction.
enum PointsTransactionType {
  /// Points earned from a completed order.
  earned('earned', 'نقاط مكتسبة'),

  /// Points redeemed as a discount on an order.
  redeemed('redeemed', 'نقاط مستخدمة'),

  /// Points awarded from a referral bonus.
  referral('referral', 'مكافأة إحالة'),

  /// Manual adjustment by admin.
  adjustment('adjustment', 'تعديل');

  final String value;
  final String labelAr;

  const PointsTransactionType(this.value, this.labelAr);

  static PointsTransactionType fromValue(String value) {
    return PointsTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown PointsTransactionType: $value'),
    );
  }
}

/// A single points transaction in a customer's ledger.
///
/// Each transaction records the change and the resulting balance,
/// forming an auditable history of all points activity.
class PointsTransaction extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The customer this transaction belongs to.
  final String customerId;

  /// The related order (null for referral/adjustment).
  final String? orderId;

  /// Type of transaction.
  final PointsTransactionType type;

  /// Points amount (positive for earned/referral, negative for redeemed).
  final int points;

  /// Customer's points balance after this transaction.
  final int balanceAfter;

  /// Human-readable description of the transaction.
  final String? description;

  /// When the transaction occurred.
  final DateTime createdAt;

  const PointsTransaction({
    required this.id,
    required this.customerId,
    this.orderId,
    required this.type,
    required this.points,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
  });

  /// Returns `true` if this transaction added points.
  bool get isCredit => points > 0;

  /// Returns `true` if this transaction deducted points.
  bool get isDebit => points < 0;

  @override
  List<Object?> get props => [
        id,
        customerId,
        orderId,
        type,
        points,
        balanceAfter,
        description,
        createdAt,
      ];
}