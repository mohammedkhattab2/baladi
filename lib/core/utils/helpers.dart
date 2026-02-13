// Core - Utility functions for generating codes, IDs, and date calculations.
//
// Provides helper functions used across the application for generating
// referral codes, order numbers, local IDs, and computing business-week periods.

import 'dart:math';

import '../constants/app_constants.dart';

/// General-purpose utility helper functions.
class Helpers {
  Helpers._();

  static final Random _random = Random.secure();

  /// Characters used for referral code generation (uppercase alphanumeric).
  static const String _alphanumeric = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

  // ─── Code / ID Generation ─────────────────────────────────────────────

  /// Generates a random referral code of [AppConstants.referralCodeLength] characters.
  ///
  /// The code consists of uppercase letters and digits.
  ///
  /// Example output: `"A3K9X2BF"`
  static String generateReferralCode() {
    return List.generate(
      AppConstants.referralCodeLength,
      (_) => _alphanumeric[_random.nextInt(_alphanumeric.length)],
    ).join();
  }

  /// Generates a human-readable order number based on the current timestamp.
  ///
  /// Format: `"ORD-{YEAR}-{5-digit-sequence}"`
  ///
  /// Example output: `"ORD-2026-48391"`
  static String generateOrderNumber() {
    final now = DateTime.now();
    final year = now.year;
    // Use the last 5 digits of the milliseconds since epoch for uniqueness
    final sequence =
        (now.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0');
    return 'ORD-$year-$sequence';
  }

  /// Generates a locally unique ID for offline-created entities.
  ///
  /// Format: `"local_{timestamp}_{random-4-digits}"`
  ///
  /// Example output: `"local_1707782400000_8274"`
  static String generateLocalId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomSuffix = _random.nextInt(10000).toString().padLeft(4, '0');
    return 'local_${timestamp}_$randomSuffix';
  }

  // ─── Date / Week Calculations ─────────────────────────────────────────

  /// Returns the start and end dates of the current business week.
  ///
  /// The business week runs Saturday (start) through Friday (end),
  /// aligned with Egyptian/Cairo business conventions.
  ///
  /// Returns a record `(DateTime startDate, DateTime endDate)` where both
  /// dates have their time set to the start/end of the respective day.
  static ({DateTime startDate, DateTime endDate}) getCurrentWeekPeriod() {
    final now = DateTime.now();
    return getWeekPeriodForDate(now);
  }

  /// Returns the start and end dates of the business week containing [date].
  ///
  /// Saturday is day 1, Friday is day 7.
  static ({DateTime startDate, DateTime endDate}) getWeekPeriodForDate(
    DateTime date,
  ) {
    // DateTime.weekday: Monday=1, Tuesday=2, ... Saturday=6, Sunday=7
    // We need Saturday as the start of the week.
    // Days since Saturday:
    //   Saturday(6) → 0, Sunday(7) → 1, Monday(1) → 2, Tuesday(2) → 3,
    //   Wednesday(3) → 4, Thursday(4) → 5, Friday(5) → 6
    final daysSinceSaturday = (date.weekday % 7 + 1) % 7;
    // Correct formula: Saturday=6 → 0, Sunday=7 → 1, Mon=1 → 2, ...
    // (weekday + 1) % 7 : Sat→0, Sun→1, Mon→2, Tue→3, Wed→4, Thu→5, Fri→6

    final startDate = DateTime(
      date.year,
      date.month,
      date.day - daysSinceSaturday,
    );
    final endDate = DateTime(
      startDate.year,
      startDate.month,
      startDate.day + 6,
      23,
      59,
      59,
    );

    return (startDate: startDate, endDate: endDate);
  }

  /// Returns the ISO 8601 week number for the given [date].
  ///
  /// Week 1 is the week containing the first Thursday of the year.
  static int getWeekNumber(DateTime date) {
    // ISO 8601: Week 1 contains the first Thursday of the year.
    // Algorithm from https://en.wikipedia.org/wiki/ISO_week_date
    final dayOfYear = _dayOfYear(date);
    final weekday = date.weekday; // Monday=1 ... Sunday=7
    final weekNumber = ((dayOfYear - weekday + 10) / 7).floor();

    if (weekNumber < 1) {
      // Belongs to the last week of the previous year
      final dec31 = DateTime(date.year - 1, 12, 31);
      return getWeekNumber(dec31);
    }

    if (weekNumber > 52) {
      // Check if it actually belongs to week 1 of the next year
      final dec31 = DateTime(date.year, 12, 31);
      final dec31Weekday = dec31.weekday;
      if (dec31Weekday < 4) {
        return 1;
      }
    }

    return weekNumber;
  }

  /// Returns the day of the year (1–366) for the given [date].
  static int _dayOfYear(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    return date.difference(startOfYear).inDays + 1;
  }

  // ─── Working Hours ────────────────────────────────────────────────────

  /// Checks if the current time falls within the given working hours.
  ///
  /// Returns `true` if both [open] and [close] are provided and the current
  /// time is between them (inclusive of open, exclusive of close).
  /// Returns `true` if either parameter is `null` (shop is always open).
  static bool isWithinWorkingHours({
    required DateTime? openTime,
    required DateTime? closeTime,
  }) {
    if (openTime == null || closeTime == null) {
      return true;
    }

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final openMinutes = openTime.hour * 60 + openTime.minute;
    final closeMinutes = closeTime.hour * 60 + closeTime.minute;

    // Handle overnight hours (e.g., open 22:00 → close 06:00)
    if (closeMinutes <= openMinutes) {
      return currentMinutes >= openMinutes || currentMinutes < closeMinutes;
    }

    return currentMinutes >= openMinutes && currentMinutes < closeMinutes;
  }
}