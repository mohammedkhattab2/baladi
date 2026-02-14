// Domain - Cash transaction entity.
//
// Represents a cash movement between parties during the order
// delivery flow: customer → rider → shop → admin.

import 'package:equatable/equatable.dart';

import '../enums/cash_transaction_type.dart';

/// A record of cash changing hands during an order's lifecycle.
///
/// Tracks the flow of cash from customer to rider, rider to shop,
/// and shop to admin as part of the weekly settlement process.
class CashTransaction extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The order this transaction belongs to.
  final String orderId;

  /// The type of cash movement.
  final CashTransactionType type;

  /// The amount of cash transferred.
  final double amount;

  /// The user who sent the cash.
  final String? fromUserId;

  /// The user who received the cash.
  final String? toUserId;

  /// When the transaction was confirmed.
  final DateTime? confirmedAt;

  /// The user who confirmed the transaction.
  final String? confirmedBy;

  /// Optional notes about the transaction.
  final String? notes;

  /// When the transaction record was created.
  final DateTime createdAt;

  const CashTransaction({
    required this.id,
    required this.orderId,
    required this.type,
    required this.amount,
    this.fromUserId,
    this.toUserId,
    this.confirmedAt,
    this.confirmedBy,
    this.notes,
    required this.createdAt,
  });

  /// Returns `true` if the transaction has been confirmed.
  bool get isConfirmed => confirmedAt != null;

  @override
  List<Object?> get props => [
        id,
        orderId,
        type,
        amount,
        fromUserId,
        toUserId,
        confirmedAt,
        confirmedBy,
        notes,
        createdAt,
      ];
}