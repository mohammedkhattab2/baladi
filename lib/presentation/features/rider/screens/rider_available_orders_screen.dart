import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/rider/rider_cubit.dart';
import 'package:baladi/presentation/cubits/rider/rider_state.dart';
import 'package:baladi/presentation/features/rider/shell/rider_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiderAvailableOrdersScreen extends StatelessWidget {
  const RiderAvailableOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RiderCubit>()..loadAvailableOrders(),
      child: const _RiderAvailableOrdersView(),
    );
  }
}

class _RiderAvailableOrdersView extends StatefulWidget {
  const _RiderAvailableOrdersView();

  @override
  State<_RiderAvailableOrdersView> createState() =>
      _RiderAvailableOrdersViewState();
}

class _RiderAvailableOrdersViewState
    extends State<_RiderAvailableOrdersView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<RiderCubit>().state;
      if (state is RiderAvailableOrdersLoaded && state.hasMore) {
        context.read<RiderCubit>().loadMoreAvailableOrders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RiderShell(
      currentRoute: RouteNames.riderAvailableOrders,
      title: 'طلبات متاحة',
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
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
                if (state is RiderLoading) {
                  return const Center(child: LoadingWidget());
                }
                if (state is RiderError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () =>
                        context.read<RiderCubit>().loadAvailableOrders(),
                  );
                }
                if (state is RiderAvailableOrdersLoaded) {
                  return _buildList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.surface,
      child: AppSearchField(
        controller: _searchController,
        hint: 'بحث برقم الطلب...',
        onChanged: (v) {
          // TODO: فلترة محلية لو حبيت
        },
      ),
    );
  }

  Widget _buildList(RiderAvailableOrdersLoaded state) {
    if (state.availableOrders.isEmpty) {
      return const AppEmptyState(
        icon: Icons.assignment_outlined,
        title: 'لا توجد طلبات متاحة',
        description: 'عند وجود طلبات جاهزة للاستلام ستظهر هنا.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<RiderCubit>().loadAvailableOrders(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount:
            state.availableOrders.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.availableOrders.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final order = state.availableOrders[index];
          return _AvailableOrderCard(order: order);
        },
      ),
    );
  }
}

class _AvailableOrderCard extends StatelessWidget {
  final Order order;

  const _AvailableOrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<RiderCubit>();

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => _showDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رقم الطلب
          Text(
            Formatters.formatOrderNumber(order.orderNumber),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),

          // مبلغ + وقت
          Row(
            children: [
              Icon(Icons.payments_outlined,
                  size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Text(
                Formatters.formatCurrency(order.totalAmount),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: 12.w),
              Icon(Icons.access_time,
                  size: 16.r, color: AppColors.textSecondary),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  Formatters.formatRelativeTime(order.createdAt),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // العنوان
          Text(
            order.deliveryAddress,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => cubit.pickupOrder(order.id),
                icon: const Icon(Icons.delivery_dining, size: 18),
                label: const Text('استلام الطلب'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
              ),
            ],
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
      builder: (ctx) => _OrderDetailsSheet(order: order),
    );
  }
}

class _OrderDetailsSheet extends StatelessWidget {
  final Order order;

  const _OrderDetailsSheet({required this.order});

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
              Row(
                children: [
                  Icon(Icons.receipt_long,
                      color: AppColors.primary, size: 28.r),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      Formatters.formatOrderNumber(order.orderNumber),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _DetailRow(
                label: 'المجموع الفرعي',
                value: Formatters.formatCurrency(order.subtotal),
              ),
              _DetailRow(
                label: 'رسوم التوصيل',
                value: Formatters.formatCurrency(order.deliveryFee),
              ),
              _DetailRow(
                label: 'خصم النقاط',
                value: Formatters.formatCurrency(order.pointsDiscount),
              ),
              _DetailRow(
                label: 'إجمالي الفاتورة',
                value: Formatters.formatCurrency(order.totalAmount),
              ),
              SizedBox(height: 16.h),
              _DetailRow(
                label: 'العنوان',
                value: order.deliveryAddress,
              ),
              if (order.deliveryLandmark != null &&
                  order.deliveryLandmark!.isNotEmpty)
                _DetailRow(
                  label: 'علامة مميزة',
                  value: order.deliveryLandmark!,
                ),
              if (order.customerNotes != null &&
                  order.customerNotes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Text(
                  'ملاحظات العميل',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  order.customerNotes!,
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
            width: 120.w,
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