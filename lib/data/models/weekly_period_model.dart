// Data - Weekly period model with JSON serialization.
//
// Maps between the API JSON representation and the domain WeeklyPeriod entity.

import '../../domain/entities/weekly_period.dart';
import '../../domain/enums/period_status.dart';

/// Data model for [WeeklyPeriod] with JSON serialization support.
class WeeklyPeriodModel extends WeeklyPeriod {
  const WeeklyPeriodModel({
    required super.id,
    required super.year,
    required super.weekNumber,
    required super.startDate,
    required super.endDate,
    super.status,
    super.closedAt,
    super.closedBy,
    required super.createdAt,
  });

  /// Creates a [WeeklyPeriodModel] from a JSON map.
  factory WeeklyPeriodModel.fromJson(Map<String, dynamic> json) {
    return WeeklyPeriodModel(
      id: json['id'] as String,
      year: json['year'] as int,
      weekNumber: json['week_number'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      status: json['status'] != null
          ? PeriodStatus.fromValue(json['status'] as String)
          : PeriodStatus.active,
      closedAt: json['closed_at'] != null
          ? DateTime.parse(json['closed_at'] as String)
          : null,
      closedBy: json['closed_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Creates a [WeeklyPeriodModel] from a domain [WeeklyPeriod] entity.
  factory WeeklyPeriodModel.fromEntity(WeeklyPeriod period) {
    return WeeklyPeriodModel(
      id: period.id,
      year: period.year,
      weekNumber: period.weekNumber,
      startDate: period.startDate,
      endDate: period.endDate,
      status: period.status,
      closedAt: period.closedAt,
      closedBy: period.closedBy,
      createdAt: period.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'year': year,
      'week_number': weekNumber,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'status': status.value,
      'closed_at': closedAt?.toIso8601String(),
      'closed_by': closedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}