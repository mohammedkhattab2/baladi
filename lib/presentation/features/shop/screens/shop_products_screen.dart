import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/product.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_state.dart';
import 'package:baladi/presentation/features/shop/screens/shop_product_form_screen.dart';
import 'package:baladi/presentation/features/shop/shell/shop_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopProductsScreen extends StatelessWidget {
  const ShopProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopManagementCubit>()..loadProducts(),
      child: const _ShopProductsView(),
    );
  }
}

class _ShopProductsView extends StatefulWidget {
  const _ShopProductsView();

  @override
  State<_ShopProductsView> createState() => _ShopProductsViewState();
}

class _ShopProductsViewState extends State<_ShopProductsView> {
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
      final state = context.read<ShopManagementCubit>().state;
      if (state is ShopProductsLoaded && state.hasMore) {
        context.read<ShopManagementCubit>().loadMoreProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ShopShell(
      currentRoute: RouteNames.shopProducts,
      title: 'منتجات المتجر',
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('منتج جديد'),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
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
                    onRetry: () =>
                        context.read<ShopManagementCubit>().loadProducts(),
                  );
                }
                if (state is ShopProductsLoaded) {
                  return _buildProductsList(state);
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
        hint: 'بحث باسم المنتج...',
        onChanged: (value) {
          // TODO: فلترة محلية لو حبيت
        },
      ),
    );
  }

  Widget _buildProductsList(ShopProductsLoaded state) {
    if (state.products.isEmpty) {
      return const AppEmptyState(
        icon: Icons.inventory_2_outlined,
        title: 'لا توجد منتجات',
        description: 'أضف أول منتج لمتجرك من زر "منتج جديد".',
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<ShopManagementCubit>().loadProducts(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.products.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }

          final product = state.products[index];
          return _ProductCard(product: product);
        },
      ),
    );
  }

  void _openForm(BuildContext context, {Product? product}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ShopManagementCubit>(),
          child: ShopProductFormScreen(product: product),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ShopManagementCubit>();

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => _openForm(context),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.inventory_2_outlined,
              color: AppColors.secondary,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.displayName,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _AvailabilityChip(isAvailable: product.isAvailable),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatCurrency(product.price),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    product.description!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, size: 20.r, color: AppColors.textHint),
            onSelected: (value) {
              if (value == 'toggle') {
                cubit.updateProduct(
                  productId: product.id,
                  isAvailable: !product.isAvailable,
                );
              } else if (value == 'edit') {
                _openForm(context);
              } else if (value == 'delete') {
                _confirmDelete(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'toggle',
                child: Row(
                  children: [
                    Icon(
                      product.isAvailable
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 18.r,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      product.isAvailable ? 'إخفاء المنتج' : 'إظهار المنتج',
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 18.r, color: AppColors.info),
                    SizedBox(width: 8.w),
                    const Text('تعديل'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 18.r, color: AppColors.error),
                    SizedBox(width: 8.w),
                    const Text('حذف'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openForm(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<ShopManagementCubit>(),
          child: ShopProductFormScreen(product: product),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final cubit = context.read<ShopManagementCubit>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف المنتج',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف "${product.displayName}"؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'إلغاء',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              cubit.deleteProduct(product.id);
            },
            child: Text(
              'حذف',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  final bool isAvailable;

  const _AvailabilityChip({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.success : AppColors.textSecondary;
    final label = isAvailable ? 'متاح' : 'غير متاح';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(6.r),
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