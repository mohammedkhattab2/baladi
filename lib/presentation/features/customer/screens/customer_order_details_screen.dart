import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order.dart';
import 'package:baladi/domain/entities/order_item.dart';
import 'package:baladi/domain/enums/order_status.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/order/order_cubit.dart';
import 'package:baladi/presentation/cubits/order/order_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerOrderDetailsScreen extends StatelessWidget {
  final String orderId;

  const CustomerOrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderCubit>()..loadOrderDetails(orderId),
      child: _OrderDetailsView(orderId: orderId),
    );
  }
}

class _OrderDetailsView extends StatelessWidget {
  final String orderId;

  const _OrderDetailsView({required this.orderId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'تفاصيل الطلب',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocConsumer<OrderCubit, OrderState>(
        listener: (context, state) {
          if (state is OrderError) {
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
          if (state is OrderActionLoading ||
              state is OrderInitial ||
              state is OrdersLoading) {
            return const Center(child: LoadingWidget());
          }
          if (state is OrderError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<OrderCubit>().loadOrderDetails(orderId),
            );
          }
          if (state is OrderDetailLoaded) {
            return _OrderDetailsBody(order: state.order);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _OrderDetailsBody extends StatelessWidget {
  final Order order;

  const _OrderDetailsBody({required this.order});

  @override
  Widget build(BuildContext context) {
    final canCancel = order.status == OrderStatus.pending ||
        order.status == OrderStatus.accepted;

    return RefreshIndicator(
      onRefresh: () =>
          context.read<OrderCubit>().loadOrderDetails(order.id),
      color: AppColors.primary,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الهيدر
            AppCard(
              padding: EdgeInsets.all(16.w),
              borderColor: _statusColor(order.status),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          Formatters.formatOrderNumber(order.orderNumber),
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      _StatusBadge(status: order.status),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'أنشئ منذ ${Formatters.formatRelativeTime(order.createdAt)}',
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

            // العناصر
            Text(
              'العناصر',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            ...order.items.map((i) => _OrderItemRow(item: i)),
            SizedBox(height: 16.h),

            // الملخص المالي
            Text(
              'الملخص المالي',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
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

            // العنوان
            Text(
              'عنوان التوصيل',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
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
                'ملاحظاتك للمتجر',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15.sp,
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

            SizedBox(height: 20.h),

            // زر الإلغاء
            if (canCancel)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => context
                      .read<OrderCubit>()
                      .cancelOrder(orderId: order.id),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text('إلغاء الطلب'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.accepted:
        return AppColors.statusAccepted;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.pickedUp:
        return AppColors.statusPickedUp;
      case OrderStatus.shopPaid:
        return AppColors.statusShopPaid;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;

  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(6.r),
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

  Color _color(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return AppColors.statusPending;
      case OrderStatus.accepted:
        return AppColors.statusAccepted;
      case OrderStatus.preparing:
        return AppColors.statusPreparing;
      case OrderStatus.pickedUp:
        return AppColors.statusPickedUp;
      case OrderStatus.shopPaid:
        return AppColors.statusShopPaid;
      case OrderStatus.completed:
        return AppColors.statusCompleted;
      case OrderStatus.cancelled:
        return AppColors.statusCancelled;
    }
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;

  const _OrderItemRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 6.h),
      padding: EdgeInsets.all(10.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productName,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            'x${item.quantity}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            Formatters.formatCurrency(item.subtotal),
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
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
      padding: EdgeInsets.symmetric(vertical: 3.h),
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