import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/presentation/cubits/ad/ad_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/catalog/categories_cubit.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart';
import 'package:baladi/presentation/cubits/notification/notification_cubit.dart';
import 'package:baladi/presentation/features/customer/widgets/home_ads_carousel.dart';
import 'package:baladi/presentation/features/customer/widgets/home_header.dart';
import 'package:baladi/presentation/features/customer/widgets/home_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerHomeScreen extends StatelessWidget {
  const CustomerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AdCubit>()..loadActiveAds(),
        ),
        BlocProvider(
          create: (_) => getIt<CategoriesCubit>()..loadCategories(),
        ),
        BlocProvider(
          create: (_) => getIt<CustomerProfileCubit>()..loadProfile(),
        ),
        BlocProvider(
          create: (_) => getIt<NotificationCubit>()..loadNotifications(),
        ),
        BlocProvider(
          create: (_) => getIt<CartCubit>()..loadCart(),
        ),
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
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        onRefresh:()=> _onRefresh(context), 
        color: AppColors.primary,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: HomeHeader(),

            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 20.h),
                child: HomeSearchBar(
                  onTap: () {
                    // TODO: Navigate to search screen
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('البحث قريباً...')),
                    );
                  },
                ), 
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(top: 24.h),
                child: const HomeAdsCarousel(), 
              ),
            )
          ],
        ), 
        
        ),
    );
  }
  Future <void> _onRefresh (BuildContext context) async{
    context.read<AdCubit>().loadActiveAds();
    context.read<CategoriesCubit>().loadCategories();
    context.read<CustomerProfileCubit>().loadProfile();
    context.read<NotificationCubit>().loadNotifications();
  }
}