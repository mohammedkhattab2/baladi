import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/shop.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/catalog/categories_cubit.dart';
import 'package:baladi/presentation/cubits/catalog/categories_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CategoryShopsScreen extends StatelessWidget {
  final String categorySlug;

  const CategoryShopsScreen({
    super.key,
    required this.categorySlug,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<CategoriesCubit>()..loadCategoryShops(categorySlug: categorySlug),
      child: _CategoryShopsView(categorySlug: categorySlug),
    );
  }
}

class _CategoryShopsView extends StatelessWidget {
  final String categorySlug;

  const _CategoryShopsView({required this.categorySlug});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'محلات القسم',
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
      body: BlocBuilder<CategoriesCubit, CategoriesState>(
        builder: (context, state) {
          // لودينج
          if (state is CategoryShopsLoading || state is CategoriesLoading) {
            return const Center(child: LoadingWidget());
          }

          // إيرور أثناء جلب محلات القسم
          if (state is CategoryShopsError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<CategoriesCubit>()
                  .loadCategoryShops(categorySlug: categorySlug),
            );
          }

          // إيرور عام في الكاتيجوري
          if (state is CategoriesError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context
                  .read<CategoriesCubit>()
                  .loadCategoryShops(categorySlug: categorySlug),
            );
          }

          // بيانات محلات القسم
          if (state is CategoryShopsLoaded) {
            final shops = state.shops;

            if (shops.isEmpty) {
              return const AppEmptyState(
                icon: Icons.storefront_outlined,
                title: 'لا توجد محلات في هذا القسم',
                description: 'سيتم عرض المحلات المتاحة لهذا القسم هنا.',
              );
            }

            return RefreshIndicator(
              onRefresh: () => context
                  .read<CategoriesCubit>()
                  .loadCategoryShops(categorySlug: categorySlug),
              color: AppColors.primary,
              backgroundColor: Colors.white,
              strokeWidth: 2.5,
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: shops.length,
                itemBuilder: (context, index) {
                  final shop = shops[index];
                  return _ShopCard(shop: shop);
                },
              ),
            );
          }

          // أول مرة (Initial) -> اطلب البيانات
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context
                .read<CategoriesCubit>()
                .loadCategoryShops(categorySlug: categorySlug);
          });
          return const Center(child: LoadingWidget());
        },
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    final isOpen = shop.isOpen;
    final minOrder = shop.minOrderAmount;

    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      onTap: () => context.goNamed(
        RouteNames.shopDetails,
        pathParameters: {'id': shop.id},
        extra: shop,
      ),
      child: Row(
        children: [
          // أيقونة المتجر
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha:  0.08),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.storefront,
              color: AppColors.primary,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),

          // بيانات المتجر
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الاسم + حالة الفتح
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shop.displayName,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    _OpenStatusChip(isOpen: isOpen),
                  ],
                ),
                SizedBox(height: 4.h),
                if (shop.address != null && shop.address!.isNotEmpty)
                  Text(
                    shop.address!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                if (minOrder > 0) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'حد أدنى للطلب: ${Formatters.formatCurrency(minOrder)}',
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

          Icon(
            Icons.chevron_left,
            color: AppColors.textHint,
            size: 20.r,
          ),
        ],
      ),
    );
  }
}

class _OpenStatusChip extends StatelessWidget {
  final bool isOpen;

  const _OpenStatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.success : AppColors.textSecondary;
    final label = isOpen ? 'مفتوح' : 'مغلق';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha:  0.08),
        borderRadius: BorderRadius.circular(8.r),
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