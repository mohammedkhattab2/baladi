// Domain - Ad entity.
//
// Represents a promotional advertisement created by a shop,
// displayed on the customer home screen.

import 'package:equatable/equatable.dart';

/// A shop advertisement (daily offer) displayed to customers.
///
/// Shops pay a daily fee for ads, which is deducted from their
/// weekly settlement. Ads are shown during their active date range.
class Ad extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The shop that created this ad.
  final String shopId;

  /// Ad title in English.
  final String title;

  /// Ad title in Arabic.
  final String? titleAr;

  /// Ad description text.
  final String? description;

  /// URL to the ad image.
  final String? imageUrl;

  /// Daily cost charged to the shop (in EGP).
  final double dailyCost;

  /// First day the ad is shown.
  final DateTime startDate;

  /// Last day the ad is shown.
  final DateTime endDate;

  /// Whether the ad is currently active.
  final bool isActive;

  /// Total accumulated cost for the ad period.
  final double totalCost;

  /// When the ad was created.
  final DateTime createdAt;

  const Ad({
    required this.id,
    required this.shopId,
    required this.title,
    this.titleAr,
    this.description,
    this.imageUrl,
    this.dailyCost = 10.0,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    this.totalCost = 0,
    required this.createdAt,
  });

  /// Returns the display title — Arabic if available, otherwise English.
  String get displayTitle => titleAr ?? title;

  /// Returns `true` if the ad is currently within its display period.
  bool get isCurrentlyShowing {
    final now = DateTime.now();
    return isActive &&
        now.isAfter(startDate.subtract(const Duration(days: 1))) &&
        now.isBefore(endDate.add(const Duration(days: 1)));
  }

  /// Number of days the ad runs.
  int get durationDays => endDate.difference(startDate).inDays + 1;

  @override
  List<Object?> get props => [
        id,
        shopId,
        title,
        titleAr,
        description,
        imageUrl,
        dailyCost,
        startDate,
        endDate,
        isActive,
        totalCost,
        createdAt,
      ];
}