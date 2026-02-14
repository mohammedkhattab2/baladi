// Domain - Ad type enumeration.
//
// Defines the types of advertisements that shops can create
// in the Baladi platform. Maps to the `ad_type` column in the ads table.

/// The type of advertisement posted by a shop.
enum AdType {
  /// A time-limited daily special offer.
  dailyOffer('daily_offer', 'عرض يومي'),

  /// A banner displayed on the customer home screen.
  banner('banner', 'بانر'),

  /// A featured shop placement at the top of listings.
  featured('featured', 'مميز');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const AdType(this.value, this.labelAr);

  /// Creates an [AdType] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any type.
  static AdType fromValue(String value) {
    return AdType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => throw ArgumentError('Unknown AdType: $value'),
    );
  }
}