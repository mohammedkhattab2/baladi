// Presentation - Common error display widget for the Baladi design system.
//
// Provides error message displays with retry actions, supporting both
// full-page error states and inline error banners.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_button.dart';

/// A centered error display with an icon, message, and optional retry button.
///
/// Used as the primary error state for pages and data-loading areas.
///
/// Example usage:
/// ```dart
/// if (state is OrderError)
///   AppErrorWidget(
///     message: state.message,
///     onRetry: () => cubit.loadOrders(),
///   )
/// ```
class AppErrorWidget extends StatelessWidget {
  /// The error message to display.
  final String message;

  /// Optional detailed description shown below the message.
  final String? description;

  /// Called when the retry button is tapped. If `null`, no button is shown.
  final VoidCallback? onRetry;

  /// The retry button label. Defaults to "إعادة المحاولة".
  final String retryLabel;

  /// The error icon. Defaults to [Icons.error_outline].
  final IconData icon;

  /// The icon color. Defaults to [AppColors.error].
  final Color iconColor;

  /// The icon size. Defaults to 64.
  final double iconSize;

  const AppErrorWidget({
    super.key,
    required this.message,
    this.description,
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
    this.icon = Icons.error_outline,
    this.iconColor = AppColors.error,
    this.iconSize = 64,
  });

  /// Creates a network-specific error widget.
  const AppErrorWidget.network({
    super.key,
    this.message = 'لا يوجد اتصال بالإنترنت',
    this.description = 'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
  })  : icon = Icons.wifi_off_outlined,
        iconColor = AppColors.textSecondary,
        iconSize = 64;

  /// Creates a server-specific error widget.
  const AppErrorWidget.server({
    super.key,
    this.message = 'حدث خطأ في الخادم',
    this.description = 'نعتذر عن هذا الخطأ، يرجى المحاولة لاحقاً',
    this.onRetry,
    this.retryLabel = 'إعادة المحاولة',
  })  : icon = Icons.cloud_off_outlined,
        iconColor = AppColors.textSecondary,
        iconSize = 64;

  /// Creates a not-found error widget.
  const AppErrorWidget.notFound({
    super.key,
    this.message = 'غير موجود',
    this.description = 'لم يتم العثور على ما تبحث عنه',
    this.onRetry,
    this.retryLabel = 'رجوع',
  })  : icon = Icons.search_off_outlined,
        iconColor = AppColors.textSecondary,
        iconSize = 64;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Icon ──────────────────────────────────────────
            Icon(icon, size: iconSize, color: iconColor),
            const SizedBox(height: 24),

            // ─── Message ───────────────────────────────────────
            Text(
              message,
              style: AppTextStyles.h3.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            // ─── Description ───────────────────────────────────
            if (description != null) ...[
              const SizedBox(height: 8),
              Text(
                description!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],

            // ─── Retry Button ──────────────────────────────────
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                text: retryLabel,
                onPressed: onRetry,
                isFullWidth: false,
                size: AppButtonSize.medium,
                leadingIcon: Icons.refresh,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// An inline error banner displayed at the top or bottom of a page.
///
/// Shows a colored bar with an error message and optional dismiss/retry actions.
///
/// Example usage:
/// ```dart
/// AppErrorBanner(
///   message: 'فشل حفظ البيانات',
///   onRetry: () => _save(),
///   onDismiss: () => setState(() => _error = null),
/// )
/// ```
class AppErrorBanner extends StatelessWidget {
  /// The error message.
  final String message;

  /// Called when the retry action is tapped.
  final VoidCallback? onRetry;

  /// Called when the dismiss button is tapped.
  final VoidCallback? onDismiss;

  /// The banner type affecting the background color.
  final AppBannerType type;

  const AppErrorBanner({
    super.key,
    required this.message,
    this.onRetry,
    this.onDismiss,
    this.type = AppBannerType.error,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _foregroundColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(
                color: _foregroundColor,
              ),
            ),
          ),
          if (onRetry != null)
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: _foregroundColor,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('إعادة'),
            ),
          if (onDismiss != null)
            IconButton(
              onPressed: onDismiss,
              icon: Icon(Icons.close, color: _foregroundColor, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
        ],
      ),
    );
  }

  Color get _backgroundColor => switch (type) {
        AppBannerType.error => AppColors.error.withValues(alpha: 0.1),
        AppBannerType.warning => AppColors.warning.withValues(alpha: 0.1),
        AppBannerType.info => AppColors.info.withValues(alpha: 0.1),
        AppBannerType.success => AppColors.success.withValues(alpha: 0.1),
      };

  Color get _foregroundColor => switch (type) {
        AppBannerType.error => AppColors.error,
        AppBannerType.warning => AppColors.warning,
        AppBannerType.info => AppColors.info,
        AppBannerType.success => AppColors.success,
      };

  IconData get _icon => switch (type) {
        AppBannerType.error => Icons.error_outline,
        AppBannerType.warning => Icons.warning_amber_outlined,
        AppBannerType.info => Icons.info_outline,
        AppBannerType.success => Icons.check_circle_outline,
      };
}

/// The visual type of an [AppErrorBanner].
enum AppBannerType {
  /// Red error banner.
  error,

  /// Orange warning banner.
  warning,

  /// Blue informational banner.
  info,

  /// Green success banner.
  success,
}