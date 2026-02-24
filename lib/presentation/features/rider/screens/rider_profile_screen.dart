// lib/presentation/features/rider/screens/rider_profile_screen.dart

import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/rider.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/rider/rider_cubit.dart';
import 'package:baladi/presentation/cubits/rider/rider_state.dart';
import 'package:baladi/presentation/features/rider/shell/rider_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<RiderCubit>()..loadDashboard(),
      child: const _RiderProfileView(),
    );
  }
}

class _RiderProfileView extends StatelessWidget {
  const _RiderProfileView();

  @override
  Widget build(BuildContext context) {
    return RiderShell(
      currentRoute: RouteNames.riderProfile,
      title: 'الملف الشخصي',
      child: BlocConsumer<RiderCubit, RiderState>(
        listener: (context, state) {
          if (state is RiderError) {
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
          if (state is RiderLoading || state is RiderTogglingAvailability) {
            return const Center(child: LoadingWidget());
          }
          if (state is RiderError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () => context.read<RiderCubit>().loadDashboard(),
            );
          }
          if (state is RiderDashboardLoaded) {
            return _ProfileContent(rider: state.rider);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final Rider rider;

  const _ProfileContent({required this.rider});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AppCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // الهيدر
                Row(
                  children: [
                    Container(
                      width: 64.r,
                      height: 64.r,
                      decoration: BoxDecoration(
                        color: AppColors.info.withValues(alpha:  0.1),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.delivery_dining,
                        color: AppColors.info,
                        size: 32.r,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rider.fullName,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            rider.phone,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 13.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),

                _DetailRow(label: 'رقم الهاتف', value: rider.phone),
                _DetailRow(
                  label: 'حالة الحساب',
                  value: rider.isActive ? 'نشط' : 'معطل',
                ),
                _DetailRow(
                  label: 'متاح للتوصيل',
                  value: rider.isAvailable ? 'نعم' : 'لا',
                ),
                // لو عندك في Rider فيلد اسمه deliveryFee فعلاً خليه، لو مش موجود شيله:
                _DetailRow(
                  label: 'أجرة التوصيل الافتراضية',
                  value: Formatters.formatCurrency(rider.deliveryFee),
                ),
                _DetailRow(
                  label: 'تاريخ الانضمام',
                  value: Formatters.formatDateTime(rider.createdAt),
                ),

                SizedBox(height: 8.h),
                Text(
                  'تعديل بيانات السائق (الاسم، الأجرة، ..) يحتاج Endpoints في الـ backend. حالياً الشاشة للعرض فقط.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
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