// Presentation - Common loading indicator widgets for the Baladi design system.
//
// Provides a centered spinner, full-screen overlay loader, and shimmer
// placeholder boxes for skeleton loading states.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

/// A centered circular progress indicator with optional message.
///
/// Example usage:
/// ```dart
/// if (state is Loading) const LoadingWidget(message: 'جاري التحميل...')
/// ```
class LoadingWidget extends StatelessWidget {
  /// Optional message displayed below the spinner.
  final String? message;

  /// The spinner color. Defaults to [AppColors.primary].
  final Color color;

  /// The spinner size. Defaults to 40.
  final double size;

  const LoadingWidget({
    super.key,
    this.message,
    this.color = AppColors.primary,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 16),
              Text(
                message!,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A full-screen semi-transparent overlay with a centered spinner.
///
/// Typically used as a [Stack] overlay during async operations
/// to block user interaction.
///
/// Example usage:
/// ```dart
/// Stack(
///   children: [
///     _buildContent(),
///     if (isLoading) const LoadingOverlay(),
///   ],
/// )
/// ```
class LoadingOverlay extends StatelessWidget {
  /// The overlay background opacity. Defaults to 0.4.
  final double opacity;

  /// Optional message below the spinner.
  final String? message;

  const LoadingOverlay({
    super.key,
    this.opacity = 0.4,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: AbsorbPointer(
        child: Container(
          color: Colors.black.withValues(alpha: opacity),
          child: LoadingWidget(
            message: message,
            color: AppColors.textOnPrimary,
          ),
        ),
      ),
    );
  }
}

/// A shimmer placeholder box for skeleton loading states.
///
/// Animates a light shimmer effect across a rounded rectangle,
/// indicating that content is loading.
///
/// Example usage:
/// ```dart
/// ShimmerBox(width: double.infinity, height: 120)
/// ```
class ShimmerBox extends StatefulWidget {
  /// The width of the placeholder. Use `double.infinity` for full width.
  final double width;

  /// The height of the placeholder.
  final double height;

  /// The border radius. Defaults to 12.
  final double borderRadius;

  const ShimmerBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_animation.value - 1, 0),
              end: Alignment(_animation.value + 1, 0),
              colors: const [
                AppColors.shimmerBase,
                AppColors.shimmerHighlight,
                AppColors.shimmerBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// A list of shimmer placeholder rows for skeleton loading.
///
/// Example usage:
/// ```dart
/// if (state is Loading) const ShimmerList(itemCount: 5)
/// ```
class ShimmerList extends StatelessWidget {
  /// Number of shimmer rows.
  final int itemCount;

  /// Height of each shimmer row. Defaults to 80.
  final double itemHeight;

  /// Spacing between rows. Defaults to 12.
  final double spacing;

  /// Padding around the list.
  final EdgeInsetsGeometry padding;

  const ShimmerList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.spacing = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        children: List.generate(
          itemCount,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < itemCount - 1 ? spacing : 0),
            child: ShimmerBox(
              width: double.infinity,
              height: itemHeight,
            ),
          ),
        ),
      ),
    );
  }
}

/// An inline loading indicator for buttons or small areas.
///
/// Displays a small spinner that fits inline with text.
///
/// Example usage:
/// ```dart
/// Row(
///   children: [
///     const InlineLoader(),
///     const SizedBox(width: 8),
///     Text('جاري الحفظ...'),
///   ],
/// )
/// ```
class InlineLoader extends StatelessWidget {
  /// The spinner size. Defaults to 16.
  final double size;

  /// The spinner color. Defaults to [AppColors.primary].
  final Color color;

  /// The stroke width. Defaults to 2.
  final double strokeWidth;

  const InlineLoader({
    super.key,
    this.size = 16,
    this.color = AppColors.primary,
    this.strokeWidth = 2,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }
}