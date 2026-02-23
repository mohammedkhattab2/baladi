import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ShopDrawer extends StatelessWidget {
  final String currentRoute;

  const ShopDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Divider(height: 1),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_outlined,
                    label: 'لوحة التحكم',
                    routeName: RouteNames.shopDashboard,
                    currentRoute: currentRoute,
                  ),
                  _DrawerItem(
                    icon: Icons.receipt_long_outlined,
                    label: 'الطلبات',
                    routeName: RouteNames.shopOrders,
                    currentRoute: currentRoute,
                  ),
                  _DrawerItem(
                    icon: Icons.inventory_2_outlined,
                    label: 'المنتجات',
                    routeName: RouteNames.shopProducts,
                    currentRoute: currentRoute,
                  ),
                  _DrawerItem(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'التسويات',
                    routeName: RouteNames.shopSettlements,
                    currentRoute: currentRoute,
                  ),
                  _DrawerItem(
                    icon: Icons.settings_outlined,
                    label: 'الإعدادات',
                    routeName: RouteNames.shopSettings,
                    currentRoute: currentRoute,
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                  color: AppColors.error,
                ),
              ),
              onTap: () {
                // TODO: تنفيذ تسجيل الخروج فعلياً
                Navigator.of(context).pop(); // يقفل الدروار بس حالياً
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      color: AppColors.primary,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.storefront, color: AppColors.textOnPrimary, size: 32.r),
          SizedBox(height: 8.h),
          Text(
            'لوحة تحكم المتجر',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'إدارة الطلبات والمنتجات والتسويات',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.sp,
              color: AppColors.textOnPrimary.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String routeName;
  final String currentRoute;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.routeName,
    required this.currentRoute,
  });

  @override
  Widget build(BuildContext context) {
    final bool selected = currentRoute == routeName;

    return ListTile(
      leading: Icon(
        icon,
        color: selected ? AppColors.primary : AppColors.textSecondary,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 14.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          color: selected ? AppColors.primary : AppColors.textPrimary,
        ),
      ),
      selected: selected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      onTap: () {
        Navigator.of(context).pop();
        if (!selected) {
          context.goNamed(routeName);
        }
      },
    );
  }
}