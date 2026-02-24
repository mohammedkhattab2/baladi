import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
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

class RiderEarningsScreen extends StatelessWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RiderCubit>()..loadDashboard(),
      child: const _RiderEarningsView(),
    );
  }
}

class _RiderEarningsView extends StatelessWidget {
  const _RiderEarningsView();

  @override
  Widget build(BuildContext context) {
    return RiderShell(
      currentRoute: RouteNames.riderEarnings,
      title: 'أرباحي',
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
            final d = state.dashboard;
            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppCard(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ملخص الفترة الحالية',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'إجمالي أرباحك ونشاطك في الفترة الأسبوعية الحالية.',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.account_balance_wallet_outlined,
                          color: AppColors.success,
                          value:
                              Formatters.formatCurrency(d.totalEarnings),
                          label: 'إجمالي الأرباح',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.delivery_dining,
                          color: AppColors.info,
                          value: d.totalDeliveries.toString(),
                          label: 'عدد التوصيلات',
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
                          value:
                              Formatters.formatCurrency(d.totalCashHandled),
                          label: 'إجمالي الكاش اللي استلمته',
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: AdminStatCard(
                          icon: Icons.assignment_outlined,
                          color: AppColors.primary,
                          value: d.availableOrdersCount.toString(),
                          label: 'طلبات متاحة الآن',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}