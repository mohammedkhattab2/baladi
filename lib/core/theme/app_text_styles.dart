// Core - Application typography styles for the Baladi design system.
//
// Defines all text styles used throughout the app. Uses the Cairo font
// family for Arabic-friendly rendering with consistent sizing and weights.

import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application text style constants.
///
/// All styles use the Cairo font family which renders beautifully in
/// both Arabic and English. Sizes follow an 8-point scale for consistency.
class AppTextStyles {
  AppTextStyles._();

  /// Primary Arabic-friendly font family.
  static const String fontFamily = 'Cairo';

  // ─── Headlines ────────────────────────────────────────────────────

  /// H1 — largest headline (28px bold).
  static const TextStyle h1 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// H2 — section headline (24px semi-bold).
  static const TextStyle h2 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  /// H3 — sub-section headline (20px semi-bold).
  static const TextStyle h3 = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
  );

  // ─── Body ─────────────────────────────────────────────────────────

  /// Large body text (16px regular).
  static const TextStyle bodyLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Medium body text (14px regular) — default paragraph text.
  static const TextStyle bodyMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Small body text (12px regular).
  static const TextStyle bodySmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ─── Labels ───────────────────────────────────────────────────────

  /// Large label (14px semi-bold) — used for form labels and list titles.
  static const TextStyle labelLarge = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  /// Medium label (12px medium).
  static const TextStyle labelMedium = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  /// Small label (10px medium) — used for captions and badges.
  static const TextStyle labelSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  // ─── Button ───────────────────────────────────────────────────────

  /// Button text style (16px semi-bold with slight letter spacing).
  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  /// Small button text style (14px medium).
  static const TextStyle buttonSmall = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.3,
  );

  // ─── Special ──────────────────────────────────────────────────────

  /// Price display (20px bold) — used for currency values.
  static const TextStyle price = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Large number display (32px bold) — used for stats/counters.
  static const TextStyle displayNumber = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  /// Hint/placeholder text (14px regular).
  static const TextStyle hint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  /// Error message text (12px regular).
  static const TextStyle error = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.error,
  );
}