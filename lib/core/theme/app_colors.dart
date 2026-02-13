// Core - Application color palette for the Baladi design system.
//
// Provides all color constants used throughout the app, organized by
// category: primary, secondary, background, text, status, order status,
// and category-specific colors.

import 'package:flutter/material.dart';

/// Application color palette constants.
///
/// All colors follow the Baladi design system with warm, natural,
/// village-friendly tones that convey trust and clarity.
class AppColors {
  AppColors._();

  // ─── Primary — Warm & Trustworthy ─────────────────────────────────

  /// Forest Green — main brand color.
  static const Color primary = Color(0xFF2D5A27);

  /// Light Green — lighter variant for hover/active states.
  static const Color primaryLight = Color(0xFF4A7C43);

  /// Dark Green — darker variant for emphasis.
  static const Color primaryDark = Color(0xFF1A3A16);

  // ─── Secondary — Warm Accent ──────────────────────────────────────

  /// Warm Sand — accent color.
  static const Color secondary = Color(0xFFD4A574);

  /// Light Sand — lighter accent variant.
  static const Color secondaryLight = Color(0xFFE8C9A0);

  // ─── Background ───────────────────────────────────────────────────

  /// Warm White — main background color.
  static const Color background = Color(0xFFFAF8F5);

  /// Pure White — card/surface background.
  static const Color surface = Color(0xFFFFFFFF);

  /// Light Beige — surface variant for inputs and secondary surfaces.
  static const Color surfaceVariant = Color(0xFFF5F2ED);

  // ─── Text ─────────────────────────────────────────────────────────

  /// Near Black — primary text color.
  static const Color textPrimary = Color(0xFF1A1A1A);

  /// Medium Grey — secondary text color.
  static const Color textSecondary = Color(0xFF6B6B6B);

  /// Light Grey — hint/placeholder text.
  static const Color textHint = Color(0xFF9E9E9E);

  /// White text for use on dark/colored backgrounds.
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ─── Status ───────────────────────────────────────────────────────

  /// Green — success / positive actions.
  static const Color success = Color(0xFF4CAF50);

  /// Orange — warning / attention needed.
  static const Color warning = Color(0xFFFF9800);

  /// Red — error / destructive actions.
  static const Color error = Color(0xFFE53935);

  /// Blue — informational / neutral status.
  static const Color info = Color(0xFF2196F3);

  // ─── Order Status Colors ──────────────────────────────────────────

  /// Orange — Pending (قيد الانتظار).
  static const Color statusPending = Color(0xFFFF9800);

  /// Blue — Accepted (مقبول).
  static const Color statusAccepted = Color(0xFF2196F3);

  /// Purple — Preparing (جاري التحضير).
  static const Color statusPreparing = Color(0xFF9C27B0);

  /// Cyan — Picked Up (تم الاستلام).
  static const Color statusPickedUp = Color(0xFF00BCD4);

  /// Light Green — Shop Paid (تم الدفع للمتجر).
  static const Color statusShopPaid = Color(0xFF8BC34A);

  /// Green — Completed (مكتمل).
  static const Color statusCompleted = Color(0xFF4CAF50);

  /// Red — Cancelled (ملغي).
  static const Color statusCancelled = Color(0xFFE53935);

  // ─── Category Colors ──────────────────────────────────────────────

  /// Restaurants (مطاعم).
  static const Color categoryRestaurants = Color(0xFFFF6B35);

  /// Bakeries (مخابز).
  static const Color categoryBakeries = Color(0xFFF7C59F);

  /// Pharmacies (صيدليات).
  static const Color categoryPharmacies = Color(0xFF2EC4B6);

  /// Cosmetics (مستحضرات تجميل).
  static const Color categoryCosmetics = Color(0xFFE71D73);

  /// Daily Habit (احتياجات يومية).
  static const Color categoryDailyHabit = Color(0xFF7B2CBF);

  // ─── Divider / Border ─────────────────────────────────────────────

  /// Light divider color.
  static const Color divider = Color(0xFFE0E0E0);

  /// Border color for cards and inputs.
  static const Color border = Color(0xFFD0D0D0);

  // ─── Shimmer ──────────────────────────────────────────────────────

  /// Shimmer base color for loading placeholders.
  static const Color shimmerBase = Color(0xFFE0E0E0);

  /// Shimmer highlight color for loading placeholders.
  static const Color shimmerHighlight = Color(0xFFF5F5F5);
}