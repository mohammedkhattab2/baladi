// Domain - Settlement business rules.
//
// Pure Dart rules governing weekly settlement calculations
// for shops and riders. No external dependencies.

/// Business rules for weekly settlement calculations.
///
/// Defines the settlement week boundaries (Saturday–Friday, Cairo time)
/// and provides helpers for computing settlement amounts.
class SettlementRules {
  /// Week starts on Saturday at 00:00:00 Cairo time (UTC+2).
  static const int weekStartDay = DateTime.saturday;

  /// Week ends on Friday at 23:59:59 Cairo time (UTC+2).
  static const int weekEndDay = DateTime.friday;

  /// Cairo timezone offset in hours.
  static const int cairoUtcOffsetHours = 2;

  /// Calculate net payable to a shop for a settlement period.
  ///
  /// ```
  /// net = grossSales - totalCommission - adsExpenses
  /// ```
  static double calculateShopNetPayable({
    required double grossSales,
    required double totalCommission,
    required double pointsDiscounts,
    required double freeDeliveryCost,
    required double adsCost,
  }) {
    return grossSales - totalCommission;
  }

  /// Calculate admin net commission for a settlement period.
  ///
  /// ```
  /// adminNet = totalCommission - pointsDiscounts - freeDeliveryCost + adsRevenue
  /// ```
  static double calculateAdminNetCommission({
    required double totalCommission,
    required double pointsDiscounts,
    required double freeDeliveryCost,
    required double adsRevenue,
  }) {
    final net = totalCommission - pointsDiscounts - freeDeliveryCost + adsRevenue;
    return net < 0 ? 0 : net;
  }

  /// Calculate rider net earnings for a settlement period.
  ///
  /// For the MVP, riders earn delivery fees directly with no commission deducted.
  static double calculateRiderNetEarnings({
    required double totalDeliveryFees,
    required double commissionDeducted,
  }) {
    return totalDeliveryFees - commissionDeducted;
  }

  /// Returns `true` if the given [date] falls within the period
  /// defined by [periodStart] and [periodEnd].
  static bool isDateInPeriod(DateTime date, DateTime periodStart, DateTime periodEnd) {
    return !date.isBefore(periodStart) && !date.isAfter(periodEnd);
  }

  /// Calculates the start of the current settlement week (Saturday 00:00 Cairo).
  static DateTime currentWeekStart() {
    final now = DateTime.now().toUtc().add(const Duration(hours: cairoUtcOffsetHours));
    final daysSinceSaturday = (now.weekday - weekStartDay + 7) % 7;
    final saturday = DateTime(now.year, now.month, now.day - daysSinceSaturday);
    return saturday;
  }

  /// Calculates the end of the current settlement week (Friday 23:59:59 Cairo).
  static DateTime currentWeekEnd() {
    final start = currentWeekStart();
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
  }
}