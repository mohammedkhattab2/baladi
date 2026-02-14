// Presentation - Common reusable button widget for the Baladi design system.
//
// Provides primary, secondary, text, and icon button variants with
// consistent styling, loading states, and large touch targets for
// village-friendly UX.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// The visual variant of an [AppButton].
enum AppButtonVariant {
  /// Filled button with primary background color.
  primary,

  /// Outlined button with primary border.
  secondary,

  /// Text-only button with no background or border.
  text,

  /// Danger button with error/red color.
  danger,
}

/// The size preset for an [AppButton].
enum AppButtonSize {
  /// Small button — 40px height, 14px font.
  small,

  /// Medium button — 48px height, 14px font.
  medium,

  /// Large button — 56px height, 16px font (default).
  large,
}

/// A versatile, design-system-consistent button widget.
///
/// Supports multiple [AppButtonVariant]s and [AppButtonSize]s with optional
/// leading/trailing icons, loading state, and full-width layout.
///
/// Example usage:
/// ```dart
/// AppButton(
///   text: 'تسجيل الدخول',
///   onPressed: () => _login(),
///   variant: AppButtonVariant.primary,
///   isLoading: state is AuthLoading,
/// )
/// ```
class AppButton extends StatelessWidget {
  /// The button label text.
  final String text;

  /// Called when the button is tapped. If `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// The visual variant of the button.
  final AppButtonVariant variant;

  /// The size preset of the button.
  final AppButtonSize size;

  /// Whether to show a loading spinner instead of the label.
  final bool isLoading;

  /// Whether the button should expand to fill the available width.
  final bool isFullWidth;

  /// Optional icon displayed before the label text.
  final IconData? leadingIcon;

  /// Optional icon displayed after the label text.
  final IconData? trailingIcon;

  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  });

  /// Creates a primary filled button.
  const AppButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.primary;

  /// Creates a secondary outlined button.
  const AppButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.secondary;

  /// Creates a text-only button.
  const AppButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = false,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.text;

  /// Creates a danger/destructive button.
  const AppButton.danger({
    super.key,
    required this.text,
    this.onPressed,
    this.size = AppButtonSize.large,
    this.isLoading = false,
    this.isFullWidth = true,
    this.leadingIcon,
    this.trailingIcon,
  }) : variant = AppButtonVariant.danger;

  @override
  Widget build(BuildContext context) {
    final isDisabled = onPressed == null || isLoading;

    final child = _buildChild();

    final Widget button = switch (variant) {
      AppButtonVariant.primary => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _primaryStyle(),
          child: child,
        ),
      AppButtonVariant.secondary => OutlinedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _secondaryStyle(),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: isDisabled ? null : onPressed,
          style: _textStyle(),
          child: child,
        ),
      AppButtonVariant.danger => ElevatedButton(
          onPressed: isDisabled ? null : onPressed,
          style: _dangerStyle(),
          child: child,
        ),
    };

    if (isFullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }

  Widget _buildChild() {
    if (isLoading) {
      return SizedBox(
        height: _iconSize,
        width: _iconSize,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(
            variant == AppButtonVariant.secondary ||
                    variant == AppButtonVariant.text
                ? AppColors.primary
                : AppColors.textOnPrimary,
          ),
        ),
      );
    }

    final textWidget = Text(text, style: _textStyleForSize);

    if (leadingIcon == null && trailingIcon == null) {
      return textWidget;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon, size: _iconSize),
          const SizedBox(width: 8),
        ],
        Flexible(child: textWidget),
        if (trailingIcon != null) ...[
          const SizedBox(width: 8),
          Icon(trailingIcon, size: _iconSize),
        ],
      ],
    );
  }

  // ─── Size Helpers ──────────────────────────────────────────────────

  double get _height => switch (size) {
        AppButtonSize.small => 40,
        AppButtonSize.medium => 48,
        AppButtonSize.large => 56,
      };

  double get _iconSize => switch (size) {
        AppButtonSize.small => 16,
        AppButtonSize.medium => 18,
        AppButtonSize.large => 20,
      };

  EdgeInsets get _padding => switch (size) {
        AppButtonSize.small =>
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        AppButtonSize.medium =>
          const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        AppButtonSize.large =>
          const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
      };

  TextStyle get _textStyleForSize => switch (size) {
        AppButtonSize.small => AppTextStyles.buttonSmall,
        AppButtonSize.medium => AppTextStyles.buttonSmall,
        AppButtonSize.large => AppTextStyles.button,
      };

  // ─── Style Builders ────────────────────────────────────────────────

  ButtonStyle _primaryStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
        padding: _padding,
        minimumSize: Size(0, _height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: _textStyleForSize,
      );

  ButtonStyle _secondaryStyle() => OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
        padding: _padding,
        minimumSize: Size(0, _height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        side: BorderSide(
          color: onPressed != null
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.5),
          width: 2,
        ),
        textStyle: _textStyleForSize,
      );

  ButtonStyle _textStyle() => TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.primary.withValues(alpha: 0.5),
        padding: _padding,
        minimumSize: Size(0, _height),
        textStyle: _textStyleForSize,
      );

  ButtonStyle _dangerStyle() => ElevatedButton.styleFrom(
        backgroundColor: AppColors.error,
        foregroundColor: AppColors.textOnPrimary,
        disabledBackgroundColor: AppColors.error.withValues(alpha: 0.5),
        disabledForegroundColor: AppColors.textOnPrimary.withValues(alpha: 0.7),
        padding: _padding,
        minimumSize: Size(0, _height),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 2,
        textStyle: _textStyleForSize,
      );
}

/// A circular icon-only button following the Baladi design system.
///
/// Example usage:
/// ```dart
/// AppIconButton(
///   icon: Icons.add,
///   onPressed: () => _addItem(),
/// )
/// ```
class AppIconButton extends StatelessWidget {
  /// The icon to display.
  final IconData icon;

  /// Called when the button is tapped. If `null`, the button is disabled.
  final VoidCallback? onPressed;

  /// The background color. Defaults to [AppColors.primary].
  final Color? backgroundColor;

  /// The icon color. Defaults to [AppColors.textOnPrimary].
  final Color? iconColor;

  /// The button diameter. Defaults to 48.
  final double size;

  /// The icon size inside the button. Defaults to 24.
  final double iconSize;

  /// Optional tooltip for accessibility.
  final String? tooltip;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 48,
    this.iconSize = 24,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? AppColors.primary;
    final fg = iconColor ?? AppColors.textOnPrimary;

    final button = Material(
      color: onPressed != null ? bg : bg.withValues(alpha: 0.5),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: onPressed != null ? fg : fg.withValues(alpha: 0.7),
          ),
        ),
      ),
    );

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: button);
    }

    return button;
  }
}