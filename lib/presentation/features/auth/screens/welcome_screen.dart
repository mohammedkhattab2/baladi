import 'package:baladi/core/config/app_config.dart';
import 'package:baladi/core/constants/mock_credentials.dart';
import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/domain/enums/user_role.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:baladi/presentation/features/auth/widgets/role_selection_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onAuthStateChanged,
        builder: (context, state) {
          final isLoading = state is AuthLoading;
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
                            context.pushNamed(RouteNames.customerLogin),
                        onStaffTap: () =>
                            context.pushNamed(RouteNames.staffLogin),
                      ),
                      if (kDebugMode) ...[
                        SizedBox(height: 16.h),
                        _DevQuickLoginPanel(isLoading: isLoading),
                      ],
                      const Spacer(),
                      const _Footer(),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  static void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      final routeName = switch (state.role) {
        UserRole.customer => RouteNames.customerHome,
        UserRole.shop => RouteNames.shopDashboard,
        UserRole.rider => RouteNames.riderDashboard,
        UserRole.admin => RouteNames.adminDashboard,
      };
      context.goNamed(routeName);
    } else if (state is AuthError) {
      context.showErrorSnackBar(state.message);
    }
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


/// Dev-only quick login panel — shown only in debug mode.
/// Allows tapping a role to instantly log in with mock credentials.
class _DevQuickLoginPanel extends StatelessWidget {
  final bool isLoading;
  const _DevQuickLoginPanel({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bug_report_outlined, size: 16.r, color: AppColors.warning),
              SizedBox(width: 6.w),
              Text(
                'تسجيل دخول سريع (تجريبي)',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: MockCredentials.all.map((account) {
              return _MockLoginChip(
                account: account,
                isLoading: isLoading,
                onTap: () => _quickLogin(context, account),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  void _quickLogin(BuildContext context, MockAccount account) {
    if (isLoading) return;
    context.read<AuthCubit>().devMockLogin(account: account);
  }
}

class _MockLoginChip extends StatelessWidget {
  final MockAccount account;
  final bool isLoading;
  final VoidCallback onTap;

  const _MockLoginChip({
    required this.account,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(account.emoji, style: TextStyle(fontSize: 18.sp)),
              SizedBox(width: 6.w),
              Text(
                account.label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
