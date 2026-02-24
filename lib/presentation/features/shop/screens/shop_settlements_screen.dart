import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/shop_settlement.dart';
import 'package:baladi/domain/enums/settlement_status.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_state.dart';
import 'package:baladi/presentation/features/shop/shell/shop_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopSettlementsScreen extends StatelessWidget {
  const ShopSettlementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopManagementCubit>()..loadSettlements(),
      child: const _ShopSettlementsView(),
    );
  }
}

class _ShopSettlementsView extends StatefulWidget {
  const _ShopSettlementsView();

  @override
  State<_ShopSettlementsView> createState() => _ShopSettlementsViewState();
}

class _ShopSettlementsViewState extends State<_ShopSettlementsView> {
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
      final state = context.read<ShopManagementCubit>().state;
      if (state is ShopSettlementsLoaded && state.hasMore) {
        context.read<ShopManagementCubit>().loadMoreSettlements();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopShell(
      currentRoute: RouteNames.shopSettlements,
      title: 'تسويات المتجر',
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
          if (state is ShopManagementLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is ShopManagementError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ShopManagementCubit>().loadSettlements(),
            );
          }
          if (state is ShopSettlementsLoaded) {
            return _buildList(state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildList(ShopSettlementsLoaded state) {
    if (state.settlements.isEmpty) {
      return const AppEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'لا توجد تسويات بعد',
        description: 'ستظهر تسوياتك الأسبوعية هنا بعد إغلاق الفترات.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ShopManagementCubit>().loadSettlements(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: state.settlements.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.settlements.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final settlement = state.settlements[index];
          return _SettlementCard(settlement: settlement);
        },
      ),
    );
  }
}

class _SettlementCard extends StatelessWidget {
  final ShopSettlement settlement;

  const _SettlementCard({required this.settlement});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => _showDetails(context),
      borderColor:
          settlement.status == SettlementStatus.settled
              ? AppColors.success
              : AppColors.warning,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // العنوان + الحالة
          Row(
            children: [
              Expanded(
                child: Text(
                  'تسوية أسبوعية',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StatusBadge(status: settlement.status),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'عدد الطلبات: ${settlement.completedOrders}/${settlement.totalOrders}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),

          // أرقام مالية
          Row(
            children: [
              Icon(Icons.account_balance_wallet_outlined,
                  size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(
                'صافي المتجر: ${Formatters.formatCurrency(settlement.netAmount)}',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'إجمالي المبيعات: ${Formatters.formatCurrency(settlement.grossSales)}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            'إجمالي العمولة: ${Formatters.formatCurrency(settlement.totalCommission)}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
          ),
          if (settlement.settledAt != null) ...[
            SizedBox(height: 4.h),
            Text(
              'تاريخ الدفع: ${Formatters.formatDate(settlement.settledAt!)}',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
      builder: (ctx) => _SettlementDetailsSheet(settlement: settlement),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final SettlementStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color =
        status == SettlementStatus.settled
            ? AppColors.success
            : AppColors.warning;
    final label =
        status == SettlementStatus.settled ? 'مدفوعة' : 'قيد الانتظار';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _SettlementDetailsSheet extends StatelessWidget {
  final ShopSettlement settlement;

  const _SettlementDetailsSheet({required this.settlement});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
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
              Text(
                'تفاصيل التسوية',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 16.h),
              _DetailRow(
                label: 'إجمالي الطلبات',
                value: settlement.totalOrders.toString(),
              ),
              _DetailRow(
                label: 'طلبات مكتملة',
                value: settlement.completedOrders.toString(),
              ),
              _DetailRow(
                label: 'طلبات ملغاة',
                value: settlement.cancelledOrders.toString(),
              ),
              SizedBox(height: 12.h),
              _DetailRow(
                label: 'إجمالي المبيعات',
                value: Formatters.formatCurrency(settlement.grossSales),
              ),
              _DetailRow(
                label: 'إجمالي العمولة',
                value: Formatters.formatCurrency(settlement.totalCommission),
              ),
              _DetailRow(
                label: 'خصومات النقاط',
                value: Formatters.formatCurrency(settlement.pointsDiscounts),
              ),
              _DetailRow(
                label: 'تكلفة التوصيل المجاني',
                value: Formatters.formatCurrency(settlement.freeDeliveryCost),
              ),
              _DetailRow(
                label: 'تكلفة الإعلانات',
                value: Formatters.formatCurrency(settlement.adsCost),
              ),
              _DetailRow(
                label: 'صافي المتجر',
                value: Formatters.formatCurrency(settlement.netAmount),
              ),
              SizedBox(height: 12.h),
              _DetailRow(
                label: 'حالة التسوية',
                value: settlement.status == SettlementStatus.settled
                    ? 'مدفوعة'
                    : 'قيد الانتظار',
              ),
              if (settlement.settledAt != null)
                _DetailRow(
                  label: 'تاريخ الدفع',
                  value: Formatters.formatDateTime(settlement.settledAt!),
                ),
              _DetailRow(
                label: 'تاريخ الإنشاء',
                value: Formatters.formatDateTime(settlement.createdAt),
              ),
              if (settlement.notes != null &&
                  settlement.notes!.trim().isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'ملاحظات الإدارة',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  settlement.notes!,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
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
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
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