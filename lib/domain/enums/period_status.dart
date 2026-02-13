// Domain - Weekly period status enumeration.
//
// Tracks the lifecycle of a weekly settlement period.

/// Status of a weekly settlement period.
enum PeriodStatus {
  /// Current active week — orders are being placed.
  active('active', 'نشط'),

  /// Admin closed the week — settlements calculated.
  closed('closed', 'مغلق'),

  /// All settlements paid and confirmed.
  settled('settled', 'تمت التسوية');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const PeriodStatus(this.value, this.labelAr);

  /// Creates a [PeriodStatus] from its backend string [value].
  static PeriodStatus fromValue(String value) {
    return PeriodStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown PeriodStatus: $value'),
    );
  }
}