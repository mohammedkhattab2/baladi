// Presentation - Common empty state widget for the Baladi design system.
//
// Provides a centered illustration placeholder with a message and optional
// action button for when lists or pages have no content to display.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'app_button.dart';

/// A centered empty-state display with icon, title, description, and optional action.
///
/// Used when a list, page, or section has no content to show — e.g. an empty
/// order history, no search results, or an empty cart.
///
/// Example usage:
/// ```dart
/// if (orders.isEmpty)
///   const AppEmptyState(
///     icon: Icons.receipt_long_outlined,
///     title: 'لا توجد طلبات',
///     description: 'طلباتك ستظهر هنا بعد أول عملية شراء',
///   )
/// ```
class AppEmptyState extends StatelessWidget {
  /// The large icon displayed at the top.
  final IconData icon;

  /// The primary message.
  final String title;

  /// Optional secondary description.
  final String? description;

  /// Optional action button label.
  final String? actionLabel;

  /// Called when the action button is tapped.
  final VoidCallback? onAction;

  /// The icon color. Defaults to [AppColors.textHint].
  final Color iconColor;

  /// The icon size. Defaults to 72.
  final double iconSize;

  const AppEmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
    this.iconColor = AppColors.textHint,
    this.iconSize = 72,
  });

  /// Empty state for an empty order list.
  const AppEmptyState.orders({
    super.key,
    this.title = 'لا توجد طلبات',
    this.description = 'طلباتك ستظهر هنا بعد أول عملية شراء',
    this.actionLabel = 'تصفح المتاجر',
    this.onAction,
  })  : icon = Icons.receipt_long_outlined,
        iconColor = AppColors.textHint,
        iconSize = 72;

  /// Empty state for an empty cart.
  const AppEmptyState.cart({
    super.key,
    this.title = 'السلة فارغة',
    this.description = 'أضف منتجات من المتاجر للبدء',
    this.actionLabel = 'تصفح المتاجر',
    this.onAction,
  })  : icon = Icons.shopping_cart_outlined,
        iconColor = AppColors.textHint,
        iconSize = 72;

  /// Empty state for no search results.
  const AppEmptyState.noResults({
    super.key,
    this.title = 'لا توجد نتائج',
    this.description = 'جرب البحث بكلمات مختلفة',
    this.actionLabel,
    this.onAction,
  })  : icon = Icons.search_off_outlined,
        iconColor = AppColors.textHint,
        iconSize = 72;

  /// Empty state for no notifications.
  const AppEmptyState.notifications({
    super.key,
    this.title = 'لا توجد إشعارات',
    this.description = 'ستظهر الإشعارات الجديدة هنا',
    this.actionLabel,
    this.onAction,
  })  : icon = Icons.notifications_none_outlined,
        iconColor = AppColors.textHint,
        iconSize = 72;

  /// Empty state for no products in a shop.
  const AppEmptyState.products({
    super.key,
    this.title = 'لا توجد منتجات',
    this.description = 'لم يتم إضافة منتجات بعد',
    this.actionLabel = 'إضافة منتج',
    this.onAction,
  })  : icon = Icons.inventory_2_outlined,
        iconColor = AppColors.textHint,
        iconSize = 72;

  /// Empty state for no available delivery orders (rider).
  const AppEmptyState.deliveries({
    super.key,
    this.title = 'لا توجد طلبات متاحة',
    this.description = 'ستظهر الطلبات الجديدة هنا عند توفرها',
    this.actionLabel,
    this.onAction,
  })  : icon = Icons.delivery_dining_outlined,
        iconColor = AppColors.textHint,
        iconSize = 72;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ─── Icon ──────────────────────────────────────────
            Container(
              width: iconSize + 32,
              height: iconSize + 32,
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: iconSize, color: iconColor),
            ),
            const SizedBox(height: 24),

            // ─── Title ─────────────────────────────────────────
            Text(
              title,
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

            // ─── Action Button ─────────────────────────────────
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton.primary(
                text: actionLabel!,
                onPressed: onAction,
                isFullWidth: false,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}