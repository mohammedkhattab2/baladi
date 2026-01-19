/// Dart extensions for the application.
///
/// These are utility extensions that enhance built-in types
/// with commonly needed functionality.
///
/// Architecture note: Extensions are core utilities that don't
/// contain business logic.
library;

/// Extensions on String.
extension StringExtensions on String {
  /// Capitalizes the first letter of the string.
  String get capitalize {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  /// Capitalizes the first letter of each word.
  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize).join(' ');
  }

  /// Removes all whitespace from the string.
  String get removeWhitespace => replaceAll(RegExp(r'\s+'), '');

  /// Checks if string is a valid email format.
  bool get isValidEmail {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(this);
  }

  /// Checks if string contains only digits.
  bool get isNumeric => RegExp(r'^[0-9]+$').hasMatch(this);

  /// Truncates string to specified length with ellipsis.
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Converts string to nullable int.
  int? toIntOrNull() => int.tryParse(this);

  /// Converts string to nullable double.
  double? toDoubleOrNull() => double.tryParse(this);
}

/// Extensions on nullable String.
extension NullableStringExtensions on String? {
  /// Returns true if string is null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns true if string is not null and not empty.
  bool get isNotNullOrEmpty => this != null && this!.isNotEmpty;

  /// Returns the string or empty string if null.
  String get orEmpty => this ?? '';

  /// Returns the string or default value if null or empty.
  String orDefault(String defaultValue) {
    return isNullOrEmpty ? defaultValue : this!;
  }
}

/// Extensions on DateTime.
extension DateTimeExtensions on DateTime {
  /// Returns true if this date is today.
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Returns true if this date is yesterday.
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year &&
        month == yesterday.month &&
        day == yesterday.day;
  }

  /// Returns true if this date is in the past.
  bool get isPast => isBefore(DateTime.now());

  /// Returns true if this date is in the future.
  bool get isFuture => isAfter(DateTime.now());

  /// Returns the start of the day (00:00:00).
  DateTime get startOfDay => DateTime(year, month, day);

  /// Returns the end of the day (23:59:59.999).
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  /// Returns the start of the week (Saturday for Egypt).
  DateTime get startOfWeek {
    // Saturday is the start of the week in Egypt
    final daysFromSaturday = (weekday + 1) % 7;
    return subtract(Duration(days: daysFromSaturday)).startOfDay;
  }

  /// Returns the end of the week (Friday for Egypt).
  DateTime get endOfWeek {
    return startOfWeek.add(const Duration(days: 6)).endOfDay;
  }

  /// Formats date as short date string (e.g., "19 Jan").
  String get shortDate {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '$day ${months[month - 1]}';
  }

  /// Formats date as full date string (e.g., "19 January 2026").
  String get fullDate {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return '$day ${months[month - 1]} $year';
  }

  /// Formats time as HH:MM (24-hour format).
  String get time24 {
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }

  /// Formats time as HH:MM AM/PM (12-hour format).
  String get time12 {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final period = hour < 12 ? 'AM' : 'PM';
    return '${h.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
  }
}

/// Extensions on num (int and double).
extension NumExtensions on num {
  /// Formats number as currency (Egyptian Pound).
  String get asEGP => '${toStringAsFixed(2)} EGP';

  /// Formats number as currency without decimals.
  String get asEGPRounded => '${round()} EGP';

  /// Checks if number is between min and max (inclusive).
  bool isBetween(num min, num max) => this >= min && this <= max;

  /// Clamps number between min and max.
  num clampTo(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }
}

/// Extensions on List.
extension ListExtensions<T> on List<T> {
  /// Returns first element or null if empty.
  T? get firstOrNull => isEmpty ? null : first;

  /// Returns last element or null if empty.
  T? get lastOrNull => isEmpty ? null : last;

  /// Returns element at index or null if out of bounds.
  T? getOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Returns a new list with duplicates removed based on key.
  List<T> distinctBy<K>(K Function(T element) keyOf) {
    final seen = <K>{};
    return where((element) => seen.add(keyOf(element))).toList();
  }
}

/// Extensions on Map.
extension MapExtensions<K, V> on Map<K, V> {
  /// Returns value for key or null if not found.
  V? getOrNull(K key) => containsKey(key) ? this[key] : null;

  /// Returns a new map with only the specified keys.
  Map<K, V> pick(Iterable<K> keys) {
    return Map.fromEntries(
      entries.where((entry) => keys.contains(entry.key)),
    );
  }

  /// Returns a new map without the specified keys.
  Map<K, V> omit(Iterable<K> keys) {
    return Map.fromEntries(
      entries.where((entry) => !keys.contains(entry.key)),
    );
  }
}