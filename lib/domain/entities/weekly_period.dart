// Domain - Weekly period entity.
//
// Represents a Saturday–Friday settlement week used for
// calculating shop and rider settlements.

import 'package:equatable/equatable.dart';

import '../enums/period_status.dart';

/// A weekly settlement period (Saturday 00:00 – Friday 23:59 Cairo time).
///
/// Orders are assigned to the period in which they were created.
/// At the end of the week, the admin closes the period and
/// settlements are calculated for each shop and rider.
class WeeklyPeriod extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// Calendar year.
  final int year;

  /// ISO week number within the year.
  final int weekNumber;

  /// Start date of the period (Saturday).
  final DateTime startDate;

  /// End date of the period (Friday).
  final DateTime endDate;

  /// Current status of the period.
  final PeriodStatus status;

  /// When the period was closed by the admin.
  final DateTime? closedAt;

  /// Admin user ID who closed the period.
  final String? closedBy;

  /// When the period record was created.
  final DateTime createdAt;

  const WeeklyPeriod({
    required this.id,
    required this.year,
    required this.weekNumber,
    required this.startDate,
    required this.endDate,
    this.status = PeriodStatus.active,
    this.closedAt,
    this.closedBy,
    required this.createdAt,
  });

  /// Returns `true` if the period is still accepting orders.
  bool get isActive => status == PeriodStatus.active;

  /// Returns `true` if the period is fully settled.
  bool get isSettled => status == PeriodStatus.settled;

  /// Returns a display label like "الأسبوع 3 - 2026".
  String get displayLabel => 'الأسبوع $weekNumber - $year';

  @override
  List<Object?> get props => [
        id,
        year,
        weekNumber,
        startDate,
        endDate,
        status,
        closedAt,
        closedBy,
        createdAt,
      ];
}