/// Points Data Transfer Object.
///
/// Used for serialization/deserialization of Points data
/// between API/database and domain entities.
library;

import '../../domain/entities/points.dart';

/// DTO for Points entity.
class PointsDto {
  final String customerId;
  final int totalEarned;
  final int totalRedeemed;
  final int balance;
  final String? lastUpdatedAt;

  const PointsDto({
    required this.customerId,
    this.totalEarned = 0,
    this.totalRedeemed = 0,
    this.balance = 0,
    this.lastUpdatedAt,
  });

  /// Create from JSON map.
  factory PointsDto.fromJson(Map<String, dynamic> json) {
    return PointsDto(
      customerId: json['customer_id'] as String,
      totalEarned: json['total_earned'] as int? ?? 0,
      totalRedeemed: json['total_redeemed'] as int? ?? 0,
      balance: json['balance'] as int? ?? 0,
      lastUpdatedAt: json['last_updated_at'] as String?,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'customer_id': customerId,
      'total_earned': totalEarned,
      'total_redeemed': totalRedeemed,
      'balance': balance,
      'last_updated_at': lastUpdatedAt,
    };
  }

  /// Convert to domain entity.
  Points toEntity() {
    return Points(
      customerId: customerId,
      totalEarned: totalEarned,
      totalRedeemed: totalRedeemed,
      balance: balance,
      lastUpdatedAt: lastUpdatedAt != null ? DateTime.parse(lastUpdatedAt!) : null,
    );
  }

  /// Create from domain entity.
  factory PointsDto.fromEntity(Points entity) {
    return PointsDto(
      customerId: entity.customerId,
      totalEarned: entity.totalEarned,
      totalRedeemed: entity.totalRedeemed,
      balance: entity.balance,
      lastUpdatedAt: entity.lastUpdatedAt?.toIso8601String(),
    );
  }
}

/// DTO for PointsTransaction.
class PointsTransactionDto {
  final String id;
  final String customerId;
  final String? orderId;
  final String type;
  final int points;
  final int balanceAfter;
  final String? description;
  final String createdAt;

  const PointsTransactionDto({
    required this.id,
    required this.customerId,
    this.orderId,
    required this.type,
    required this.points,
    required this.balanceAfter,
    this.description,
    required this.createdAt,
  });

  /// Create from JSON map.
  factory PointsTransactionDto.fromJson(Map<String, dynamic> json) {
    return PointsTransactionDto(
      id: json['id'] as String,
      customerId: json['customer_id'] as String,
      orderId: json['order_id'] as String?,
      type: json['type'] as String,
      points: json['points'] as int,
      balanceAfter: json['balance_after'] as int,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  /// Convert to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'order_id': orderId,
      'type': type,
      'points': points,
      'balance_after': balanceAfter,
      'description': description,
      'created_at': createdAt,
    };
  }

  /// Convert to domain entity.
  PointsTransaction toEntity() {
    return PointsTransaction(
      id: id,
      customerId: customerId,
      orderId: orderId,
      type: PointsTransactionType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => PointsTransactionType.earned,
      ),
      points: points,
      balanceAfter: balanceAfter,
      description: description,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Create from domain entity.
  factory PointsTransactionDto.fromEntity(PointsTransaction entity) {
    return PointsTransactionDto(
      id: entity.id,
      customerId: entity.customerId,
      orderId: entity.orderId,
      type: entity.type.name,
      points: entity.points,
      balanceAfter: entity.balanceAfter,
      description: entity.description,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}