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
        // Deep dark base to blend with admin gradients
        backgroundColor: const Color(0xFF050B11),
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          automaticallyImplyLeading: false,
          // Custom flexible space for luxurious gradient bar
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D1B2A),
                  Color(0xFF1B263B),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.65),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(18.r),
              ),
              border: Border(
                bottom: BorderSide(
                  color: Colors.white.withValues(alpha: 0.16),
                  width: 0.6,
                ),
              ),
            ),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.1,
              color: Colors.white.withValues(alpha: 0.96),
            ),
          ),
          // Show a back button on all admin screens except the dashboard.
          leading: currentRoute == RouteNames.adminDashboard
              ? (showDrawer
                  ? Builder(
                      builder: (context) => IconButton(
                        icon: Icon(
                          Icons.menu_rounded,
                          size: 22.r,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                        tooltip: 'القائمة',
                      ),
                    )
                  : null)
              : IconButton(
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    size: 22.r,
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
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
          actions: actions ??
              [
                // subtle status dot / brand accent on the right
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.w),
                  child: Container(
                    width: 20.r,
                    height: 20.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.24),
                        width: 1.1,
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withValues(alpha: 0.95),
                          AppColors.secondary.withValues(alpha: 0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.50),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
          iconTheme: IconThemeData(
            color: Colors.white.withValues(alpha: 0.92),
            size: 22.r,
          ),
        ),
        drawer: showDrawer ? AdminDrawer(currentRoute: currentRoute) : null,
        floatingActionButton: floatingActionButton,
        body: child,
      ),
    );
  }
}