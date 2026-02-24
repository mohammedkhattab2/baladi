import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReferralScreen extends StatefulWidget {
  const ReferralScreen({super.key});

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<CustomerProfileCubit>()..loadProfile(),
      child: BlocConsumer<CustomerProfileCubit, CustomerProfileState>(
        listener: (context, state) {
          if (state is CustomerReferralApplied) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تطبيق كود الإحالة بنجاح',
                  style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _codeController.clear();
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
            );
          }

          final customer = (state is CustomerProfileLoaded)
              ? state.customer
              : (state is CustomerProfileUpdating)
                  ? state.customer
                  : (state is CustomerProfileError && state.customer != null)
                      ? state.customer!
                      : (state is CustomerReferralApplied)
                          ? state.customer
                          : null;

          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: _buildAppBar(),
            body: customer == null
                ? const Center(child: LoadingWidget())
                : _buildBody(context, customer.referralCode),
          );
        },
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        'برنامج الإحالة',
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

  Widget _buildBody(BuildContext context, String? referralCode) {
    final cubit = context.read<CustomerProfileCubit>();

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'شارك كود إحالتك مع أصدقائك',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'عند تسجيل صديق بحساب جديد واستخدام كودك، يحصل هو على نقاط ترحيبية وتحصل أنت على نقاط إضافية.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                if (referralCode != null && referralCode.isNotEmpty)
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.04),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.4),
                            ),
                          ),
                          child: Text(
                            referralCode,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      IconButton(
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: referralCode),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'تم نسخ الكود إلى الحافظة',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                              backgroundColor: AppColors.primary,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy_rounded),
                        color: AppColors.primary,
                      ),
                    ],
                  )
                else
                  Text(
                    'سيظهر كود الإحالة الخاص بك هنا بعد تفعيل برنامج الإحالة لحسابك.',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'امتلك كود إحالة وتريد استخدامه؟',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استخدم كود إحالة لصديق واحد فقط، لتحصل على نقاط إضافية.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _codeController,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'أدخل كود الإحالة هنا',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    isDense: true,
                  ),
                ),
                SizedBox(height: 12.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final code = _codeController.text.trim();
                      if (code.isEmpty) return;
                      cubit.applyReferral(code);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'تطبيق الكود',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}