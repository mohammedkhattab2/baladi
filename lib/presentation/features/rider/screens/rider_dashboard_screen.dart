// lib/presentation/features/rider/screens/rider_dashboard_screen.dart

import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/rider.dart';
import 'package:baladi/domain/repositories/rider_repository.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/rider/rider_cubit.dart';
import 'package:baladi/presentation/cubits/rider/rider_state.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_stat_card.dart';
import 'package:baladi/presentation/features/rider/shell/rider_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RiderDashboardScreen extends StatelessWidget {
  const RiderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RiderCubit>()..loadDashboard(),
      child: const _RiderDashboardView(),
    );
  }
}

class _RiderDashboardView extends StatelessWidget {
  const _RiderDashboardView();

  @override
  Widget build(BuildContext context) {
    return RiderShell(
      currentRoute: RouteNames.riderDashboard,
      title: 'لوحة تحكم السائق',
      child: BlocConsumer<RiderCubit, RiderState>(
        listener: (context, state) {
          if (state is RiderError) {
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
          if (state is RiderLoading || state is RiderTogglingAvailability) {
            return const Center(child: LoadingWidget());
          }
          if (state is RiderError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<RiderCubit>().loadDashboard(),
            );
          }
          if (state is RiderDashboardLoaded) {
            return _DashboardContent(
              rider: state.rider,
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
  final Rider rider;
  final RiderDashboard dashboard;

  const _DashboardContent({
    required this.rider,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<RiderCubit>().loadDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeaderCard(rider: rider, dashboard: dashboard),
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
  final Rider rider;
  final RiderDashboard dashboard;

  const _HeaderCard({
    required this.rider,
    required this.dashboard,
  });

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RiderCubit>();

    return AppCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // rider info
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha:  0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.delivery_dining,
                  color: AppColors.info,
                  size: 26.r,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rider.fullName,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      rider.phone,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _AvailabilityChip(isAvailable: rider.isAvailable),
            ],
          ),
          SizedBox(height: 16.h),

          // availability switch
          Row(
            children: [
              Text(
                'متاح للتوصيل:',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.sp,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 8.w),
              Switch(
                value: rider.isAvailable,
                activeThumbColor: AppColors.primary,
                onChanged: (value) {
                  cubit.toggleAvailability(isAvailable: value);
                },
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // summary
          Text(
            'إجمالي أرباح الفترة الحالية: '
            '${Formatters.formatCurrency(dashboard.totalEarnings)}',
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

class _AvailabilityChip extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.success : AppColors.textSecondary;
    final label = isAvailable ? 'متاح' : 'غير متاح';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.schedule,
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
  final RiderDashboard dashboard;

  const _StatsGrid({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.delivery_dining,
                color: AppColors.info,
                value: dashboard.totalDeliveries.toString(),
                label: 'توصيلات مكتملة',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.account_balance_wallet_outlined,
                color: AppColors.success,
                value: Formatters.formatCurrency(dashboard.totalEarnings),
                label: 'إجمالي الأرباح',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.attach_money,
                color: AppColors.warning,
                value: Formatters.formatCurrency(
                  dashboard.totalCashHandled,
                ),
                label: 'إجمالي الكاش اللي استلمته',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.assignment_outlined,
                color: AppColors.primary,
                value: dashboard.availableOrdersCount.toString(),
                label: 'طلبات متاحة الآن',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  final RiderDashboard dashboard;

  const _QuickActions({required this.dashboard});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _QuickActionTile(
          icon: Icons.assignment_outlined,
          label: 'مشاهدة الطلبات المتاحة',
          subtitle: '${dashboard.availableOrdersCount} طلب جاهز للاستلام',
          onTap: () => context.goNamed(RouteNames.riderAvailableOrders),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.account_balance_wallet_outlined,
          label: 'أرباحي',
          subtitle: 'ملخص أرباح الفترة الحالية',
          onTap: () => context.goNamed(RouteNames.riderEarnings),
        ),
        SizedBox(height: 8.h),
        _QuickActionTile(
          icon: Icons.person_outline,
          label: 'الملف الشخصي',
          subtitle: 'بيانات حسابك',
          onTap: () => context.goNamed(RouteNames.riderProfile),
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
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
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