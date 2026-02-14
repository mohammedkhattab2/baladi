// Domain - Cash transaction type enumeration.
//
// Defines the types of cash transactions in the order delivery flow.
// Maps to the `type` column in the cash_transactions table.

/// The type of cash movement between parties in an order.
enum CashTransactionType {
  /// Customer pays cash to the delivery rider.
  customerToRider('customer_to_rider', 'من العميل للسائق'),

  /// Rider hands cash to the shop owner.
  riderToShop('rider_to_shop', 'من السائق للمتجر'),

  /// Shop transfers commission to admin (settlement).
  shopToAdmin('shop_to_admin', 'من المتجر للإدارة');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const CashTransactionType(this.value, this.labelAr);

  /// Creates a [CashTransactionType] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any type.
  static CashTransactionType fromValue(String value) {
    return CashTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown CashTransactionType: $value'),
    );
  }
}