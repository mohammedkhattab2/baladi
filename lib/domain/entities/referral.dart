// Domain - Referral entity.
//
// Represents a referral relationship between two customers
// in the loyalty system. The referrer earns bonus points when
// the referred customer completes their first order.

import 'package:equatable/equatable.dart';

import '../enums/referral_status.dart';

/// A referral linking a referrer to a referred customer.
///
/// Tracks whether the referred customer completed their first order
/// and whether bonus points have been awarded to the referrer.
class Referral extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The customer who shared the referral code.
  final String referrerId;

  /// The customer who used the referral code.
  final String referredId;

  /// The first order placed by the referred customer (null until placed).
  final String? firstOrderId;

  /// Whether bonus points have been awarded to the referrer.
  final bool pointsAwarded;

  /// Current status of the referral.
  final ReferralStatus status;

  /// When the referral was created.
  final DateTime createdAt;

  /// When the referral was completed (first order placed).
  final DateTime? completedAt;

  const Referral({
    required this.id,
    required this.referrerId,
    required this.referredId,
    this.firstOrderId,
    this.pointsAwarded = false,
    this.status = ReferralStatus.pending,
    required this.createdAt,
    this.completedAt,
  });

  /// Returns `true` if the referral is still pending completion.
  bool get isPending => status.isPending;

  /// Returns `true` if the referral has been completed and points awarded.
  bool get isCompleted => status.isCompleted;

  @override
  List<Object?> get props => [
        id,
        referrerId,
        referredId,
        firstOrderId,
        pointsAwarded,
        status,
        createdAt,
        completedAt,
      ];
}