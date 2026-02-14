import 'dart:ffi';

import 'package:baladi/core/config/app_config.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/widgets/role_selection_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const GradientBackground(),
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                const _BrandSection(),
                const Spacer(flex: 3),
                _RoleSelection(
                  onCustomerTap: () =>
                      context.goNamed(RouteNames.customerLogin),
                  onStaffTap: () => context.goNamed(RouteNames.staffLogin),
                ),
                const Spacer(),
                const _Footer(),
                SizedBox(height: 16.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          AppConfig.appNameEn,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textHint,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 2.h,),
        Text(
          "الإصدار  ${AppConfig.appVersion}",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 11.sp,
            color: AppColors.textHint
          ),
        )
      ],
    );
  }
}

class _RoleSelection extends StatelessWidget {
  final VoidCallback onCustomerTap;
  final VoidCallback onStaffTap;
  const _RoleSelection({required this.onCustomerTap, required this.onStaffTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "اختر طريقة الدخول",
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          RoleSelectionCard(
            icon: Icons.shopping_bag_outlined,
            title: 'عميل',
            subtitle: 'تصفح المتاجر واطلب للتوصيل',
            accentColor: AppColors.primary,
            onTap: onCustomerTap,
          ),
          SizedBox(height: 12.h),
          RoleSelectionCard(
            icon: Icons.badge_outlined,
            title: 'فريق العمل',
            subtitle: 'متجر • سائق توصيل • مدير',
            accentColor: AppColors.secondary,
            onTap: onStaffTap,
          ),
        ],
      ),
    );
  }
}

class _BrandSection extends StatelessWidget {
  const _BrandSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88.r,
          height: 88.r,
          decoration: BoxDecoration(
            color: AppColors.surface,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Icon(Icons.eco_rounded, size: 42.r, color: AppColors.primary),
        ),
        SizedBox(height: 20.h),
        Text(
          AppConfig.appName,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 36.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textOnPrimary,
            letterSpacing: 2,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          "توصيل سريع لباب بيتك",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15.sp,
            fontWeight: FontWeight.w400,
            color: AppColors.textOnPrimary.withValues(alpha: 0.85),
          ),
        ),
        SizedBox(height: 14.h),
        Container(
          width: 40.w,
          height: 3.h,
          decoration: BoxDecoration(
            color: AppColors.secondary,
            borderRadius: BorderRadius.circular(2.r),
          ),
        ),
      ],
    );
  }
}

class GradientBackground extends StatelessWidget {
  const GradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.45.sh,
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
          stops: [0.0, 0.6, 1.0],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30.r,
            right: -20.r,
            child: _DecorativeCircle(size: 120.r),
          ),
          Positioned(
            bottom: 30.r,
            left: -25.r,
            child: _DecorativeCircle(size: 80.r),
          ),
          Positioned(
            bottom: 60.r,
            right: 40.r,
            child: _DecorativeCircle(size: 40.r),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCircle extends StatelessWidget {
  final double size;
  const _DecorativeCircle({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.07),
      ),
    );
  }
}
