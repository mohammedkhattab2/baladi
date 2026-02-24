import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/points/points_cubit.dart';
import 'package:baladi/presentation/cubits/points/points_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PointsScreen extends StatelessWidget {
  const PointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<PointsCubit>()..loadPoints(),
      child: const _PointsView(),
    );
  }
}

class _PointsView extends StatelessWidget {
  const _PointsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'نقاطي',
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
      body: BlocBuilder<PointsCubit, PointsState>(
        builder: (context, state) {
          if (state is PointsLoading || state is PointsInitial) {
            return const Center(child: LoadingWidget());
          }
          if (state is PointsError && state.balance == null) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<PointsCubit>().loadPoints(),
            );
          }

          final balance = state is PointsLoaded
              ? state.balance
              : (state is PointsError && state.balance != null
                  ? state.balance!
                  : 0);

          final history = state is PointsLoaded ? state.history : const [];

          return RefreshIndicator(
            onRefresh: () => context.read<PointsCubit>().loadPoints(),
            color: AppColors.primary,
            backgroundColor: Colors.white,
            strokeWidth: 2.5,
            child: ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                AppCard(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'إجمالي رصيدك',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 13.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        '$balance نقطة',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 24.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'يمكنك استخدام نقاطك للحصول على خصومات على الطلبات.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'سجل النقاط',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                if (history.isEmpty)
                  const AppEmptyState(
                    icon: Icons.loyalty_outlined,
                    title: 'لا توجد حركات نقاط بعد',
                    description:
                        'عند تنفيذ طلبات أو استخدام كود إحالة سيظهر سجل النقاط هنا.',
                  )
                else
                  ...history.map(
                    (tx) => AppCard(
                      margin: EdgeInsets.only(bottom: 8.h),
                      padding: EdgeInsets.all(12.w),
                      child: Row(
                        children: [
                          Icon(
                            Icons.stars_rounded,
                            size: 20.r,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Text(
                              'معاملة نقاط',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13.sp,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          // نفترض وجود createdAt في PointsTransaction (نفس نمط باقي الكيانات)
                          // لو الاسم مختلف عدّله حسب الـ entity
                          Text(
                            Formatters.formatDateTime(tx.createdAt),
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 11.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}