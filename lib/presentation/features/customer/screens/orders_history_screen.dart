import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order.dart';
import 'package:baladi/domain/enums/order_status.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/order/order_cubit.dart';
import 'package:baladi/presentation/cubits/order/order_state.dart';
import 'package:baladi/presentation/features/customer/widgets/customer_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
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
    final cubit = context.read<OrderCubit>();
    final state = cubit.state;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (state is OrdersLoaded && state.hasMore) {
        cubit.loadMoreOrders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<OrderCubit>()..loadOrders()),
        BlocProvider(create: (_) => getIt<CartCubit>()..loadCart()),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            'طلباتي',
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
            if (state is OrderError && state.orders.isNotEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.message,
                    style:
                        TextStyle(fontFamily: AppTextStyles.fontFamily),
                  ),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is OrdersLoading || state is OrderInitial) {
              return const Center(child: LoadingWidget());
            }

            if (state is OrderError && state.orders.isEmpty) {
              return AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<OrderCubit>().loadOrders(),
              );
            }

            List<Order> orders = [];
            bool loadingMore = false;

            if (state is OrdersLoaded) {
              orders = state.orders;
              loadingMore = false;
            } else if (state is OrdersLoadingMore) {
              orders = state.orders;
              loadingMore = true;
            } else if (state is OrderError) {
              orders = state.orders;
            }

            if (orders.isEmpty) {
              return const AppEmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'لا توجد طلبات بعد',
                description:
                    'عند قيامك بأول طلب شراء، سيظهر هنا في قائمة الطلبات.',
              );
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<OrderCubit>().loadOrders(),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: orders.length + (loadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (loadingMore && index == orders.length) {
                    return Padding(
                      padding: EdgeInsets.all(16.r),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  final order = orders[index];
                  return _OrderCard(order: order);
                },
              ),
            );
          },
        ),
        bottomNavigationBar: const CustomerBottomNav(currentIndex: 1),
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
      margin: EdgeInsets.only(bottom: 10.h),
      onTap: () => context.goNamed(
        RouteNames.customerOrderDetails,
        pathParameters: {'id': order.id},
      ),
      borderColor: _statusColor(order.status),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // رقم الطلب + الحالة
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
          SizedBox(height: 6.h),

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
        ],
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