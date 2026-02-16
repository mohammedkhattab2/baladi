// lib/presentation/features/admin/shell/admin_shell.dart

import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
    return Scaffold(
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
        actions: actions,
      ),
      drawer: showDrawer ? AdminDrawer(currentRoute: currentRoute) : null,
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }
}