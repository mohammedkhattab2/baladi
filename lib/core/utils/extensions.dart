// Core - Dart/Flutter extension methods for String, DateTime, num, and BuildContext.
//
// Provides ergonomic helper getters and methods on built-in types
// to reduce boilerplate throughout the application.

import 'package:flutter/material.dart';

import 'formatters.dart';

// ─── String Extensions ────────────────────────────────────────────────────

/// Convenience extensions on [String].
extension StringExtensions on String {
  /// Whether this string is a valid Egyptian phone number (starts with 01, 11 digits).
  bool get isValidPhone => RegExp(r'^01[0-9]{9}$').hasMatch(trim());

  /// Whether this string is a valid numeric PIN (4–6 digits).
  bool get isValidPin => RegExp(r'^\d{4,6}$').hasMatch(trim());

  /// Whether this string is not null, not empty, and not only whitespace.
  bool get isNotBlank => trim().isNotEmpty;

  /// Returns this string with the first character capitalized.
  ///
  /// Example: `"hello"` → `"Hello"`
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Converts Western Arabic numerals (0-9) to Eastern Arabic numerals (٠-٩).
  ///
  /// Example: `"123"` → `"١٢٣"`
  String get toArabicDigits {
    const western = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const eastern = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    var result = this;
    for (var i = 0; i < western.length; i++) {
      result = result.replaceAll(western[i], eastern[i]);
    }
    return result;
  }
}

// ─── Nullable String Extensions ───────────────────────────────────────────

/// Convenience extensions on nullable [String].
extension NullableStringExtensions on String? {
  /// Whether this string is null, empty, or only whitespace.
  bool get isBlank => this == null || this!.trim().isEmpty;

  /// Whether this string is not null, not empty, and not only whitespace.
  bool get isNotBlank => !isBlank;
}

// ─── DateTime Extensions ──────────────────────────────────────────────────

/// Convenience extensions on [DateTime].
extension DateTimeExtensions on DateTime {
  /// Whether this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Whether this date falls within the current calendar week (Saturday–Friday).
  bool get isThisWeek {
    final now = DateTime.now();
    // Calculate the start of the current week (Saturday)
    final daysSinceSaturday = (now.weekday + 1) % 7;
    final weekStart = DateTime(now.year, now.month, now.day - daysSinceSaturday);
    final weekEnd = weekStart.add(const Duration(days: 7));
    return !isBefore(weekStart) && isBefore(weekEnd);
  }

  /// Formats this date as an Arabic date string (e.g. `"15 يناير 2026"`).
  String get toFormattedDate => Formatters.formatDate(this);

  /// Formats this date's time component (e.g. `"14:05"`).
  String get toFormattedTime => Formatters.formatTime(this);

  /// Formats this date as a relative time string (e.g. `"منذ 5 دقائق"`).
  String get toRelative => Formatters.formatRelativeTime(this);

  /// Returns a new [DateTime] at the start of this day (00:00:00.000).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns a new [DateTime] at the end of this day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the [DateTime] of the start of the business week (Saturday) containing this date.
  DateTime get startOfWeek {
    final daysSinceSaturday = (weekday + 1) % 7;
    return DateTime(year, month, day - daysSinceSaturday);
  }

  /// Returns the [DateTime] of the end of the business week (Friday 23:59:59) containing this date.
  DateTime get endOfWeek {
    final start = startOfWeek;
    return DateTime(start.year, start.month, start.day + 6, 23, 59, 59);
  }
}

// ─── Num Extensions ───────────────────────────────────────────────────────

/// Convenience extensions on [num].
extension NumExtensions on num {
  /// Formats this number as Egyptian currency (e.g. `"200.00 جنيه"`).
  String get toCurrency => Formatters.formatCurrency(toDouble());

  /// Formats this number as loyalty points (e.g. `"25 نقطة"`).
  String get toPoints => Formatters.formatPoints(toInt());
}

// ─── BuildContext Extensions ──────────────────────────────────────────────

/// Convenience extensions on [BuildContext] for screen metrics and snack bars.
extension ContextExtensions on BuildContext {
  /// The width of the screen in logical pixels.
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// The height of the screen in logical pixels.
  double get screenHeight => MediaQuery.sizeOf(this).height;

  /// The current [ThemeData].
  ThemeData get theme => Theme.of(this);

  /// The current [TextTheme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// The current [ColorScheme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Shows a neutral [SnackBar] with the given [message].
  void showSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Shows an error [SnackBar] with a red background.
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  /// Shows a success [SnackBar] with a green background.
  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}