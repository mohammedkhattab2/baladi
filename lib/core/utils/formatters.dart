// Core - Currency, date, order number, phone, and points formatters.
//
// All methods are static and produce Arabic-friendly formatted strings
// suitable for direct display in the UI.

/// Static formatting methods for display values throughout the app.
class Formatters {
  Formatters._();

  // ─── Currency ─────────────────────────────────────────────────────────

  /// Formats an amount as Egyptian currency.
  ///
  /// Example: `formatCurrency(200)` → `"200.00 جنيه"`
  static String formatCurrency(double amount) {
    final formatted = amount.toStringAsFixed(2);
    return '$formatted جنيه';
  }

  // ─── Date / Time ──────────────────────────────────────────────────────

  /// Arabic month names (1-indexed; index 0 is unused).
  static const List<String> _arabicMonths = [
    '',
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  /// Arabic day-of-week names (Monday=1 … Sunday=7 per [DateTime.weekday]).
  static const List<String> _arabicDays = [
    '',
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  /// Formats a [DateTime] as an Arabic date string.
  ///
  /// Example: `"15 يناير 2026"`
  static String formatDate(DateTime date) {
    final month = _arabicMonths[date.month];
    return '${date.day} $month ${date.year}';
  }

  /// Formats a [DateTime] as an Arabic time string (24-hour).
  ///
  /// Example: `"14:05"`
  static String formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Formats a [DateTime] as an Arabic date and time string.
  ///
  /// Example: `"15 يناير 2026 - 14:05"`
  static String formatDateTime(DateTime dt) {
    return '${formatDate(dt)} - ${formatTime(dt)}';
  }

  /// Formats a [DateTime] as a relative time string in Arabic.
  ///
  /// Examples: `"الآن"`, `"منذ 5 دقائق"`, `"منذ ساعة"`, `"منذ 3 أيام"`
  static String formatRelativeTime(DateTime dt) {
    final now = DateTime.now();
    final difference = now.difference(dt);

    if (difference.isNegative) {
      return formatDateTime(dt);
    }

    if (difference.inSeconds < 60) {
      return 'الآن';
    }

    if (difference.inMinutes < 2) {
      return 'منذ دقيقة';
    }

    if (difference.inMinutes < 11) {
      return 'منذ ${difference.inMinutes} دقائق';
    }

    if (difference.inMinutes < 60) {
      return 'منذ ${difference.inMinutes} دقيقة';
    }

    if (difference.inHours < 2) {
      return 'منذ ساعة';
    }

    if (difference.inHours < 11) {
      return 'منذ ${difference.inHours} ساعات';
    }

    if (difference.inHours < 24) {
      return 'منذ ${difference.inHours} ساعة';
    }

    if (difference.inDays < 2) {
      return 'منذ يوم';
    }

    if (difference.inDays < 11) {
      return 'منذ ${difference.inDays} أيام';
    }

    if (difference.inDays < 30) {
      return 'منذ ${difference.inDays} يوم';
    }

    if (difference.inDays < 60) {
      return 'منذ شهر';
    }

    if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return months < 11 ? 'منذ $months أشهر' : 'منذ $months شهر';
    }

    final years = (difference.inDays / 365).floor();
    if (years < 2) {
      return 'منذ سنة';
    }
    return years < 11 ? 'منذ $years سنوات' : 'منذ $years سنة';
  }

  /// Returns the Arabic day-of-week name for a [DateTime].
  static String dayOfWeek(DateTime date) {
    return _arabicDays[date.weekday];
  }

  // ─── Order ────────────────────────────────────────────────────────────

  /// Formats an order number for display.
  ///
  /// Example: `formatOrderNumber("1234")` → `"طلب #1234"`
  static String formatOrderNumber(String number) {
    return 'طلب #$number';
  }

  // ─── Phone ────────────────────────────────────────────────────────────

  /// Formats a phone number for display.
  ///
  /// Example: `formatPhone("01012345678")` → `"010-1234-5678"`
  static String formatPhone(String phone) {
    final cleaned = phone.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleaned.length == 11) {
      return '${cleaned.substring(0, 3)}-${cleaned.substring(3, 7)}-${cleaned.substring(7)}';
    }
    return phone;
  }

  // ─── Points ───────────────────────────────────────────────────────────

  /// Formats loyalty points for display.
  ///
  /// Example: `formatPoints(25)` → `"25 نقطة"`
  static String formatPoints(int points) {
    return '$points نقطة';
  }

  // ─── Percentage ───────────────────────────────────────────────────────

  /// Formats a decimal rate as a percentage string.
  ///
  /// Example: `formatPercentage(0.10)` → `"10%"`
  static String formatPercentage(double rate) {
    final percent = (rate * 100).round();
    return '$percent%';
  }

  /// Formats a number with thousand separators for display.
  ///
  /// Example: `formatNumber(1500)` → `"1,500"`
  static String formatNumber(int number) {
    if (number < 0) {
      return '-${formatNumber(-number)}';
    }
    final str = number.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}