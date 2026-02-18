// lib/presentation/features/admin/screens/admin_dashboard_screen.dart

import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/weekly_period.dart';
import 'package:baladi/domain/repositories/admin_repository.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_state.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadDashboard(),
      child: const _AdminDashboardView(),
    );
  }
}

class _AdminDashboardView extends StatelessWidget {
  const _AdminDashboardView();

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: RouteNames.adminDashboard,
      title: 'لوحة التحكم',
      child: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminWeekClosed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إغلاق الفترة بنجاح: ${state.closedPeriod.displayLabel}',
                  style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            // Reload dashboard after closing week
            context.read<AdminCubit>().loadDashboard();
          }
          if (state is AdminError) {
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
          if (state is AdminLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is AdminActionLoading) {
            return const Center(
              child: LoadingWidget(message: 'جاري المعالجة...'),
            );
          }
          if (state is AdminError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<AdminCubit>().loadDashboard(),
            );
          }
          if (state is AdminDashboardLoaded) {
            return _DashboardContent(dashboard: state.dashboard);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final AdminDashboard dashboard;

  const _DashboardContent({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<AdminCubit>().loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            _WelcomeCard(currentPeriod: dashboard.currentPeriod),
            SizedBox(height: 24.h),

                        // Stats Section
                        _SectionHeader(
                          title: 'الإحصائيات',
                          trailing: Text(
                            'إجمالي المستخدمين: ${Formatters.formatNumber(dashboard.totalUsers)}',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        _StatsGrid(dashboard: dashboard),
                        SizedBox(height: 24.h),

            // Quick Actions Section
            _SectionHeader(title: 'إجراءات سريعة'),
            SizedBox(height: 12.h),
            _QuickActionsSection(dashboard: dashboard),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final WeeklyPeriod? currentPeriod;

  const _WelcomeCard({this.currentPeriod});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha:  0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'مرحباً بك في لوحة التحكم 👋',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textOnPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'إدارة نظام بلدي للتوصيل',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              color: AppColors.textOnPrimary.withValues(alpha:  0.8),
            ),
          ),
          if (currentPeriod != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:  0.2),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: AppColors.textOnPrimary,
                    size: 14.r,
                  ),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(
                      'الفترة الحالية: ${Formatters.formatDate(currentPeriod!.startDate)} - ${Formatters.formatDate(currentPeriod!.endDate)}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.sp,
                        color: AppColors.textOnPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const _SectionHeader({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final AdminDashboard dashboard;

  const _StatsGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.people,
                color: AppColors.primary,
                value: Formatters.formatNumber(dashboard.totalCustomers),
                label: 'العملاء',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.storefront,
                color: AppColors.secondary,
                value: Formatters.formatNumber(dashboard.totalShops),
                label: 'المحلات',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.delivery_dining,
                color: AppColors.info,
                value: Formatters.formatNumber(dashboard.totalRiders),
                label: 'السائقين',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.receipt_long,
                color: AppColors.success,
                value: Formatters.formatNumber(dashboard.totalOrders),
                label: 'إجمالي الطلبات',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.account_balance_wallet,
                color: AppColors.warning,
                value: Formatters.formatCurrency(dashboard.totalRevenue),
                label: 'إيرادات المنصة',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.stars,
                color: Colors.purple,
                value: Formatters.formatNumber(
                  dashboard.totalPointsIssued - dashboard.totalPointsRedeemed,
                ),
                label: 'النقاط النشطة',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActionsSection extends StatelessWidget {
  final AdminDashboard dashboard;

  const _QuickActionsSection({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    final activeOrders =
        dashboard.totalOrders -
        dashboard.completedOrders -
        dashboard.cancelledOrders;

    return Column(
      children: [
        _QuickActionTile(
          icon: Icons.receipt_long,
          label: 'عرض الطلبات',
          subtitle: '$activeOrders طلب نشط',
          onTap: () => context.goNamed(RouteNames.adminOrders),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.people_outline,
          label: 'إدارة المستخدمين',
          subtitle: '${dashboard.totalCustomers} عميل مسجل',
          onTap: () => context.goNamed(RouteNames.adminUsers),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.storefront_outlined,
          label: 'إدارة المحلات',
          subtitle: '${dashboard.totalShops} محل مسجل',
          onTap: () => context.goNamed(RouteNames.adminShops),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.delivery_dining_outlined,
          label: 'إدارة السائقين',
          subtitle: '${dashboard.totalRiders} سائق مسجل',
          onTap: () => context.goNamed(RouteNames.adminRiders),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.calendar_month,
          label: 'إغلاق الفترة الحالية',
          subtitle: 'إنشاء تسويات جديدة',
          onTap: () => _showCloseWeekDialog(context),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.date_range_outlined,
          label: 'فترات التسوية',
          subtitle: 'عرض جميع الفترات',
          onTap: () => context.goNamed(RouteNames.adminPeriods),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.account_balance_wallet_outlined,
          label: 'التسويات',
          subtitle: 'تسويات المحلات والسائقين',
          onTap: () => context.goNamed(RouteNames.adminSettlements),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.stars,
          label: 'تعديل نقاط عميل',
          subtitle: 'إضافة أو خصم نقاط',
          onTap: () => context.goNamed(RouteNames.adminPoints),
        ),
      ],
    );
  }

  void _showCloseWeekDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'إغلاق الفترة الحالية',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'سيتم إنشاء تسويات لجميع المحلات والسائقين.\n\nهل أنت متأكد؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().closeCurrentWeek();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'إغلاق الفترة',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha:  0.1),
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
                    SizedBox(height: 2.h),
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
        ),
      ),
    );
  }
}