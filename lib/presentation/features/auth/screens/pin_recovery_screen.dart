import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/core/utils/validators.dart';
import 'package:baladi/presentation/common/widgets/app_button.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:baladi/widgets/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PinRecoveryScreen extends StatefulWidget {
  const PinRecoveryScreen({super.key});

  @override
  State<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<PinRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _phoneFocus = FocusNode();

  @override
  void dispose() {
    _phoneController.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────

  void _handleSubmit(BuildContext blocContext) {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().recoverPin(
      phone: _phoneController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onStateChanged,
        builder: (context, state) {
          if (state is AuthPinRecoverySent) {
            return Scaffold(
              backgroundColor: AppColors.background,
              body: _SuccessView(
                message: state.message,
                onBackToLogin: () => Navigator.of(context).pop(),
              ),
            );
          }
          final isLoading = state is AuthLoading;
          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const AuthHeader(
                    title: 'استعادة رمز الدخول',
                    subtitle: 'أدخل رقم هاتفك المسجل وسنساعدك',
                  ),
                  SizedBox(height: 32.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const _InfoBanner(),
                          SizedBox(height: 28.h,),
                          AppTextField.phone(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            validator: Validators.validatePhone,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) =>
                                _handleSubmit(context),
                          ),
                          SizedBox(height: 32.h,),
                          AppButton.primary(
                            text: 'إرسال طلب الاستعادة',
                            onPressed: isLoading
                                  ? null
                                  : ()=> _handleSubmit(context),
                              isLoading: isLoading,
                              leadingIcon: Icons.send_outlined,
                            ),
                            SizedBox(height: 16.h,),
                            Center(
                              child: TextButton.icon(
                                onPressed: ()=> 
                                Navigator.of(context).pop,
                                icon: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14.r,
                                ), 
                                label: Text(
                                  "العودة لتسجيل الدخول",
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14.sp
                                  ),
                                )
                                ),
                            ),
                            SizedBox(height: 32.h,)
                          ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state is AuthError) {
      context.showErrorSnackBar(state.message);
    }
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2))
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
          color: AppColors.info,
          size: 22.r,
          ),
          SizedBox(width: 12.w,),
          Expanded(
            child: Text(
              'سيتم إرسال طلب استعادة الرمز للإدارة. '
              'سنتواصل معك عبر هاتفك المسجل.',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                height: 1.6,
                color: AppColors.info,
              ),
            ) 
          )
        ],
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  final String message;
  final VoidCallback onBackToLogin;

  const _SuccessView({required this.message, required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Container(
              width: 100.r,
              height: 100.r,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle_outline_rounded,
                size: 56.r,
                color: AppColors.success,
              ),
            ),
            SizedBox(height: 28.h),
            Text(
              "تم إرسال الطلب بنجاح",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                height: 1.6,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                children: [
                  _InstructionRow(
                    number: '١',
                    text: 'ستتلقى اتصالاً من فريق الدعم',
                  ),
                  SizedBox(height: 10.h),
                  _InstructionRow(
                    number: '٢',
                    text: 'سيتم التحقق من هويتك',
                  ),
                  SizedBox(height: 10.h),
                  _InstructionRow(
                    number: '٣',
                    text: 'ستحصل على رمز دخول جديد',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
