import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/result/result.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order.dart';
import 'package:baladi/domain/enums/order_status.dart';
import 'package:baladi/domain/repositories/order_repository.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopOrderManageScreen extends StatefulWidget {
  final String orderId;

  const ShopOrderManageScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<ShopOrderManageScreen> createState() => _ShopOrderManageScreenState();
}

class _ShopOrderManageScreenState extends State<ShopOrderManageScreen> {
  final _repo = getIt<OrderRepository>();

  Order? _order;
  String? _error;
  bool _loading = true;
  bool _actionLoading = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final Result<Order> result = await _repo.getOrderDetails(widget.orderId);

    result.fold(
      onSuccess: (order) {
        setState(() {
          _order = order;
          _loading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
    );
  }

  Future<void> _runAction(Future<Result<Order>> Function() action) async {
    setState(() {
      _actionLoading = true;
      _error = null;
    });

    final result = await action();

    result.fold(
      onSuccess: (order) {
        setState(() {
          _order = order;
          _actionLoading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _error = failure.message;
          _actionLoading = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'إدارة الطلب',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: LoadingWidget());
    }
    if (_error != null && _order == null) {
      return AppErrorWidget(
        message: _error!,
        onRetry: _loadOrder,
      );
    }
    if (_order == null) {
      return const SizedBox.shrink();
    }

    final order = _order!;

    return RefreshIndicator(
      onRefresh: _loadOrder,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppCard(
              padding: EdgeInsets.all(16.w),
              borderColor: _statusColor(order.status),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // رقم الطلب + حالة
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

            // المبالغ
            Text(
              'القيمة المالية',
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
                'ملاحظات العميل',
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

            // أخطاء الأكشن لو حصلت
            if (_error != null && _order != null) ...[
              AppErrorWidget(
                message: _error!,
                onRetry: null,
              ),
              SizedBox(height: 12.h),
            ],

            // الأزرار (الإجراءات)
            _buildActions(order),
            SizedBox(height: 12.h),
            if (_actionLoading)
              const Center(child: LoadingWidget()),
          ],
        ),
      ),
    );
  }

  Widget _buildActions(Order order) {
    final status = order.status;
    final List<Widget> buttons = [];

    // إلغاء الطلب (فقط pending / accepted)
    if (status == OrderStatus.pending || status == OrderStatus.accepted) {
      buttons.add(
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _actionLoading
                ? null
                : () => _runAction(
                      () => _repo.cancelOrder(orderId: order.id),
                    ),
            icon: const Icon(Icons.cancel_outlined, size: 18),
            label: const Text('إلغاء الطلب'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
          ),
        ),
      );
      buttons.add(SizedBox(width: 12.w));
    }

    // قبول الطلب
    if (status == OrderStatus.pending) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _actionLoading
                ? null
                : () => _runAction(() => _repo.acceptOrder(order.id)),
            icon: const Icon(Icons.check_circle_outline, size: 18),
            label: const Text('قبول الطلب'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ),
      );
    }

    // بدء التحضير
    if (status == OrderStatus.accepted) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _actionLoading
                ? null
                : () => _runAction(() => _repo.markPreparing(order.id)),
            icon: const Icon(Icons.restaurant_outlined, size: 18),
            label: const Text('بدء التحضير'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ),
      );
    }

    // تأكيد استلام الكاش من المندوب (shop_paid → completed)
    if (status == OrderStatus.shopPaid) {
      buttons.add(
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _actionLoading
                ? null
                : () => _runAction(
                      () => _repo.confirmCashReceived(order.id),
                    ),
            icon: const Icon(Icons.attach_money, size: 18),
            label: const Text('تأكيد استلام الكاش'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              foregroundColor: AppColors.textOnPrimary,
            ),
          ),
        ),
      );
    }

    if (buttons.isEmpty) {
      return Text(
        'لا توجد إجراءات متاحة لهذه الحالة.',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 13.sp,
          color: AppColors.textSecondary,
        ),
      );
    }

    return Row(children: buttons);
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
            width: 130.w,
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