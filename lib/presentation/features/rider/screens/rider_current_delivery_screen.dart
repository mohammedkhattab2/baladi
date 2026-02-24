import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/core/result/result.dart';
import 'package:baladi/domain/entities/order.dart';
import 'package:baladi/domain/repositories/order_repository.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/features/rider/shell/rider_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiderCurrentDeliveryScreen extends StatefulWidget {
  final String orderId;

  const RiderCurrentDeliveryScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<RiderCurrentDeliveryScreen> createState() =>
      _RiderCurrentDeliveryScreenState();
}

class _RiderCurrentDeliveryScreenState
    extends State<RiderCurrentDeliveryScreen> {
  Order? _order;
  String? _error;
  bool _loading = true;

  final _repo = getIt<OrderRepository>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
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

  @override
  Widget build(BuildContext context) {
    return RiderShell(
      currentRoute: RouteNames.riderCurrentDelivery,
      title: 'الطلب الحالي',
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: LoadingWidget());
    }
    if (_error != null) {
      return AppErrorWidget(
        message: _error!,
        onRetry: _load,
      );
    }
    if (_order == null) {
      return const SizedBox.shrink();
    }

    final order = _order!;

    return RefreshIndicator(
      onRefresh: _load,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رقم الطلب + الحالة
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha:  0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    Formatters.formatOrderNumber(order.orderNumber),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'تم إنشاء الطلب ${Formatters.formatRelativeTime(order.createdAt)}',
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

            // تفاصيل المبالغ
            _SectionTitle('قيمة الطلب'),
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
              label: 'الإجمالي المطلوب من العميل',
              value: Formatters.formatCurrency(order.totalAmount),
            ),
            SizedBox(height: 16.h),

            // العنوان
            _SectionTitle('عنوان التوصيل'),
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
              _SectionTitle('ملاحظات العميل'),
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
        fontSize: 15.sp,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
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