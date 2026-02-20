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
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_state.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminOrdersScreen extends StatelessWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadOrders(),
      child: const _AdminOrdersView(),
    );
  }
}

class _AdminOrdersView extends StatefulWidget {
  const _AdminOrdersView();

  @override
  State<_AdminOrdersView> createState() => _AdminOrdersViewState();
}

class _AdminOrdersViewState extends State<_AdminOrdersView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  /// القيمة اللي بتتبعت للـ API (pending / accepted / ... ) أو null للكل
  String? _selectedStatus;

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
      final state = context.read<AdminCubit>().state;
      if (state is AdminOrdersLoaded && state.hasMore) {
        context
            .read<AdminCubit>()
            .loadMoreOrders(status: _selectedStatus);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: RouteNames.adminOrders,
      title: 'إدارة الطلبات',
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
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
                    onRetry: () =>
                        context.read<AdminCubit>().loadOrders(
                              status: _selectedStatus,
                            ),
                  );
                }
                if (state is AdminOrdersLoaded) {
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

  // ───────────── Filters (Search + Status) ─────────────

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
              // لا نستدعي API هنا عشان ما نحملش السيرفر على كل حرف.
              // بنعمل فلترة محلية في الـ UI بناءً على رقم الطلب المعروض.
              setState(() {});
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
                  isSelected: _selectedStatus == OrderStatus.pending.value,
                  color: AppColors.statusPending,
                  onTap: () => _onStatusFilter(OrderStatus.pending.value),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.accepted.labelAr,
                  isSelected: _selectedStatus == OrderStatus.accepted.value,
                  color: AppColors.statusAccepted,
                  onTap: () => _onStatusFilter(OrderStatus.accepted.value),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.preparing.labelAr,
                  isSelected: _selectedStatus == OrderStatus.preparing.value,
                  color: AppColors.statusPreparing,
                  onTap: () => _onStatusFilter(OrderStatus.preparing.value),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.pickedUp.labelAr,
                  isSelected: _selectedStatus == OrderStatus.pickedUp.value,
                  color: AppColors.statusPickedUp,
                  onTap: () => _onStatusFilter(OrderStatus.pickedUp.value),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.shopPaid.labelAr,
                  isSelected: _selectedStatus == OrderStatus.shopPaid.value,
                  color: AppColors.statusShopPaid,
                  onTap: () => _onStatusFilter(OrderStatus.shopPaid.value),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.completed.labelAr,
                  isSelected: _selectedStatus == OrderStatus.completed.value,
                  color: AppColors.statusCompleted,
                  onTap: () => _onStatusFilter(OrderStatus.completed.value),
                ),
                SizedBox(width: 8.w),
                _StatusChip(
                  label: OrderStatus.cancelled.labelAr,
                  isSelected: _selectedStatus == OrderStatus.cancelled.value,
                  color: AppColors.statusCancelled,
                  onTap: () => _onStatusFilter(OrderStatus.cancelled.value),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onStatusFilter(String? status) {
    setState(() => _selectedStatus = status);
    context.read<AdminCubit>().loadOrders(status: _selectedStatus);
  }

  // ───────────── List ─────────────

  Widget _buildOrdersList(AdminOrdersLoaded state) {
    final query = _searchController.text.trim();

    // فلترة محلية برقم الطلب على البيانات اللي رجعت من الـ API
    final filteredOrders = state.orders.where((order) {
      if (query.isEmpty) return true;
      // نستخدم toString عشان orderNumber ممكن يكون int أو String في الـ Entity
      return order.orderNumber.toString().contains(query);
    }).toList();

    if (state.orders.isEmpty) {
      // مفيش أي طلبات في النظام أساسًا
      return const AppEmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'لا توجد طلبات',
        description: 'الطلبات ستظهر هنا بمجرد إنشائها',
      );
    }

    if (filteredOrders.isEmpty) {
      // في طلبات موجودة لكن البحث الحالي مديش أي نتيجة
      return const AppEmptyState(
        icon: Icons.search_off,
        title: 'لا توجد نتائج',
        description: 'جرّب البحث برقم طلب مختلف',
      );
    }

    final showLoaderAtEnd = state.hasMore && query.isEmpty;

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<AdminCubit>().loadOrders(status: _selectedStatus),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: filteredOrders.length + (showLoaderAtEnd ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredOrders.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final order = filteredOrders[index];
          return _OrderCard(order: order);
        },
      ),
    );
  }
}

// ───────────── Widgets مساعدة ─────────────

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
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => _showDetails(context),
      borderColor: _statusColor(order.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // First row: order number + status badge
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

          // Amount + created at
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

          // Cash flow flags
          Row(
            children: [
              _CashFlag(
                icon: Icons.attach_money,
                label: 'من العميل',
                isDone: order.cashCollected,
              ),
              SizedBox(width: 8.w),
              _CashFlag(
                icon: Icons.storefront,
                label: 'للمحل',
                isDone: order.cashToShop,
              ),
              SizedBox(width: 8.w),
              _CashFlag(
                icon: Icons.check_circle_outline,
                label: 'تأكيد المحل',
                isDone: order.shopConfirmedCash,
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
    final color = _statusColor(status);
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

class _CashFlag extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDone;

  const _CashFlag({
    required this.icon,
    required this.label,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDone ? AppColors.success : AppColors.textSecondary;
    return Row(
      children: [
        Icon(icon, size: 14.r, color: color),
        SizedBox(width: 2.w),
        Icon(
          isDone ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 12.r,
          color: color,
        ),
        SizedBox(width: 2.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 10.sp,
            color: color,
          ),
        ),
      ],
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
              _DetailRow(
                label: 'نقاط مكتسبة',
                value: order.pointsEarned.toString(),
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