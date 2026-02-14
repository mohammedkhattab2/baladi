// Domain - Points transaction type enumeration.
//
// Defines the types of points transactions in the loyalty system.
// Maps to the `type` column in the points_transactions table.

/// The type of points movement in the loyalty system.
enum PointsTransactionType {
  /// Points earned from completing an order.
  earned('earned', 'مكتسبة'),

  /// Points redeemed as a discount on an order.
  redeemed('redeemed', 'مستخدمة'),

  /// Bonus points awarded for a successful referral.
  referral('referral', 'إحالة'),

  /// Manual points adjustment by an admin.
  adjustment('adjustment', 'تعديل إداري');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const PointsTransactionType(this.value, this.labelAr);

  /// Creates a [PointsTransactionType] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any type.
  static PointsTransactionType fromValue(String value) {
    return PointsTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () =>
          throw ArgumentError('Unknown PointsTransactionType: $value'),
    );
  }

  /// Returns `true` if this transaction adds points to the balance.
  bool get isCredit => this == earned || this == referral;

  /// Returns `true` if this transaction deducts points from the balance.
  bool get isDebit => this == redeemed;
}