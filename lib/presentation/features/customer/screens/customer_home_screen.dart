import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/ad/ad_cubit.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/catalog/categories_cubit.dart';
import 'package:baladi/presentation/cubits/catalog/categories_state.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart';
import 'package:baladi/presentation/cubits/notification/notification_cubit.dart';
import 'package:baladi/presentation/features/customer/widgets/customer_bottom_nav.dart';
import 'package:baladi/presentation/features/customer/widgets/home_ads_carousel.dart';
import 'package:baladi/presentation/features/customer/widgets/home_category_card.dart';
import 'package:baladi/presentation/features/customer/widgets/home_header.dart';
import 'package:baladi/presentation/features/customer/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<AdCubit>()..loadActiveAds()),
        BlocProvider(create: (_) => getIt<CategoriesCubit>()..loadCategories()),
        BlocProvider(
          create: (_) => getIt<CustomerProfileCubit>()..loadProfile(),
        ),
        BlocProvider(
          create: (_) => getIt<NotificationCubit>()..loadNotifications(),
        ),
        BlocProvider(create: (_) => getIt<CartCubit>()..loadCart()),
      ],
      child: const _CustomerHomeView(),
    );
  }
}

class _CustomerHomeView extends StatelessWidget {
  const _CustomerHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: () => _onRefresh(context),
        color: AppColors.primary,
        backgroundColor: Colors.white,
        strokeWidth: 2.5,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Header
            const SliverToBoxAdapter(child: HomeHeader()),
            
            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: HomeSearchBar(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'البحث قريباً...',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14.sp,
                          ),
                        ),
                        backgroundColor: const Color(0xFF0A1628),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        margin: EdgeInsets.all(16.r),
                      ),
                    );
                  },
                ),
              ),
            ),
            
            // Ads Carousel
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: const HomeAdsCarousel(),
              ),
            ),
            
            // Categories Section Header
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 32.h, 20.w, 16.h),
                child: Row(
                  children: [
                    // Section icon
                    Container(
                      padding: EdgeInsets.all(8.r),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.primary.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.primary,
                        size: 18.r,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      "الأقسام",
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0A1628),
                        letterSpacing: 0.3,
                      ),
                    ),
                    const Spacer(),
                    // View all button
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.15),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "عرض الكل",
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: 10.r,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Categories Grid
            BlocBuilder<CategoriesCubit, CategoriesState>(
              builder: (context, state) {
                if (state is CategoriesLoading) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, __) => _buildCategoryShimmer(),
                        childCount: 8,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.85,
                      ),
                    ),
                  );
                }
                if (state is CategoriesError) {
                  return SliverToBoxAdapter(
                    child: _buildErrorState(context, state.message),
                  );
                }
                if (state is CategoriesLoaded) {
                  return SliverPadding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            HomeCategoryCard(category: state.categories[index]),
                        childCount: state.categories.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 12.h,
                        crossAxisSpacing: 12.w,
                        childAspectRatio: 0.85,
                      ),
                    ),
                  );
                }
                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),
            
            // Bottom spacing
            SliverToBoxAdapter(
              child: SizedBox(height: 120.h),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomerBottomNav(currentIndex: 0),
    );
  }

  Widget _buildCategoryShimmer() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0A1628).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShimmerBox(
            width: 56.r,
            height: 56.r,
            borderRadius: 16,
          ),
          SizedBox(height: 10.h),
          ShimmerBox(
            width: 50.w,
            height: 12.h,
            borderRadius: 6,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: const Color(0xFFEF4444).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              color: const Color(0xFFEF4444),
              size: 32.r,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF0A1628),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              color: const Color(0xFF0A1628).withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          GestureDetector(
            onTap: () => context.read<CategoriesCubit>().loadCategories(),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary,
                    Color(0xFF34D399),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 18.r,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'إعادة المحاولة',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onRefresh(BuildContext context) async {
    context.read<AdCubit>().loadActiveAds();
    context.read<CategoriesCubit>().loadCategories();
    context.read<CustomerProfileCubit>().loadProfile();
    context.read<NotificationCubit>().loadNotifications();
  }
}
