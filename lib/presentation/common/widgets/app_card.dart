// Presentation - Common reusable card widget for the Baladi design system.
//
// Provides styled card containers with consistent shadows, border radius,
// and padding following the warm, village-friendly Baladi aesthetic.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A design-system-consistent card widget.
///
/// Wraps content in a rounded container with a subtle shadow, optional
/// header, tap action, and border highlight for status indication.
///
/// Example usage:
/// ```dart
/// AppCard(
///   child: Text('Hello Baladi'),
///   onTap: () => _navigate(),
/// )
/// ```
class AppCard extends StatelessWidget {
  /// The card content.
  final Widget child;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  /// Called when the card is long-pressed.
  final VoidCallback? onLongPress;

  /// Inner padding. Defaults to 16 on all sides.
  final EdgeInsetsGeometry padding;

  /// Outer margin. Defaults to zero (caller controls spacing).
  final EdgeInsetsGeometry margin;

  /// Card background color. Defaults to [AppColors.surface].
  final Color? backgroundColor;

  /// Optional left border color for status indication.
  final Color? borderColor;

  /// Left border width when [borderColor] is set. Defaults to 4.
  final double borderWidth;

  /// Corner radius. Defaults to 16.
  final double borderRadius;

  /// Shadow elevation. Defaults to 2.
  final double elevation;

  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 4,
    this.borderRadius = 16,
    this.elevation = 2,
  });

  /// Creates a flat card with no elevation.
  const AppCard.flat({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 4,
    this.borderRadius = 16,
  }) : elevation = 0;

  /// Creates a card with an outlined border.
  const AppCard.outlined({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1,
    this.borderRadius = 16,
  }) : elevation = 0;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.surface;
    final radius = BorderRadius.circular(borderRadius);

    Widget card = Container(
      margin: margin,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: borderColor != null
            ? Border(
                right: BorderSide(
                  color: borderColor!,
                  width: borderWidth,
                ),
              )
            : elevation == 0
                ? Border.all(color: AppColors.border.withValues(alpha: 0.3))
                : null,
        boxShadow: elevation > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: elevation * 4,
                  offset: Offset(0, elevation),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );

    if (onTap != null || onLongPress != null) {
      card = Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          onLongPress: onLongPress,
          borderRadius: radius,
          child: card,
        ),
      );
    }

    return card;
  }
}

/// A card variant with a header title and optional trailing action.
///
/// Example usage:
/// ```dart
/// AppSectionCard(
///   title: 'ملخص الأسبوع',
///   trailing: TextButton(onPressed: () {}, child: Text('عرض الكل')),
///   child: WeeklySummaryContent(),
/// )
/// ```
class AppSectionCard extends StatelessWidget {
  /// The section title.
  final String title;

  /// Optional trailing widget (e.g. a "view all" button).
  final Widget? trailing;

  /// The section content.
  final Widget child;

  /// Inner padding for the content area.
  final EdgeInsetsGeometry contentPadding;

  /// Outer margin. Defaults to zero.
  final EdgeInsetsGeometry margin;

  const AppSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.trailing,
    this.contentPadding = const EdgeInsets.fromLTRB(16, 0, 16, 16),
    this.margin = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.zero,
      margin: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // ─── Header ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(title, style: AppTextStyles.h3),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),

          // ─── Content ─────────────────────────────────────────
          Padding(
            padding: contentPadding,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// A simple stat/metric card for dashboards.
///
/// Displays a numeric value with a label and optional icon.
///
/// Example usage:
/// ```dart
/// AppStatCard(
///   label: 'طلب',
///   value: '15',
///   icon: Icons.shopping_bag_outlined,
///   color: AppColors.primary,
/// )
/// ```
class AppStatCard extends StatelessWidget {
  /// The stat label (e.g. "طلب", "جنيه").
  final String label;

  /// The stat value (e.g. "15", "2,450").
  final String value;

  /// Optional icon displayed above the value.
  final IconData? icon;

  /// The accent color for the icon and value. Defaults to [AppColors.primary].
  final Color color;

  /// Called when the card is tapped.
  final VoidCallback? onTap;

  const AppStatCard({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.color = AppColors.primary,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
          ],
          Text(
            value,
            style: AppTextStyles.displayNumber.copyWith(color: color),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}