// Domain - Payment method enumeration.
//
// For the MVP, only cash payment is supported. This enum is
// designed to be extensible for future online payment methods.

/// Supported payment methods for orders.
enum PaymentMethod {
  /// Cash on delivery — the only method in MVP.
  cash('cash', 'كاش'),

  /// Online payment (future expansion).
  online('online', 'دفع إلكتروني');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const PaymentMethod(this.value, this.labelAr);

  /// Creates a [PaymentMethod] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any method.
  static PaymentMethod fromValue(String value) {
    return PaymentMethod.values.firstWhere(
      (method) => method.value == value,
      orElse: () => throw ArgumentError('Unknown PaymentMethod: $value'),
    );
  }

  /// Returns `true` if this method requires cash handling by the rider.
  bool get requiresCashHandling => this == PaymentMethod.cash;
}