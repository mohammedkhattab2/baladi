import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/features/shop/widgets/shop_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopShell extends StatelessWidget {
  /// محتوى الشاشة (Body)
  final Widget child;

  /// اسم الروت الحالي (عشان تميّز العنصر المختار في الدروار)
  final String currentRoute;

  /// عنوان الـ AppBar
  final String title;

  /// أزرار إضافية في الـ AppBar (اختياري)
  final List<Widget>? actions;

  /// FloatingActionButton لو محتاج (اختياري)
  final Widget? floatingActionButton;

  const ShopShell({
    super.key,
    required this.child,
    required this.currentRoute,
    required this.title,
    this.actions,
    this.floatingActionButton,
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
      drawer: ShopDrawer(currentRoute: currentRoute),
      floatingActionButton: floatingActionButton,
      body: child,
    );
  }
}