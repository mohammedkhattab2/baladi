// Domain - Order status history entity.
//
// Represents a single status change in an order's lifecycle.
// Provides an audit trail of who changed the status and when.

import 'package:equatable/equatable.dart';

/// A record of an order status transition.
///
/// Each time an order's status changes, a new [OrderStatusHistory]
/// entry is created capturing the new status, who made the change,
/// and any accompanying notes.
class OrderStatusHistory extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The order this status change belongs to.
  final String orderId;

  /// The new status that was set.
  final String status;

  /// The user who triggered the status change.
  final String? changedBy;

  /// Optional notes explaining the status change.
  final String? notes;

  /// When the status change occurred.
  final DateTime createdAt;

  const OrderStatusHistory({
    required this.id,
    required this.orderId,
    required this.status,
    this.changedBy,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        status,
        changedBy,
        notes,
        createdAt,
      ];
}