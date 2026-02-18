import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/weekly_period.dart';
import 'package:baladi/domain/enums/period_status.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_state.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminPeriodsScreen extends StatelessWidget {
  const AdminPeriodsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadPeriods(),
      child: const _AdminPeriodsView(),
    );
  }
}

class _AdminPeriodsView extends StatefulWidget {
  const _AdminPeriodsView();

  @override
  State<_AdminPeriodsView> createState() => _AdminPeriodsViewState();
}

class _AdminPeriodsViewState extends State<_AdminPeriodsView> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminCubit>().state;
      if (state is AdminPeriodsLoaded && state.hasMore) {
        context.read<AdminCubit>().loadMorePeriods();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: RouteNames.adminPeriods,
      title: 'فترات التسوية',
      child: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
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
          if (state is AdminLoading || state is AdminActionLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is AdminError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<AdminCubit>().loadPeriods(),
            );
          }
          if (state is AdminPeriodsLoaded) {
            return _buildPeriodsList(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildPeriodsList(AdminPeriodsLoaded state) {
    if (state.periods.isEmpty) {
      return const AppEmptyState(
        icon: Icons.date_range_outlined,
        title: 'لا توجد فترات',
        description: 'سيتم إنشاء فترات أسبوعية تلقائياً مع أول طلبات',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadPeriods(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: state.periods.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.periods.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final period = state.periods[index];
          return _PeriodCard(period: period);
        },
      ),
    );
  }
}

// ───────────── Card + Details ─────────────

class _PeriodCard extends StatelessWidget {
  final WeeklyPeriod period;

  const _PeriodCard({required this.period});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      borderColor: _statusColor(period.status),
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          // Icon
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.date_range,
              color: AppColors.primary,
              size: 22.r,
            ),
          ),
          SizedBox(width: 12.w),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Label + status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        period.displayLabel,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _StatusBadge(status: period.status),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  '${Formatters.formatDate(period.startDate)} - ${Formatters.formatDate(period.endDate)}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (period.closedAt != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'أُغلقت: ${Formatters.formatDateTime(period.closedAt!)}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          Icon(
            Icons.chevron_left,
            color: AppColors.textHint,
            size: 20.r,
          ),
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => _PeriodDetailsSheet(period: period),
    );
  }

  Color _statusColor(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.active:
        return AppColors.info;
      case PeriodStatus.closed:
        return AppColors.warning;
      case PeriodStatus.settled:
        return AppColors.success;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final PeriodStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        status.labelAr,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _statusColor(PeriodStatus status) {
    switch (status) {
      case PeriodStatus.active:
        return AppColors.info;
      case PeriodStatus.closed:
        return AppColors.warning;
      case PeriodStatus.settled:
        return AppColors.success;
    }
  }
}

class _PeriodDetailsSheet extends StatelessWidget {
  final WeeklyPeriod period;

  const _PeriodDetailsSheet({required this.period});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.all(24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Icon(
                    Icons.date_range,
                    color: AppColors.primary,
                    size: 28.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period.displayLabel,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        _StatusBadge(status: period.status),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _DetailRow(
                label: 'السنة',
                value: period.year.toString(),
              ),
              _DetailRow(
                label: 'رقم الأسبوع',
                value: period.weekNumber.toString(),
              ),
              _DetailRow(
                label: 'من',
                value: Formatters.formatDate(period.startDate),
              ),
              _DetailRow(
                label: 'إلى',
                value: Formatters.formatDate(period.endDate),
              ),
              if (period.closedAt != null) ...[
                _DetailRow(
                  label: 'تاريخ الإغلاق',
                  value: Formatters.formatDateTime(period.closedAt!),
                ),
              ],
              if (period.closedBy != null && period.closedBy!.isNotEmpty) ...[
                _DetailRow(
                  label: 'أُغلقت بواسطة',
                  value: period.closedBy!,
                ),
              ],
              _DetailRow(
                label: 'تاريخ الإنشاء',
                value: Formatters.formatDateTime(period.createdAt),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}