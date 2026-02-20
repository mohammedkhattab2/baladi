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
      backgroundColor: AppColors.surface,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24.r),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56.r,
                    height: 56.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.admin_panel_settings,
                      color: AppColors.textOnPrimary,
                      size: 32.r,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    "لوحة التحكم ",
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13.sp,
                      color: AppColors.textOnPrimary.withValues(alpha: 0.8),
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
                    child: Divider(color: AppColors.border),
                  ),
                  _DrawerItem(
                    icon: Icons.date_range_outlined,
                    activeIcon: Icons.date_range,
                    label: 'فترات التسوية',
                    routeName: RouteNames.adminPeriods,
                    isSelected: currentRoute == RouteNames.adminPeriods,
                    onTap: () => _navigateTo(context, RouteNames.adminPeriods),
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
                leading: Icon(Icons.logout, color: AppColors.error, size: 24.r),
                title: Text(
                  "تسجيل الخروج",
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
                shape: BeveledRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                onTap: () => _handleLogout(context),
              ),
            ),
          ],
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
        title: Text(
          "تسجيل الخروج",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          "هل تريد تسجيل الخروج؟",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "إالغاء",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthCubit>().logout();
              context.goNamed(RouteNames.welcome);
            },
            child: Text( 
              "خروج",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      child: ListTile(
        leading: Icon(
          isSelected ? activeIcon : icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
          size: 24.r,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        onTap: onTap,
      ),
    );
  }
}
