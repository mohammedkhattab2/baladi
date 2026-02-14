// Domain - Customer entity.
//
// Represents the customer profile with address, points, and referral info.

import 'package:equatable/equatable.dart';

/// Customer profile entity linked to a [User] with role `customer`.
///
/// Holds delivery address, loyalty points balance, and referral code.
class Customer extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// Associated user account ID.
  final String userId;

  /// Customer's full name (Arabic or English).
  final String fullName;

  /// Free-text delivery address.
  final String? addressText;

  /// Nearby landmark for easier delivery.
  final String? landmark;

  /// Area or neighborhood name.
  final String? area;

  /// Current loyalty points balance.
  final int totalPoints;

  /// Unique referral code for sharing.
  final String referralCode;

  /// ID of the customer who referred this user.
  final String? referredById;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;
  /// Security question chosen during registration.
final String? securityQuestion;

/// Hashed security answer (never displayed, only used for verification).
final String? securityAnswer;

  const Customer({
    required this.id,
    required this.userId,
    required this.fullName,
    this.addressText,
    this.landmark,
    this.area,
    this.totalPoints = 0,
    required this.referralCode,
    this.referredById,
    required this.createdAt,
    required this.updatedAt,
    this.securityQuestion,
    this.securityAnswer,
  });

  /// Returns `true` if the customer has a delivery address set.
  bool get hasAddress =>
      addressText != null && addressText!.trim().isNotEmpty;

  /// Returns `true` if the customer has redeemable points.
  bool get hasPoints => totalPoints > 0;

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        addressText,
        landmark,
        area,
        totalPoints,
        referralCode,
        referredById,
        createdAt,
        updatedAt,
        securityQuestion,
        securityAnswer,
      ];
}