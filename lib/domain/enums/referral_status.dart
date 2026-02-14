// Domain - Referral status enumeration.
//
// Defines the lifecycle statuses of a referral in the loyalty system.
// Maps to the `status` column in the referrals table.

/// The current status of a referral.
enum ReferralStatus {
  /// Referral created but referred user hasn't completed first order.
  pending('pending', 'قيد الانتظار'),

  /// Referred user completed first order; bonus points awarded.
  completed('completed', 'مكتمل'),

  /// Referral expired without completion.
  expired('expired', 'منتهي');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const ReferralStatus(this.value, this.labelAr);

  /// Creates a [ReferralStatus] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any status.
  static ReferralStatus fromValue(String value) {
    return ReferralStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown ReferralStatus: $value'),
    );
  }

  /// Returns `true` if the referral is still awaiting completion.
  bool get isPending => this == ReferralStatus.pending;

  /// Returns `true` if bonus points were awarded.
  bool get isCompleted => this == ReferralStatus.completed;
}