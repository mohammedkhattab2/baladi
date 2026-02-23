import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order.dart';
import 'package:baladi/domain/enums/order_status.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_state.dart';
import 'package:baladi/presentation/features/shop/shell/shop_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopOrdersScreen extends StatelessWidget {
  const ShopOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopManagementCubit>()..loadOrders(),
      child: const _ShopOrdersView(),
    );
  }
}

class _ShopOrdersView extends StatefulWidget {
  const _ShopOrdersView();

  @override
  State<_ShopOrdersView> createState() => _ShopOrdersViewState();
}

class _ShopOrdersViewState extends State<_ShopOrdersView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  OrderStatus? _selectedStatus;

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
      final state = context.read<ShopManagementCubit>().state;
      if (state is ShopOrdersLoaded && state.hasMore) {
        context.read<ShopManagementCubit>().loadMoreOrders(
              status: _selectedStatus,
            );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopShell(
      currentRoute: RouteNames.shopOrders,
      title: 'طلبات المتجر',
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
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
                if (state is ShopManagementLoading ||
                    state is ShopProductActionLoading) {
                  return const Center(child: LoadingWidget());
                }
                if (state is ShopManagementError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context
                        .read<ShopManagementCubit>()
                        .loadOrders(status: _selectedStatus),
                  );
                }
                if (state is ShopOrdersLoaded) {
                  return _buildOrdersList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───── Filters ─────

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.surface,
      child: Column(
        children: [
          AppSearchField(
            controller: _searchController,
            hint: 'بحث برقم الطلب...',
            onChanged: (value) {
              // TODO: فلترة محلية لو حبيت
            },
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _StatusChip(
                  label: 'الكل',
                  isSelected: _selectedStatus == null,
                  onTap: () => _onStatusFilter(null),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.pending.labelAr,
                  isSelected: _selectedStatus == OrderStatus.pending,
                  color: AppColors.statusPending,
                  onTap: () => _onStatusFilter(OrderStatus.pending),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.accepted.labelAr,
                  isSelected: _selectedStatus == OrderStatus.accepted,
                  color: AppColors.statusAccepted,
                  onTap: () => _onStatusFilter(OrderStatus.accepted),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.preparing.labelAr,
                  isSelected: _selectedStatus == OrderStatus.preparing,
                  color: AppColors.statusPreparing,
                  onTap: () => _onStatusFilter(OrderStatus.preparing),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.pickedUp.labelAr,
                  isSelected: _selectedStatus == OrderStatus.pickedUp,
                  color: AppColors.statusPickedUp,
                  onTap: () => _onStatusFilter(OrderStatus.pickedUp),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.shopPaid.labelAr,
                  isSelected: _selectedStatus == OrderStatus.shopPaid,
                  color: AppColors.statusShopPaid,
                  onTap: () => _onStatusFilter(OrderStatus.shopPaid),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.completed.labelAr,
                  isSelected: _selectedStatus == OrderStatus.completed,
                  color: AppColors.statusCompleted,
                  onTap: () => _onStatusFilter(OrderStatus.completed),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.cancelled.labelAr,
                  isSelected: _selectedStatus == OrderStatus.cancelled,
                  color: AppColors.statusCancelled,
                  onTap: () => _onStatusFilter(OrderStatus.cancelled),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onStatusFilter(OrderStatus? status) {
    setState(() => _selectedStatus = status);
    context.read<ShopManagementCubit>().loadOrders(status: status);
  }

  // ───── List ─────

  Widget _buildOrdersList(ShopOrdersLoaded state) {
    if (state.orders.isEmpty) {
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد طلبات',
        description: 'طلبات متجرك ستظهر هنا بمجرد استقبالها',
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ShopManagementCubit>().loadOrders(
                status: _selectedStatus,
              ),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: state.orders.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.orders.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final order = state.orders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

// ───── Helper Widgets ─────

class _StatusChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? color;

  const _StatusChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = color ?? AppColors.textSecondary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? baseColor : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? baseColor : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShopManagementCubit>();

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => _showDetails(context),
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
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _StatusBadge(status: order.status),
            ],
          ),
          SizedBox(height: 8.h),

          // مبلغ + وقت
          Row(
            children: [
              Icon(
                Icons.payments_outlined,
                size: 16.r,
                color: AppColors.textSecondary,
              ),
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
              Icon(
                Icons.access_time,
                size: 16.r,
                color: AppColors.textSecondary,
              ),
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

          // أزرار أكشن للمتجر (قبول / بدء التحضير)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (order.status == OrderStatus.pending)
                TextButton.icon(
                  onPressed: () => cubit.acceptOrder(order.id),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('قبول الطلب'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                )
              else if (order.status == OrderStatus.accepted)
                TextButton.icon(
                  onPressed: () => cubit.markPreparing(order.id),
                  icon: const Icon(Icons.local_dining_outlined, size: 18),
                  label: const Text('بدء التحضير'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.info,
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
                  Icon(
                    Icons.receipt_long,
                    color: AppColors.primary,
                    size: 28.r,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          Formatters.formatOrderNumber(order.orderNumber),
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        _StatusBadge(status: order.status),
                      ],
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
                SizedBox(height: 6.h),
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