import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/features/rider/widgets/rider_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RiderShell extends StatelessWidget {
  final Widget child;
  final String currentRoute;
  final String title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  const RiderShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
    this.actions,
    this.floatingActionButton,
  });

  bool get _isDashboard => currentRoute == RouteNames.riderDashboard;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // لما يضغط زر الرجوع في الموبايل:
        // لو مش على صفحة الداشبورد → ارجعه للداشبورد
        if (!_isDashboard) {
          context.goNamed(RouteNames.riderDashboard);
          return false;
        }
        // لو هو أصلاً على الداشبورد → خليه يتصرف طبيعي (يخرج من الأبلكيشن)
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: _isDashboard
              ? null // يظهر زر القائمة (الدروار) بشكل افتراضي
              : BackButton(
                  onPressed: () {
                    // زر الرجوع في الـ AppBar:
                    // لو فيه صفحة في الـ Navigator stack → pop
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    } else {
                      // لو مفيش → ارجع للداشبورد
                      context.goNamed(RouteNames.riderDashboard);
                    }
                  },
                ),
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
          actions: actions,
        ),
        drawer: RiderDrawer(currentRoute: currentRoute),
        floatingActionButton: floatingActionButton,
        body: child,
      ),
    );
  }
}