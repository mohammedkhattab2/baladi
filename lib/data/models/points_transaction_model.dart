// Data - Points transaction model with JSON serialization.
//
// Maps between the API JSON representation and the domain PointsTransaction entity.

import '../../domain/entities/points_transaction.dart';

/// Data model for [PointsTransaction] with JSON serialization support.
class PointsTransactionModel extends PointsTransaction {
  const PointsTransactionModel({
    required super.id,
    required super.customerId,
    super.orderId,
    required super.type,
    required super.points,
    required super.balanceAfter,
    super.description,
    required super.createdAt,
  });

  /// Creates a [PointsTransactionModel] from a JSON map.
  factory PointsTransactionModel.fromJson(Map<String, dynamic> json) {
    return PointsTransactionModel(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      orderId: json['order_id'] as String?,
      type: PointsTransactionType.fromValue(json['type'] as String),
      points: json['points'] as int,
      balanceAfter: json['balance_after'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Creates a [PointsTransactionModel] from a domain [PointsTransaction] entity.
  factory PointsTransactionModel.fromEntity(PointsTransaction transaction) {
    return PointsTransactionModel(
      id: transaction.id,
      customerId: transaction.customerId,
      orderId: transaction.orderId,
      type: transaction.type,
      points: transaction.points,
      balanceAfter: transaction.balanceAfter,
      description: transaction.description,
      createdAt: transaction.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_id': orderId,
      'type': type.value,
      'points': points,
      'balance_after': balanceAfter,
      'description': description,
      'created_at': createdAt.toIso8601String(),
    };
  }
}