// Presentation - Common base scaffold layout for the Baladi design system.
//
// Provides a consistent page structure with app bar, body, bottom navigation,
// FAB support, and RTL-aware layout for all screens in the application.

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../widgets/loading_widget.dart';

/// A base scaffold providing consistent page structure across the app.
///
/// Wraps [Scaffold] with Baladi-styled app bar, optional bottom navigation,
/// floating action button, and loading/error overlay support.
///
/// Example usage:
/// ```dart
/// BaseScaffold(
///   title: 'الرئيسية',
///   body: HomeContent(),
///   bottomNavigationBar: CustomerBottomNav(currentIndex: 0),
/// )
/// ```
class BaseScaffold extends StatelessWidget {
  /// The page title shown in the app bar. If `null`, no app bar is displayed.
  final String? title;

  /// Optional custom title widget (overrides [title] text).
  final Widget? titleWidget;

  /// The main body content.
  final Widget body;

  /// Whether to show a back button in the app bar.
  final bool showBackButton;

  /// Custom back button action. If `null`, uses [Navigator.pop].
  final VoidCallback? onBack;

  /// Leading widget in the app bar (overrides back button).
  final Widget? leading;

  /// Action widgets displayed on the trailing side of the app bar.
  final List<Widget>? actions;

  /// Bottom navigation bar widget.
  final Widget? bottomNavigationBar;

  /// Floating action button.
  final Widget? floatingActionButton;

  /// FAB location. Defaults to [FloatingActionButtonLocation.endFloat].
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Background color. Defaults to [AppColors.background].
  final Color? backgroundColor;

  /// App bar background color. Defaults to [AppColors.surface].
  final Color? appBarColor;

  /// Whether the app bar should have elevation.
  final bool appBarElevation;

  /// Whether to add safe area padding to the body.
  final bool useSafeArea;

  /// Whether the body should resize when keyboard appears.
  final bool resizeToAvoidBottomInset;

  /// Whether to show a loading overlay on top of the body.
  final bool isLoading;

  /// Optional loading message.
  final String? loadingMessage;

  /// Optional bottom sheet widget.
  final Widget? bottomSheet;

  /// Optional drawer widget.
  final Widget? drawer;

  /// Optional end drawer widget.
  final Widget? endDrawer;

  /// Whether the body extends behind the app bar.
  final bool extendBodyBehindAppBar;

  /// Optional padding for the body content.
  final EdgeInsetsGeometry? bodyPadding;

  const BaseScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.body,
    this.showBackButton = true,
    this.onBack,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.appBarColor,
    this.appBarElevation = false,
    this.useSafeArea = true,
    this.resizeToAvoidBottomInset = true,
    this.isLoading = false,
    this.loadingMessage,
    this.bottomSheet,
    this.drawer,
    this.endDrawer,
    this.extendBodyBehindAppBar = false,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = body;

    if (bodyPadding != null) {
      content = Padding(padding: bodyPadding!, child: content);
    }

    if (useSafeArea && title == null && titleWidget == null) {
      content = SafeArea(child: content);
    }

    return Scaffold(
      backgroundColor: backgroundColor ?? AppColors.background,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          content,
          if (isLoading)
            LoadingOverlay(message: loadingMessage),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      bottomSheet: bottomSheet,
      drawer: drawer,
      endDrawer: endDrawer,
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context) {
    if (title == null && titleWidget == null) return null;

    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: appBarColor ?? AppColors.surface,
      elevation: appBarElevation ? 1 : 0,
      scrolledUnderElevation: appBarElevation ? 2 : 1,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: _buildLeading(context, canPop),
      title: titleWidget ??
          Text(
            title!,
            style: const TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
      actions: actions != null
          ? [
              ...actions!,
              const SizedBox(width: 8),
            ]
          : null,
    );
  }

  Widget? _buildLeading(BuildContext context, bool canPop) {
    if (leading != null) return leading;

    if (showBackButton && canPop) {
      return IconButton(
        icon: const Icon(Icons.arrow_forward_ios, size: 20),
        onPressed: onBack ?? () => Navigator.of(context).pop(),
        tooltip: 'رجوع',
      );
    }

    return null;
  }
}

