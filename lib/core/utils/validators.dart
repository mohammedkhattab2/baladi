/// Input validators for the application.
///
/// These are pure validation functions used across the app
/// for form validation and data integrity checks.
///
/// Architecture note: Validators are core utilities, not business rules.
/// They check format/structure, not business logic.
library;

/// Validation result containing success status and error message.
class ValidationResult {
  final bool isValid;
  final String? errorMessage;

  const ValidationResult._(this.isValid, this.errorMessage);

  factory ValidationResult.valid() => const ValidationResult._(true, null);
  factory ValidationResult.invalid(String message) =>
      ValidationResult._(false, message);
}

/// Collection of input validators.
class Validators {
  Validators._();

  /// Validates Egyptian phone number format.
  /// Accepts: 01xxxxxxxxx (11 digits starting with 01)
  static ValidationResult phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('Phone number is required');
    }

    final cleaned = value.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Egyptian mobile format: 01xxxxxxxxx (11 digits)
    if (!RegExp(r'^01[0-9]{9}$').hasMatch(cleaned)) {
      return ValidationResult.invalid('Please enter a valid phone number');
    }

    return ValidationResult.valid();
  }

  /// Validates 4-digit PIN.
  static ValidationResult pin(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('PIN is required');
    }

    if (value.length != 4) {
      return ValidationResult.invalid('PIN must be 4 digits');
    }

    if (!RegExp(r'^[0-9]{4}$').hasMatch(value)) {
      return ValidationResult.invalid('PIN must contain only numbers');
    }

    // Check for simple patterns (optional security enhancement)
    if (_isSimplePin(value)) {
      return ValidationResult.invalid('Please choose a stronger PIN');
    }

    return ValidationResult.valid();
  }

  /// Checks if PIN is too simple (e.g., 1234, 0000, 1111).
  static bool _isSimplePin(String pin) {
    // All same digits
    if (RegExp(r'^(.)\1{3}$').hasMatch(pin)) return true;

    // Sequential ascending (1234, 2345, etc.)
    if (_isSequential(pin, ascending: true)) return true;

    // Sequential descending (4321, 5432, etc.)
    if (_isSequential(pin, ascending: false)) return true;

    return false;
  }

  static bool _isSequential(String pin, {required bool ascending}) {
    for (int i = 0; i < pin.length - 1; i++) {
      final current = int.parse(pin[i]);
      final next = int.parse(pin[i + 1]);
      final diff = ascending ? next - current : current - next;
      if (diff != 1) return false;
    }
    return true;
  }

  /// Validates username format.
  static ValidationResult username(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('Username is required');
    }

    if (value.length < 3) {
      return ValidationResult.invalid('Username must be at least 3 characters');
    }

    if (value.length > 30) {
      return ValidationResult.invalid('Username must be at most 30 characters');
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
      return ValidationResult.invalid(
        'Username can only contain letters, numbers, and underscores',
      );
    }

    return ValidationResult.valid();
  }

  /// Validates password strength.
  static ValidationResult password(String? value) {
    if (value == null || value.isEmpty) {
      return ValidationResult.invalid('Password is required');
    }

    if (value.length < 6) {
      return ValidationResult.invalid('Password must be at least 6 characters');
    }

    return ValidationResult.valid();
  }

  /// Validates required text field.
  static ValidationResult required(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.invalid('$fieldName is required');
    }
    return ValidationResult.valid();
  }

  /// Validates minimum length.
  static ValidationResult minLength(
    String? value, {
    required int min,
    String fieldName = 'Field',
  }) {
    if (value == null || value.length < min) {
      return ValidationResult.invalid(
        '$fieldName must be at least $min characters',
      );
    }
    return ValidationResult.valid();
  }

  /// Validates maximum length.
  static ValidationResult maxLength(
    String? value, {
    required int max,
    String fieldName = 'Field',
  }) {
    if (value != null && value.length > max) {
      return ValidationResult.invalid(
        '$fieldName must be at most $max characters',
      );
    }
    return ValidationResult.valid();
  }

  /// Validates positive number.
  static ValidationResult positiveNumber(num? value, {String fieldName = 'Value'}) {
    if (value == null) {
      return ValidationResult.invalid('$fieldName is required');
    }
    if (value <= 0) {
      return ValidationResult.invalid('$fieldName must be greater than 0');
    }
    return ValidationResult.valid();
  }

  /// Validates non-negative number.
  static ValidationResult nonNegativeNumber(num? value, {String fieldName = 'Value'}) {
    if (value == null) {
      return ValidationResult.invalid('$fieldName is required');
    }
    if (value < 0) {
      return ValidationResult.invalid('$fieldName cannot be negative');
    }
    return ValidationResult.valid();
  }
}