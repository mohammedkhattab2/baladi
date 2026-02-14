// Domain - Referral business rules.
//
// Pure Dart rules governing the referral/loyalty system.
// No external dependencies.

/// Business rules for the referral system.
///
/// Defines referral code generation, bonus amounts, and
/// validation logic for the customer referral program.
class ReferralRules {
  /// Points awarded to the referrer when the referred user completes first order.
  static const int referralBonusPoints = 2;

  /// Length of auto-generated referral codes.
  static const int referralCodeLength = 8;

  /// Maximum number of referrals a single customer can make (0 = unlimited).
  static const int maxReferralsPerCustomer = 0;

  /// Whether a customer can refer themselves (always false).
  static const bool allowSelfReferral = false;

  /// Validate whether a referral code can be applied.
  ///
  /// Returns `null` if valid, or an error message string if invalid.
  static String? validateReferralApplication({
    required String referralCode,
    required String customerId,
    required String? referrerCustomerId,
    required bool alreadyReferred,
  }) {
    if (referralCode.trim().isEmpty) {
      return 'كود الإحالة مطلوب';
    }

    if (referrerCustomerId == null) {
      return 'كود إحالة غير صالح';
    }

    if (referrerCustomerId == customerId) {
      return 'لا يمكنك استخدام كود الإحالة الخاص بك';
    }

    if (alreadyReferred) {
      return 'لقد استخدمت كود إحالة من قبل';
    }

    return null;
  }

  /// Returns `true` if the referral bonus should be awarded.
  ///
  /// The bonus is awarded when the referred customer completes
  /// their first order and the referral is still pending.
  static bool shouldAwardBonus({
    required bool isFirstOrder,
    required bool referralIsPending,
  }) {
    return isFirstOrder && referralIsPending;
  }
}