/// A scaffold variant with a scrollable body and pull-to-refresh support.
///
/// Example usage:
/// ```dart
/// ScrollableScaffold(
///   title: 'طلباتي',
///   onRefresh: () => cubit.loadOrders(),
///   slivers: [
///     SliverList(delegate: SliverChildBuilderDelegate(...)),
///   ],
/// )
/// ```
class ScrollableScaffold extends StatelessWidget {
  /// The page title.
  final String? title;

  /// Optional custom title widget.
  final Widget? titleWidget;

  /// The sliver children for the [CustomScrollView].
  final List<Widget> slivers;

  /// Pull-to-refresh callback.
  final Future<void> Function()? onRefresh;

  /// Whether to show a back button.
  final bool showBackButton;

  /// Custom back action.
  final VoidCallback? onBack;

  /// Leading widget in the app bar.
  final Widget? leading;

  /// Actions in the app bar.
  final List<Widget>? actions;

  /// Bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Floating action button.
  final Widget? floatingActionButton;

  /// FAB location.
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  /// Background color.
  final Color? backgroundColor;

  /// Whether to show a loading overlay.
  final bool isLoading;

  /// Optional loading message.
  final String? loadingMessage;

  const ScrollableScaffold({
    super.key,
    this.title,
    this.titleWidget,
    required this.slivers,
    this.onRefresh,
    this.showBackButton = true,
    this.onBack,
    this.leading,
    this.actions,
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.backgroundColor,
    this.isLoading = false,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    Widget scrollView = CustomScrollView(
      slivers: slivers,
    );

    if (onRefresh != null) {
      scrollView = RefreshIndicator(
        onRefresh: onRefresh!,
        color: AppColors.primary,
        child: scrollView,
      );
    }

    return BaseScaffold(
      title: title,
      titleWidget: titleWidget,
      showBackButton: showBackButton,
      onBack: onBack,
      leading: leading,
      actions: actions,
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      backgroundColor: backgroundColor,
      isLoading: isLoading,
      loadingMessage: loadingMessage,
      body: scrollView,
    );
  }
}

/// A scaffold variant with a [TabBar] integrated into the app bar.
///
/// Example usage:
/// ```dart
/// TabbedScaffold(
///   title: 'طلبات المتجر',
///   tabs: [Tab(text: 'جديدة'), Tab(text: 'جارية'), Tab(text: 'مكتملة')],
///   tabViews: [NewOrders(), ActiveOrders(), CompletedOrders()],
/// )
/// ```
class TabbedScaffold extends StatelessWidget {
  /// The page title.
  final String title;

  /// The tab definitions.
  final List<Widget> tabs;

  /// The tab view content.
  final List<Widget> tabViews;

  /// Whether to show a back button.
  final bool showBackButton;

  /// Custom back action.
  final VoidCallback? onBack;

  /// Actions in the app bar.
  final List<Widget>? actions;

  /// Bottom navigation bar.
  final Widget? bottomNavigationBar;

  /// Background color.
  final Color? backgroundColor;

  /// Whether tabs are scrollable.
  final bool isScrollable;

  /// Whether to show a loading overlay.
  final bool isLoading;

  const TabbedScaffold({
    super.key,
    required this.title,
    required this.tabs,
    required this.tabViews,
    this.showBackButton = true,
    this.onBack,
    this.actions,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.isScrollable = false,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: tabs.length,
      child: BaseScaffold(
        titleWidget: Text(
          title,
          style: const TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        showBackButton: showBackButton,
        onBack: onBack,
        actions: actions,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
        isLoading: isLoading,
        body: Column(
          children: [
            Material(
              color: AppColors.surface,
              child: TabBar(
                tabs: tabs,
                isScrollable: isScrollable,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
                labelStyle: AppTextStyles.labelLarge,
                unselectedLabelStyle: AppTextStyles.labelMedium,
              ),
            ),
            Expanded(
              child: TabBarView(children: tabViews),
            ),
          ],
        ),
      ),
    );
  }
}