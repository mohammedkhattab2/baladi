import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order_item.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/cart/cart_state.dart';
import 'package:baladi/presentation/features/customer/widgets/customer_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CustomerCartScreen extends StatelessWidget {
  const CustomerCartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CartCubit>()..loadCart(),
      child: const _CartView(),
    );
  }
}

class _CartView extends StatelessWidget {
  const _CartView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'السلة',
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
      body: BlocConsumer<CartCubit, CartState>(
        listener: (context, state) {
          if (state is CartError) {
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
          if (state is CartLoading || state is CartInitial) {
            return const Center(child: LoadingWidget());
          }
          if (state is CartError && state.items.isEmpty) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<CartCubit>().loadCart(),
            );
          }
          if (state is CartLoaded) {
            if (state.isEmpty) {
              return const AppEmptyState(
                icon: Icons.shopping_bag_outlined,
                title: 'السلة فارغة',
                description: 'أضف منتجات من المتاجر ليظهر طلبك هنا.',
              );
            }
            return _buildCartContent(context, state);
          }
          if (state is CartError) {
            // في حالة وجود بيانات سابقة
            return _buildCartContent(
              context,
              CartLoaded(
                shopId: null,
                items: state.items,
                totalItems: state.items.fold(
                    0, (sum, item) => sum + item.quantity),
                subtotal: state.items.fold(
                    0, (sum, item) => sum + item.subtotal),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 2),
    );
  }

  Widget _buildCartContent(BuildContext context, CartLoaded state) {
    final cubit = context.read<CartCubit>();

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: state.items.length,
            itemBuilder: (context, index) {
              final item = state.items[index];
              return _CartItemTile(
                item: item,
                onIncrease: () {
                  final productId = item.productId;
                  if (productId == null) return;
                  cubit.updateQuantity(
                    productId: productId,
                    quantity: item.quantity + 1,
                  );
                },
                onDecrease: () {
                  final productId = item.productId;
                  if (productId == null) return;
                  cubit.updateQuantity(
                    productId: productId,
                    quantity: item.quantity - 1,
                  );
                },
                onRemove: () {
                  final productId = item.productId;
                  if (productId == null) return;
                  cubit.removeItem(productId);
                },
              );
            },
            separatorBuilder: (_, __) => SizedBox(height: 8.h),
          ),
        ),
        // الملخص + زر إتمام الطلب
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0A1628).withValues(alpha:  0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Text(
                    'الإجمالي الفرعي',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    Formatters.formatCurrency(state.subtotal),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Text(
                    'عدد العناصر: ${state.totalItems}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => cubit.clearCart(),
                    child: Text(
                      'مسح السلة',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 12.sp,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: state.shopId == null
                      ? null
                      : () => context.goNamed(RouteNames.checkout),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textOnPrimary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'إتمام الطلب',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final OrderItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onRemove;

  const _CartItemTile({
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          // اسم + سعر
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
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
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatCurrency(item.price),
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
          // عداد الكمية
          Row(
            children: [
              _QuantityButton(
                icon: Icons.remove_rounded,
                onTap: onDecrease,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              _QuantityButton(
                icon: Icons.add_rounded,
                onTap: onIncrease,
              ),
            ],
          ),
          SizedBox(width: 8.w),
          // الإجمالي
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(item.subtotal),
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              IconButton(
                onPressed: onRemove,
                icon: Icon(
                  Icons.delete_outline,
                  size: 18.r,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        width: 26.r,
        height: 26.r,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(
          icon,
          size: 16.r,
          color: AppColors.primary,
        ),
      ),
    );
  }
}