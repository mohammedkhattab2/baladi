import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_state.dart';
import 'package:baladi/presentation/cubits/notification/notification_cubit.dart';
import 'package:baladi/presentation/cubits/notification/notification_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 16.h),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
                    builder: (context, state) {
                      final name = state is CustomerProfileLoaded
                          ? state.customer.fullName.split(" ").first
                          : "";
                      return Text(
                        name.isNotEmpty ? 'مرحباً $name 👋' : 'مرحباً 👋',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textOnPrimary,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 4.h),
                  GestureDetector(
                    onTap: () => context.pushNamed(RouteNames.customerProfile),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                          size: 16.r,
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child:
                              BlocBuilder<
                                CustomerProfileCubit,
                                CustomerProfileState
                              >(
                                builder: (context, state) {
                                  String address = "أضف عنوان التوصيل";
                                  if (state is CustomerProfileLoaded &&
                                      state.customer.addressText != null) {
                                    address = state.customer.addressText!;
                                    if (address.length > 30) {
                                      address =
                                          '${address.substring(0, 30)}...';
                                    }
                                  }
                                  return Text(
                                    address,
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13.sp,
                                      color: AppColors.textOnPrimary.withValues(
                                        alpha: 0.8,
                                      ),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  );
                                },
                              ),
                        ),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: AppColors.textOnPrimary.withValues(alpha: 0.8),
                          size: 18.r,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            _NotificationBell(),
          ],
        ),
      ),
    );
  }
}

class _NotificationBell extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(RouteNames.notifications),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          color: AppColors.textOnPrimary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.notifications_outlined,
              color: AppColors.textOnPrimary,
              size: 24.r,
            ),
            BlocBuilder<NotificationCubit, NotificationState>(
              builder: (context, state) {
                final count = state is NotificationLoaded
                    ? state.unreadCount
                    : 0;
                if (count == 0) return SizedBox.shrink();
                return Positioned(
                  top: -4.r,
                  right: -4.r,
                  child: Container(
                    padding: EdgeInsets.all(4.r),
                    decoration: const BoxDecoration(
                      color:  AppColors.error,
                      shape: BoxShape.circle
                    ),
                    constraints: BoxConstraints(minWidth: 16.r),
                    child: Text(
                      count > 9 ? '9+' : '$count',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textOnPrimary, 
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                  );
              },
            ),
          ],
        ),
      ),
    );
  }
}
