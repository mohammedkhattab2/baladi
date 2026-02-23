import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/shop.dart';
import 'package:baladi/domain/repositories/shop_repository.dart';
import 'package:baladi/presentation/common/widgets/app_button.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_state.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_stat_card.dart';
import 'package:baladi/presentation/features/shop/shell/shop_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ShopDashboardScreen extends StatelessWidget {
  const ShopDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopManagementCubit>()..loadDashboard(),
      child: const _ShopDashboardView(),
    );
  }
}

class _ShopDashboardView extends StatelessWidget {
  const _ShopDashboardView();

  @override
  Widget build(BuildContext context) {
    return ShopShell(
      currentRoute: RouteNames.shopDashboard,
      title: 'لوحة تحكم المتجر',
      child: BlocConsumer<ShopManagementCubit, ShopManagementState>(
        listener: (context, state) {
          if (state is ShopManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ShopManagementLoading ||
              state is ShopStatusToggling) {
            return const Center(child: LoadingWidget());
          }
          if (state is ShopManagementError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ShopManagementCubit>().loadDashboard(),
            );
          }
          if (state is ShopDashboardLoaded) {
            return _DashboardContent(
              shop: state.shop,
              dashboard: state.dashboard,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final ShopDashboard dashboard;
  final Shop shop;

  const _DashboardContent({
    required this.dashboard,
    required this.shop,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<ShopManagementCubit>().loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(shop: shop, dashboard: dashboard),
            SizedBox(height: 24.h),
            _SectionTitle('إحصائيات الفترة الحالية'),
            SizedBox(height: 12.h),
            _StatsGrid(dashboard: dashboard),
            SizedBox(height: 24.h),
            _SectionTitle('إجراءات سريعة'),
            SizedBox(height: 12.h),
            _QuickActions(dashboard: dashboard),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final Shop shop;
  final ShopDashboard dashboard;

  const _HeaderCard({
    required this.shop,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShopManagementCubit>();

    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // اسم المتجر + حالة الفتح
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.storefront,
                  color: AppColors.secondary,
                  size: 26.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shop.displayName,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      shop.address ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _OpenStatusChip(isOpen: shop.isOpen),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Text(
                'حالة المتجر:',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Switch(
                value: shop.isOpen,
                activeColor: AppColors.primary,
                onChanged: (value) {
                  cubit.toggleShopStatus(isOpen: value);
                },
              ),
              SizedBox(width: 8.w),
              Text(
                shop.isOpen ? 'يستقبل طلبات' : 'مغلق حالياً',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'إجمالي صافي الأرباح في الفترة الحالية: '
            '${Formatters.formatCurrency(dashboard.netEarnings)}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpenStatusChip extends StatelessWidget {
  final bool isOpen;

  const _OpenStatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.success : AppColors.warning;
    final label = isOpen ? 'مفتوح' : 'مغلق';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.schedule,
            size: 14.r,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontFamily: AppTextStyles.fontFamily,
        fontSize: 16.sp,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final ShopDashboard dashboard;

  const _StatsGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.receipt_long,
                color: AppColors.primary,
                value: dashboard.totalOrders.toString(),
                label: 'إجمالي الطلبات',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.pending_actions,
                color: AppColors.statusPending,
                value: dashboard.pendingOrders.toString(),
                label: 'طلبات قيد الانتظار',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.check_circle_outline,
                color: AppColors.statusCompleted,
                value: dashboard.completedOrders.toString(),
                label: 'طلبات مكتملة',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.cancel_outlined,
                color: AppColors.statusCancelled,
                value: dashboard.cancelledOrders.toString(),
                label: 'طلبات ملغاة',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.success,
                value: Formatters.formatCurrency(dashboard.totalRevenue),
                label: 'إجمالي المبيعات',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.percent,
                color: AppColors.warning,
                value: Formatters.formatCurrency(dashboard.totalCommission),
                label: 'إجمالي العمولة',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final ShopDashboard dashboard;

  const _QuickActions({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionTile(
          icon: Icons.receipt_long_outlined,
          label: 'إدارة الطلبات',
          subtitle: '${dashboard.pendingOrders} طلب في انتظار الإجراء',
          onTap: () => context.goNamed(RouteNames.shopOrders),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.inventory_2_outlined,
          label: 'إدارة المنتجات',
          subtitle: 'إضافة وتعديل وحذف المنتجات',
          onTap: () => context.goNamed(RouteNames.shopProducts),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.account_balance_wallet_outlined,
          label: 'عرض التسويات',
          subtitle: 'تسويات الأسابيع السابقة وصافي الأرباح',
          onTap: () => context.goNamed(RouteNames.shopSettlements),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.settings_outlined,
          label: 'إعدادات المتجر',
          subtitle: 'بيانات المتجر وطرق التواصل',
          onTap: () => context.goNamed(RouteNames.shopSettings),
        ),
      ],
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(16.r),
      margin: EdgeInsets.zero,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22.r),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_left, color: AppColors.textHint, size: 24.r),
        ],
      ),
    );
  }
}