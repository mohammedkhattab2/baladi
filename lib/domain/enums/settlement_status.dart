// Domain - Settlement status enumeration.
//
// Tracks the payment status of weekly shop/rider settlements.

/// Status of a weekly settlement.
enum SettlementStatus {
  /// Settlement calculated but not yet paid.
  pending('pending', 'قيد الانتظار'),

  /// Settlement has been paid and confirmed.
  settled('settled', 'تمت التسوية');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const SettlementStatus(this.value, this.labelAr);

  /// Creates a [SettlementStatus] from its backend string [value].
  static SettlementStatus fromValue(String value) {
    return SettlementStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown SettlementStatus: $value'),
    );
  }
}