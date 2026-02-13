// Domain - Customer repository interface.
//
// Defines the contract for customer profile, address,
// and referral operations.

import '../../core/result/result.dart';
import '../entities/customer.dart';

/// Repository contract for customer-related operations.
///
/// Handles profile management, address updates, and referral
/// code application for customers.
abstract class CustomerRepository {
  /// Fetches the current customer's profile.
  Future<Result<Customer>> getProfile();

  /// Updates the customer's profile information.
  ///
  /// - [fullName]: Updated full name (optional).
  Future<Result<Customer>> updateProfile({
    String? fullName,
  });

  /// Updates the customer's delivery address.
  ///
  /// - [addressText]: Full delivery address text.
  /// - [landmark]: Optional landmark near the address.
  /// - [area]: Optional area/district name.
  Future<Result<Customer>> updateAddress({
    required String addressText,
    String? landmark,
    String? area,
  });

  /// Applies a referral code to the current customer.
  ///
  /// Awards bonus points to the referrer upon successful application.
  /// Can only be applied once per customer.
  ///
  /// - [referralCode]: The referral code to apply.
  Future<Result<void>> applyReferralCode(String referralCode);

  /// Fetches the customer's referral code for sharing.
  Future<Result<String>> getReferralCode();

  /// Returns the locally cached customer profile, or `null` if not cached.
  Future<Customer?> getCachedProfile();

  /// Caches the customer profile locally.
  Future<void> cacheProfile(Customer customer);

  /// Clears the cached customer profile.
  Future<void> clearCache();
}