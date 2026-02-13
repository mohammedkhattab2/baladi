// Core - Input validation utilities with Arabic error messages.
//
// All methods are static and return `String?` — `null` means the input
// is valid, a non-null `String` is the Arabic error message for the user.

import '../constants/app_constants.dart';

/// Static input validation methods for forms and user input.
class Validators {
  Validators._();

  /// Validates an Egyptian phone number.
  ///
  /// Must start with `01` and be exactly 11 digits.
  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    final phone = value.trim();
    if (!RegExp(r'^01[0-9]{9}$').hasMatch(phone)) {
      return 'رقم الهاتف يجب أن يبدأ بـ 01 ويتكون من 11 رقم';
    }
    return null;
  }

  /// Validates a numeric PIN code.
  ///
  /// Must be 4–6 digits only.
  static String? validatePin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رمز PIN مطلوب';
    }
    final pin = value.trim();
    if (!RegExp(r'^\d{4,6}$').hasMatch(pin)) {
      return 'رمز PIN يجب أن يتكون من 4 إلى 6 أرقام';
    }
    return null;
  }

  /// Validates a strong password.
  ///
  /// Minimum 8 characters, at least one uppercase, one lowercase, and one digit.
  static String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    final password = value.trim();
    if (password.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير واحد على الأقل';
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير واحد على الأقل';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'كلمة المرور يجب أن تحتوي على رقم واحد على الأقل';
    }
    return null;
  }

  /// Validates a person's name (Arabic or English letters).
  ///
  /// Must be 2–100 characters, letters and spaces only.
  static String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'الاسم مطلوب';
    }
    final name = value.trim();
    if (name.length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    if (name.length > 100) {
      return 'الاسم يجب أن لا يتجاوز 100 حرف';
    }
    // Allow Arabic letters, English letters, spaces, hyphens, and dots
    if (!RegExp(r'^[\u0600-\u06FFa-zA-Z\s\.\-]+$').hasMatch(name)) {
      return 'الاسم يجب أن يحتوي على حروف عربية أو إنجليزية فقط';
    }
    return null;
  }

  /// Validates a delivery address.
  ///
  /// Must not be empty and must be at most 255 characters.
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'العنوان مطلوب';
    }
    final address = value.trim();
    if (address.length > AppConstants.maxAddressLength) {
      return 'العنوان يجب أن لا يتجاوز ${AppConstants.maxAddressLength} حرف';
    }
    return null;
  }

  /// Validates an item quantity.
  ///
  /// Must be a positive integer.
  static String? validateQuantity(int? value) {
    if (value == null) {
      return 'الكمية مطلوبة';
    }
    if (value <= 0) {
      return 'الكمية يجب أن تكون رقم موجب';
    }
    return null;
  }

  /// Validates a price value.
  ///
  /// Must be a positive number.
  static String? validatePrice(double? value) {
    if (value == null) {
      return 'السعر مطلوب';
    }
    if (value <= 0) {
      return 'السعر يجب أن يكون رقم موجب';
    }
    return null;
  }

  /// Validates optional notes text.
  ///
  /// If provided, must not exceed 500 characters.
  static String? validateNotes(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Notes are optional
    }
    if (value.trim().length > AppConstants.maxOrderNotes) {
      return 'الملاحظات يجب أن لا تتجاوز ${AppConstants.maxOrderNotes} حرف';
    }
    return null;
  }

  /// Validates a referral code.
  ///
  /// Must be alphanumeric and exactly [AppConstants.referralCodeLength] characters.
  static String? validateReferralCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'رمز الإحالة مطلوب';
    }
    final code = value.trim();
    if (code.length != AppConstants.referralCodeLength) {
      return 'رمز الإحالة يجب أن يتكون من ${AppConstants.referralCodeLength} أحرف';
    }
    if (!RegExp(r'^[A-Za-z0-9]+$').hasMatch(code)) {
      return 'رمز الإحالة يجب أن يحتوي على حروف وأرقام فقط';
    }
    return null;
  }
}