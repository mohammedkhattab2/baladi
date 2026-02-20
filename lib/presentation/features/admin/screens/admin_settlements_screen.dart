import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/weekly_period.dart';
import 'package:baladi/domain/entities/shop_settlement.dart';
import 'package:baladi/domain/entities/rider_settlement.dart';
import 'package:baladi/domain/usecases/admin/get_settlement_report.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:baladi/presentation/features/admin/widgets/admin_stat_card.dart';
import 'package:baladi/presentation/cubits/settlement/settlement_cubit.dart';
import 'package:baladi/presentation/cubits/settlement/settlement_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class AdminSettlementsScreen extends StatelessWidget {
  const AdminSettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<SettlementCubit>()..loadPeriods(),
      child: const _AdminSettlementsView(),
    );
  }
}

class _AdminSettlementsView extends StatelessWidget {
  const _AdminSettlementsView();

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: RouteNames.adminSettlements,
      title: 'تسويات النظام',
      child: BlocConsumer<SettlementCubit, SettlementState>(
        listener: (context, state) {
          if (state is SettlementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: const TextStyle(fontFamily: AppTextStyles.fontFamily),
                ),
                backgroundColor: AppColors.error,
              ),
            );
          }
          if (state is SettlementWeekClosed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم إغلاق الفترة بنجاح: ${state.closedPeriod.displayLabel}',
                  style: const TextStyle(fontFamily: AppTextStyles.fontFamily),
                ),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is SettlementLoading) {
            return const Center(child: LoadingWidget());
          }

          if (state is SettlementError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<SettlementCubit>().loadPeriods(),
            );
          }

          if (state is SettlementReportLoaded) {
            return _SettlementReportView(report: state.report);
          }

          if (state is SettlementPeriodsLoaded) {
            return _PeriodsSelectionView(
              periods: state.periods,
              currentPeriod: state.currentPeriod,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PeriodsSelectionView extends StatefulWidget {
  final List<WeeklyPeriod> periods;
  final WeeklyPeriod? currentPeriod;

  const _PeriodsSelectionView({
    required this.periods,
    this.currentPeriod,
  });

  @override
  State<_PeriodsSelectionView> createState() => _PeriodsSelectionViewState();
}

class _PeriodsSelectionViewState extends State<_PeriodsSelectionView> {
  WeeklyPeriod? _selected;

  @override
  void initState() {
    super.initState();
    if (widget.periods.isNotEmpty) {
      _selected = widget.currentPeriod ?? widget.periods.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.periods.isEmpty) {
      return const AppEmptyState(
        icon: Icons.calendar_today,
        title: 'لا توجد فترات تسوية',
        description: 'سيتم إنشاء فترات أسبوعية تلقائياً مع أول طلبات مكتملة',
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<SettlementCubit>().loadPeriods(),
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          Text(
            'اختر فترة لعرض تقرير التسويات',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12.h),
          DropdownButtonFormField<WeeklyPeriod>(
            value: _selected,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: 'الفترة الأسبوعية',
              labelStyle: const TextStyle(
                fontFamily: AppTextStyles.fontFamily,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 10.h,
              ),
            ),
            items: widget.periods
                .map(
                  (p) => DropdownMenuItem<WeeklyPeriod>(
                    value: p,
                    child: Text(
                      '${p.displayLabel} • '
                      '${Formatters.formatDate(p.startDate)} - '
                      '${Formatters.formatDate(p.endDate)}',
                      style: const TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            onChanged: (value) {
              setState(() {
                _selected = value;
              });
            },
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _selected == null
                  ? null
                  : () {
                      context
                          .read<SettlementCubit>()
                          .loadReport(_selected!.id);
                    },
              icon: const Icon(Icons.analytics_outlined),
              label: const Text(
                'عرض تقرير التسويات',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          TextButton.icon(
            onPressed: () {
              context.goNamed(RouteNames.adminPeriods);
            },
            icon: const Icon(Icons.date_range_outlined),
            label: Text(
              'عرض كل الفترات',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettlementReportView extends StatelessWidget {
  final SettlementReport report;

  const _SettlementReportView({required this.report});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.read<SettlementCubit>().loadReport(
            report.period.id,
          ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ReportHeader(period: report.period),
            SizedBox(height: 20.h),
            _SummaryStats(report: report),
            SizedBox(height: 24.h),
            _ShopsSettlementsSection(
              settlements: report.shopSettlements,
            ),
            SizedBox(height: 24.h),
            _RidersSettlementsSection(
              settlements: report.riderSettlements,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHeader extends StatelessWidget {
  final WeeklyPeriod period;

  const _ReportHeader({required this.period});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.date_range,
              color: AppColors.primary,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تقرير تسويات الفترة',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  period.displayLabel,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '${Formatters.formatDate(period.startDate)} - '
                  '${Formatters.formatDate(period.endDate)}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<SettlementCubit>().loadPeriods();
            },
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'تغيير الفترة',
          ),
        ],
      ),
    );
  }
}

class _SummaryStats extends StatelessWidget {
  final SettlementReport report;

  const _SummaryStats({required this.report});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.shopping_bag,
                color: AppColors.primary,
                value: Formatters.formatCurrency(report.totalGrossSales),
                label: 'إجمالي المبيعات',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.percent,
                color: AppColors.secondary,
                value: Formatters.formatCurrency(report.totalCommissions),
                label: 'إجمالي العمولات',
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: AdminStatCard(
                icon: Icons.local_shipping_outlined,
                color: AppColors.info,
                value: Formatters.formatCurrency(report.totalDeliveryFees),
                label: 'رسوم التوصيل',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.stars_outlined,
                color: Colors.purple,
                value: Formatters.formatCurrency(
                  report.totalPointsDiscounts,
                ),
                label: 'خصومات النقاط (تحمّل المنصة)',
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
                color: AppColors.warning,
                value: Formatters.formatCurrency(
                  report.totalFreeDeliveryCosts,
                ),
                label: 'تكلفة التوصيل المجاني',
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: AdminStatCard(
                icon: Icons.campaign_outlined,
                color: AppColors.success,
                value: Formatters.formatCurrency(report.totalAdsRevenue),
                label: 'إيرادات الإعلانات',
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
                color: AppColors.primaryDark,
                value: Formatters.formatCurrency(report.adminNetRevenue),
                label: 'صافي إيراد المنصة',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ShopsSettlementsSection extends StatelessWidget {
  final List<ShopSettlement> settlements;

  const _ShopsSettlementsSection({required this.settlements});

  @override
  Widget build(BuildContext context) {
    if (settlements.isEmpty) {
      return const AppEmptyState(
        icon: Icons.storefront_outlined,
        title: 'لا توجد تسويات للمحلات',
        description: 'لم يتم إنشاء تسويات للمحلات في هذه الفترة بعد',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تسويات المحلات (${settlements.length})',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: settlements.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final s = settlements[index];
            return AppCard(
              onTap: () {
                context
                    .read<SettlementCubit>()
                    .loadShopSettlementDetail(s.id);
              },
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.storefront,
                      color: AppColors.primary,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'متجر #${s.shopId}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'طلبات مكتملة: ${s.completedOrders} • ملغاة: ${s.cancelledOrders}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'إجمالي المبيعات: ${Formatters.formatCurrency(s.grossSales)}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        Formatters.formatCurrency(s.netAmount),
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.success,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        s.status.labelAr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.sp,
                          color:
                              s.isPaid ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RidersSettlementsSection extends StatelessWidget {
  final List<RiderSettlement> settlements;

  const _RidersSettlementsSection({required this.settlements});

  @override
  Widget build(BuildContext context) {
    if (settlements.isEmpty) {
      return const AppEmptyState(
        icon: Icons.delivery_dining_outlined,
        title: 'لا توجد تسويات للسائقين',
        description: 'لم يتم إنشاء تسويات للسائقين في هذه الفترة بعد',
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تسويات السائقين (${settlements.length})',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: settlements.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            final s = settlements[index];
            return AppCard(
              onTap: () {
                context
                    .read<SettlementCubit>()
                    .loadRiderSettlementDetail(s.id);
              },
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      color: AppColors.info,
                      size: 20.r,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سائق #${s.riderId}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'تسليمات: ${s.totalDeliveries} • نقدية: ${Formatters.formatCurrency(s.totalCashHandled)}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'إجمالي أرباح التوصيل: ${Formatters.formatCurrency(s.totalEarnings)}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        s.status.labelAr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.sp,
                          color:
                              s.isPaid ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}