// lib/presentation/features/admin/shell/admin_shell.dart

import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final bool showDrawer;

  const AdminShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
    this.actions,
    this.floatingActionButton,
    this.showDrawer = true,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // System back should behave like the app bar back button:
        // - On admin dashboard: allow normal back (exit app or previous flow).
        // - On other admin screens: go back to previous page, or to dashboard
        //   if there is nothing to pop.
        if (currentRoute == RouteNames.adminDashboard) {
          return true;
        }

        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          context.goNamed(RouteNames.adminDashboard);
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 0,
          // Show a back button on all admin screens except the dashboard.
          leading: currentRoute == RouteNames.adminDashboard
              ? null
              : IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    // Pop back to the previous route in the navigator stack.
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      // Fallback: if nothing to pop, go explicitly to the dashboard.
                      context.goNamed(RouteNames.adminDashboard);
                    }
                  },
                ),
          actions: actions,
        ),
        drawer: showDrawer ? AdminDrawer(currentRoute: currentRoute) : null,
        floatingActionButton: floatingActionButton,
        body: child,
      ),
    );
  }
}