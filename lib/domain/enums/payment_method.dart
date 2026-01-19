/// Payment methods in the Baladi application.
/// 
/// Currently only cash is supported, but architecture is ready
/// for future online payment integration.
/// 
/// Architecture note: This enum is designed to be extensible
/// for future payment methods without breaking changes.
library;
/// Available payment methods in the system.
enum PaymentMethod {
  /// Cash on delivery payment.
  cash;

  // TODO: Add these when online payments are enabled
  // creditCard,
  // debitCard,
  // mobileWallet,
  // bankTransfer,

  /// Returns display name for the payment method.
  String get displayName {
    return switch (this) {
      PaymentMethod.cash => 'Cash on Delivery',
    };
  }

  /// Returns Arabic display name for the payment method.
  String get displayNameAr {
    return switch (this) {
      PaymentMethod.cash => 'الدفع عند الاستلام',
    };
  }

  /// Returns short code for the payment method.
  String get code {
    return switch (this) {
      PaymentMethod.cash => 'COD',
    };
  }

  /// Returns true if this method requires online processing.
  bool get requiresOnlineProcessing {
    return switch (this) {
      PaymentMethod.cash => false,
    };
  }

  /// Returns true if this method is currently available.
  bool get isAvailable {
    return switch (this) {
      PaymentMethod.cash => true,
    };
  }

  /// Parses a string to PaymentMethod.
  static PaymentMethod? fromString(String? value) {
    if (value == null) return null;
    return PaymentMethod.values.where((p) => p.name == value).firstOrNull;
  }
}