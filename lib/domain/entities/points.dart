/// Points entity in the Baladi application.
/// 
/// This is a pure domain entity representing the loyalty points
/// system for customers.
/// 
/// Architecture note: Points are a value object that tracks
/// customer loyalty rewards. Business rules for points are
/// defined in domain/rules/points_rules.dart.
library;
/// Represents a customer's points balance and history.
class Points {
  /// Customer ID these points belong to.
  final String customerId;

  /// Total points earned over lifetime.
  final int totalEarned;

  /// Total points redeemed over lifetime.
  final int totalRedeemed;

  /// Current available balance.
  final int balance;

  /// When the points record was last updated.
  final DateTime? lastUpdatedAt;

  const Points({
    required this.customerId,
    this.totalEarned = 0,
    this.totalRedeemed = 0,
    this.balance = 0,
    this.lastUpdatedAt,
  });

  /// Creates a copy of this points with the given fields replaced.
  Points copyWith({
    String? customerId,
    int? totalEarned,
    int? totalRedeemed,
    int? balance,
    DateTime? lastUpdatedAt,
  }) {
    return Points(
      customerId: customerId ?? this.customerId,
      totalEarned: totalEarned ?? this.totalEarned,
      totalRedeemed: totalRedeemed ?? this.totalRedeemed,
      balance: balance ?? this.balance,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  /// Returns true if customer has any points available.
  bool get hasPoints => balance > 0;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Points && other.customerId == customerId;
  }

  @override
  int get hashCode => customerId.hashCode;

  @override
  String toString() => 'Points(customerId: $customerId, balance: $balance)';
}

/// Represents a single points transaction.
class PointsTransaction {
  /// Unique identifier for the transaction.
  final String id;

  /// Customer ID.
  final String customerId;

  /// Order ID (if related to an order).
  final String? orderId;

  /// Type of transaction.
  final PointsTransactionType type;

  /// Points amount (positive for earned, negative for redeemed).
  final int points;

  /// Balance after this transaction.
  final int balanceAfter;

  /// Description of the transaction.
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

  /// Returns true if this is an earning transaction.
  bool get isEarning => type == PointsTransactionType.earned ||
      type == PointsTransactionType.referralBonus;

  /// Returns true if this is a redemption transaction.
  bool get isRedemption => type == PointsTransactionType.redeemed;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PointsTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'PointsTransaction(id: $id, type: ${type.name}, points: $points)';
}

/// Types of points transactions.
enum PointsTransactionType {
  /// Points earned from an order.
  earned,

  /// Points redeemed for a discount.
  redeemed,

  /// Bonus points from referral.
  referralBonus,

  /// Manual adjustment by admin.
  adjustment;

  /// Returns display name for the transaction type.
  String get displayName {
    return switch (this) {
      PointsTransactionType.earned => 'Points Earned',
      PointsTransactionType.redeemed => 'Points Redeemed',
      PointsTransactionType.referralBonus => 'Referral Bonus',
      PointsTransactionType.adjustment => 'Admin Adjustment',
    };
  }

  /// Returns Arabic display name.
  String get displayNameAr {
    return switch (this) {
      PointsTransactionType.earned => 'نقاط مكتسبة',
      PointsTransactionType.redeemed => 'نقاط مستخدمة',
      PointsTransactionType.referralBonus => 'مكافأة الإحالة',
      PointsTransactionType.adjustment => 'تعديل إداري',
    };
  }
}