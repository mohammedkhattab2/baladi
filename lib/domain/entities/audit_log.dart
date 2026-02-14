// Domain - Audit log entity.
//
// Represents an audit trail entry for sensitive actions performed
// in the system. Used for accountability and dispute resolution.

import 'package:equatable/equatable.dart';

/// An audit log entry recording a user action in the system.
///
/// Captures who did what, when, and the before/after state of
/// the affected entity. Used by admin for accountability tracking.
class AuditLog extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The user who performed the action.
  final String? userId;

  /// The action performed (e.g. 'order.cancel', 'settlement.approve').
  final String action;

  /// The type of entity affected (e.g. 'order', 'user', 'settlement').
  final String entityType;

  /// The ID of the affected entity.
  final String? entityId;

  /// Snapshot of relevant data before and after the action.
  final Map<String, dynamic>? details;

  /// When the action was performed.
  final DateTime createdAt;

  const AuditLog({
    required this.id,
    this.userId,
    required this.action,
    required this.entityType,
    this.entityId,
    this.details,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        action,
        entityType,
        entityId,
        details,
        createdAt,
      ];
}