import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminDrawer extends StatelessWidget {
  final String currentRoute;
  const AdminDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // Dark base to match admin identity (no light surface)
      backgroundColor: const Color(0xFF050B11),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF050B11),
                Color(0xFF0B1722),
                Color(0xFF101B27),
              ],
              stops: [0.0, 0.45, 1.0],
            ),
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0D1B2A),
                      Color(0xFF1B263B),
                    ],
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.white.withValues(alpha: 0.16),
                      width: 0.5,
                    ),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.6),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 56.r,
                      height: 56.r,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.25),
                          width: 1.1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.50),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.admin_panel_settings,
                        color: Colors.white,
                        size: 30.r,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      "لوحة التحكم ",
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  children: [
                    _DrawerItem(
                      icon: Icons.dashboard_outlined,
                      activeIcon: Icons.dashboard,
                      label: 'الرئيسية',
                      routeName: RouteNames.adminDashboard,
                      isSelected: currentRoute == RouteNames.adminDashboard,
                      onTap: () =>
                          _navigateTo(context, RouteNames.adminDashboard),
                    ),
                    _DrawerItem(
                      icon: Icons.people_outline,
                      activeIcon: Icons.people,
                      label: 'المستخدمين',
                      routeName: RouteNames.adminUsers,
                      isSelected: currentRoute == RouteNames.adminUsers,
                      onTap: () => _navigateTo(context, RouteNames.adminUsers),
                    ),
                    _DrawerItem(
                      icon: Icons.storefront_outlined,
                      activeIcon: Icons.storefront,
                      label: 'المحلات',
                      routeName: RouteNames.adminShops,
                      isSelected: currentRoute == RouteNames.adminShops,
                      onTap: () => _navigateTo(context, RouteNames.adminShops),
                    ),
                    _DrawerItem(
                      icon: Icons.category_outlined,
                      activeIcon: Icons.category,
                      label: 'التصنيفات',
                      routeName: RouteNames.adminCategories,
                      isSelected: currentRoute == RouteNames.adminCategories,
                      onTap: () =>
                          _navigateTo(context, RouteNames.adminCategories),
                    ),
                    _DrawerItem(
                      icon: Icons.delivery_dining_outlined,
                      activeIcon: Icons.delivery_dining,
                      label: 'السائقين',
                      routeName: RouteNames.adminRiders,
                      isSelected: currentRoute == RouteNames.adminRiders,
                      onTap: () => _navigateTo(context, RouteNames.adminRiders),
                    ),
                    _DrawerItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      label: 'الطلبات',
                      routeName: RouteNames.adminOrders,
                      isSelected: currentRoute == RouteNames.adminOrders,
                      onTap: () => _navigateTo(context, RouteNames.adminOrders),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: Divider(
                        color: Colors.white.withValues(alpha: 0.18),
                      ),
                    ),
                    _DrawerItem(
                      icon: Icons.date_range_outlined,
                      activeIcon: Icons.date_range,
                      label: 'فترات التسوية',
                      routeName: RouteNames.adminPeriods,
                      isSelected: currentRoute == RouteNames.adminPeriods,
                      onTap: () =>
                          _navigateTo(context, RouteNames.adminPeriods),
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      activeIcon: Icons.account_balance_wallet,
                      label: 'التسويات',
                      routeName: RouteNames.adminSettlements,
                      isSelected: currentRoute == RouteNames.adminSettlements,
                      onTap: () =>
                          _navigateTo(context, RouteNames.adminSettlements),
                    ),
                    _DrawerItem(
                      icon: Icons.stars_outlined,
                      activeIcon: Icons.stars,
                      label: 'النقاط',
                      routeName: RouteNames.adminPoints,
                      isSelected: currentRoute == RouteNames.adminPoints,
                      onTap: () => _navigateTo(context, RouteNames.adminPoints),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: ListTile(
                  leading: Icon(
                    Icons.logout,
                    color: AppColors.error,
                    size: 24.r,
                  ),
                  title: Text(
                    "تسجيل الخروج",
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.error,
                    ),
                  ),
                  tileColor: Colors.white.withValues(alpha: 0.02),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 1.0,
                    ),
                  ),
                  onTap: () => _handleLogout(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateTo(BuildContext context, String routeName) {
    Navigator.pop(context);
    if (currentRoute != routeName) {
      context.goNamed(routeName);
    }
  }

  void _handleLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF050B11),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1.2,
          ),
        ),
        titlePadding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 4.h),
        contentPadding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
        actionsPadding: EdgeInsets.fromLTRB(12.w, 4.h, 12.w, 10.h),
        title: Row(
          children: [
            Container(
              width: 34.r,
              height: 34.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.error.withValues(alpha: 0.95),
                    AppColors.error.withValues(alpha: 0.75),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.55),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 18.r,
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                "تسجيل الخروج",
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white.withValues(alpha: 0.96),
                ),
              ),
            ),
          ],
        ),
        content: Text(
          "هل تريد تسجيل الخروج؟",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            color: Colors.white.withValues(alpha: 0.85),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              foregroundColor: Colors.white.withValues(alpha: 0.90),
              backgroundColor: Colors.white.withValues(alpha: 0.04),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.r),
                side: BorderSide(
                  color: Colors.white.withValues(alpha: 0.20),
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              "إلغاء",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.goNamed(RouteNames.welcome);
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 8.h),
              backgroundColor: AppColors.error.withValues(alpha: 0.18),
              foregroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999.r),
                side: BorderSide(
                  color: AppColors.error.withValues(alpha: 0.85),
                  width: 1.0,
                ),
              ),
            ),
            child: Text(
              "خروج",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String routeName;
  final bool isSelected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.routeName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = isSelected;

    final Color iconColor = selected
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.72);
    final Color textColor = selected
        ? AppColors.primary
        : Colors.white.withValues(alpha: 0.92);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          selected ? activeIcon : icon,
          color: iconColor,
          size: 24.r,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: textColor,
          ),
        ),
        selected: selected,
        tileColor: Colors.white.withValues(alpha: 0.02),
        selectedTileColor: Colors.white.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14.r),
          side: BorderSide(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.85)
                : Colors.white.withValues(alpha: 0.14),
            width: 1.0,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
