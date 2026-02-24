import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_state.dart';
import 'package:baladi/presentation/features/customer/widgets/customer_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomerProfileScreen extends StatefulWidget {
  const CustomerProfileScreen({super.key});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _areaController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _landmarkController.dispose();
    _areaController.dispose();
    super.dispose();
  }

  void _fillControllers(CustomerProfileState state) {
    final customer = switch (state) {
      CustomerProfileLoaded s => s.customer,
      CustomerProfileUpdating s => s.customer,
      CustomerReferralApplied s => s.customer,
      CustomerProfileError s when s.customer != null => s.customer!,
      _ => null,
    };

    if (customer == null) return;

    _nameController.text = customer.fullName;
    _addressController.text = customer.addressText ?? '';
    _landmarkController.text = customer.landmark ?? '';
    _areaController.text = customer.area ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CustomerProfileCubit>()..loadProfile(),
      child: BlocConsumer<CustomerProfileCubit, CustomerProfileState>(
        listener: (context, state) {
          if (state is CustomerProfileLoaded ||
              state is CustomerProfileUpdating ||
              state is CustomerReferralApplied ||
              (state is CustomerProfileError && state.customer != null)) {
            _fillControllers(state);
          }
          if (state is CustomerProfileError) {
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
          if (state is CustomerProfileLoading ||
              state is CustomerProfileInitial) {
            return const Scaffold(
              backgroundColor: Color(0xFFF8FAFC),
              body: Center(child: LoadingWidget()),
            );
          }
          if (state is CustomerProfileError &&
              state.customer == null) {
            return Scaffold(
              backgroundColor: const Color(0xFFF8FAFC),
              appBar: _buildAppBar(),
              body: AppErrorWidget(
                message: state.message,
                onRetry: () =>
                    context.read<CustomerProfileCubit>().loadProfile(),
              ),
              bottomNavigationBar:
                  const CustomerBottomNav(currentIndex: 3),
            );
          }

          final customer = switch (state) {
            CustomerProfileLoaded s => s.customer,
            CustomerProfileUpdating s => s.customer,
            CustomerReferralApplied s => s.customer,
            CustomerProfileError s when s.customer != null => s.customer!,
            _ => null,
          };

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(),
            body: customer == null
                ? const Center(child: LoadingWidget())
                : _buildBody(context),
            bottomNavigationBar: const CustomerBottomNav(
              currentIndex: 3,
            ),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'حسابي',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.textOnPrimary,
    );
  }

  Widget _buildBody(BuildContext context) {
    final cubit = context.read<CustomerProfileCubit>();

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
                      width: 56.r,
                      height: 56.r,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                        size: 30.r,
                      ),
                    ),
                    SizedBox(width: 14.w),
                    Expanded(
                      child: Text(
                        'بيانات الحساب',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 18.h),

                Text(
                  'الاسم الكامل',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),

                Text(
                  'عنوان التوصيل',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4.h),
                TextField(
                  controller: _addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _landmarkController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'علامة مميزة (اختياري)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _areaController,
                  decoration: InputDecoration(
                    isDense: true,
                    labelText: 'المنطقة / الحي (اختياري)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final name = _nameController.text.trim();
                      final address = _addressController.text.trim();

                      if (name.isNotEmpty) {
                        cubit.updateProfile(fullName: name);
                      }
                      if (address.isNotEmpty) {
                        cubit.updateAddress(
                          addressText: address,
                          landmark: _landmarkController.text.trim().isEmpty
                              ? null
                              : _landmarkController.text.trim(),
                          area: _areaController.text.trim().isEmpty
                              ? null
                              : _areaController.text.trim(),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14.r),
                      ),
                    ),
                    child: Text(
                      'حفظ التعديلات',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 10.h),
                Text(
                  'تسجيل الخروج وتنشيط / إلغاء الحساب محتاجين Flow منفصل حسب الـ Auth عندك.',
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
      ),
    );
  }
}