// Presentation - PIN recovery screen (multi-step).
//
// Step 1: Enter phone → backend returns security question.
// Step 2: Answer question + set new PIN → backend verifies & resets.
// Step 3: Success confirmation.

import 'package:baladi/presentation/features/auth/widgets/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../cubits/auth/auth_state.dart';


/// Multi-step PIN recovery screen.
///
/// Flow: Phone → Security Question → New PIN → Success.
class PinRecoveryScreen extends StatefulWidget {
  const PinRecoveryScreen({super.key});

  @override
  State<PinRecoveryScreen> createState() => _PinRecoveryScreenState();
}

class _PinRecoveryScreenState extends State<PinRecoveryScreen> {
  // ─── Step Tracking ────────────────────────────────────────────
  // 0 = phone, 1 = answer + new pin, 2 = success
  int _currentStep = 0;

  // ─── Form Keys ────────────────────────────────────────────────
  final _phoneFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────────
  final _phoneController = TextEditingController();
  final _answerController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  // ─── Focus Nodes ──────────────────────────────────────────────
  final _phoneFocus = FocusNode();
  final _answerFocus = FocusNode();
  final _newPinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();

  // ─── Recovery Data ────────────────────────────────────────────
  String _phone = '';
  String _securityQuestion = '';

  @override
  void dispose() {
    _phoneController.dispose();
    _answerController.dispose();
    _newPinController.dispose();
    _confirmPinController.dispose();
    _phoneFocus.dispose();
    _answerFocus.dispose();
    _newPinFocus.dispose();
    _confirmPinFocus.dispose();
    super.dispose();
  }

  // ─── Validators ───────────────────────────────────────────────

  String? _validateAnswer(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'إجابة سؤال الأمان مطلوبة';
    }
    return null;
  }

  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تأكيد رمز الدخول مطلوب';
    }
    if (value.trim() != _newPinController.text.trim()) {
      return 'رمز الدخول غير متطابق';
    }
    return null;
  }

  // ─── Actions ──────────────────────────────────────────────────

  void _submitPhone(BuildContext blocContext) {
    if (!_phoneFormKey.currentState!.validate()) return;
    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().verifyPhoneForRecovery(
          phone: _phoneController.text.trim(),
        );
  }

  void _submitReset(BuildContext blocContext) {
    if (!_resetFormKey.currentState!.validate()) return;
    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().resetPin(
          phone: _phone,
          securityAnswer: _answerController.text.trim(),
          newPin: _newPinController.text.trim(),
        );
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onStateChanged,
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  // ─── Header (يتغير حسب الخطوة) ──────
                  AuthHeader(
                    title: _headerTitle,
                    subtitle: _headerSubtitle,
                    showBackButton: _currentStep < 2,
                  ),
                  SizedBox(height: 24.h),

                  // ─── Step Indicator ──────────────────
                  if (_currentStep < 2)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: _StepIndicator(
                        currentStep: _currentStep,
                        totalSteps: 2,
                      ),
                    ),
                  SizedBox(height: 24.h),

                  // ─── Step Content ───────────────────
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: _currentStep == 0
                        ? _PhoneStep(
                            formKey: _phoneFormKey,
                            phoneController: _phoneController,
                            phoneFocus: _phoneFocus,
                            isLoading: isLoading,
                            onSubmit: () => _submitPhone(context),
                            onBack: () => Navigator.of(context).pop(),
                          )
                        : _currentStep == 1
                            ? _ResetStep(
                                formKey: _resetFormKey,
                                securityQuestion: _securityQuestion,
                                answerController: _answerController,
                                answerFocus: _answerFocus,
                                newPinController: _newPinController,
                                newPinFocus: _newPinFocus,
                                confirmPinController:
                                    _confirmPinController,
                                confirmPinFocus: _confirmPinFocus,
                                validateAnswer: _validateAnswer,
                                validateConfirmPin: _validateConfirmPin,
                                isLoading: isLoading,
                                onSubmit: () => _submitReset(context),
                                onBack: () =>
                                    setState(() => _currentStep = 0),
                              )
                            : _SuccessStep(
                                onBackToLogin: () =>
                                    Navigator.of(context).pop(),
                              ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─── Header Text ──────────────────────────────────────────────

  String get _headerTitle => switch (_currentStep) {
        0 => 'استعادة رمز الدخول',
        1 => 'التحقق من الهوية',
        _ => 'تم بنجاح!',
      };

  String get _headerSubtitle => switch (_currentStep) {
        0 => 'أدخل رقم هاتفك المسجل',
        1 => 'أجب على سؤال الأمان وأدخل رمز جديد',
        _ => 'تم تغيير رمز الدخول',
      };

  // ─── State Listener ───────────────────────────────────────────

  void _onStateChanged(BuildContext context, AuthState state) {
    if (state is AuthRecoveryQuestionLoaded) {
      setState(() {
        _phone = state.phone;
        _securityQuestion = state.securityQuestion;
        _currentStep = 1;
      });
    } else if (state is AuthPinResetSuccess) {
      setState(() => _currentStep = 2);
    } else if (state is AuthError) {
      context.showErrorSnackBar(state.message);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// ─── Step Widgets ────────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════

/// Visual step indicator: ● ─── ○
class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps * 2 - 1, (index) {
        // Even indices = dots, odd indices = lines
        if (index.isOdd) {
          // Line connector
          return Expanded(
            child: Container(
              height: 2.h,
              color: (index ~/ 2) < currentStep
                  ? AppColors.primary
                  : AppColors.border,
            ),
          );
        }
        // Dot
        final stepIndex = index ~/ 2;
        final isActive = stepIndex <= currentStep;

        return Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primary
                : AppColors.surfaceVariant,
            shape: BoxShape.circle,
            border: isActive
                ? null
                : Border.all(color: AppColors.border),
          ),
          alignment: Alignment.center,
          child: Text(
            '${stepIndex + 1}',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: isActive
                  ? AppColors.textOnPrimary
                  : AppColors.textHint,
            ),
          ),
        );
      }),
    );
  }
}

// ─── Step 1: Phone ──────────────────────────────────────────────

class _PhoneStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _PhoneStep({
    required this.formKey,
    required this.phoneController,
    required this.phoneFocus,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Info Banner ──────────────────────
          _InfoBanner(
            icon: Icons.phone_outlined,
            text: 'أدخل رقم الهاتف المسجل به حسابك '
                'وسنعرض لك سؤال الأمان.',
          ),
          SizedBox(height: 28.h),

          AppTextField.phone(
            controller: phoneController,
            focusNode: phoneFocus,
            validator: Validators.validatePhone,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          SizedBox(height: 32.h),

          AppButton.primary(
            text: 'التالي',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
            trailingIcon: Icons.chevron_left,
          ),
          SizedBox(height: 12.h),

          Center(
            child: TextButton.icon(
              onPressed: onBack,
              icon: Icon(Icons.arrow_forward_ios, size: 14.r),
              label: Text(
                'العودة لتسجيل الدخول',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Answer + New PIN ───────────────────────────────────

class _ResetStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final String securityQuestion;
  final TextEditingController answerController;
  final FocusNode answerFocus;
  final TextEditingController newPinController;
  final FocusNode newPinFocus;
  final TextEditingController confirmPinController;
  final FocusNode confirmPinFocus;
  final String? Function(String?) validateAnswer;
  final String? Function(String?) validateConfirmPin;
  final bool isLoading;
  final VoidCallback onSubmit;
  final VoidCallback onBack;

  const _ResetStep({
    required this.formKey,
    required this.securityQuestion,
    required this.answerController,
    required this.answerFocus,
    required this.newPinController,
    required this.newPinFocus,
    required this.confirmPinController,
    required this.confirmPinFocus,
    required this.validateAnswer,
    required this.validateConfirmPin,
    required this.isLoading,
    required this.onSubmit,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Security Question Display ────────
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.help_outline_rounded,
                  color: AppColors.primary,
                  size: 22.r,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'سؤال الأمان',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        securityQuestion,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),

          // ── Answer Field ────────────────────
          AppTextField(
            label: 'إجابتك',
            hint: 'أدخل إجابة سؤال الأمان',
            controller: answerController,
            focusNode: answerFocus,
            prefixIcon: Icons.key_outlined,
            textInputAction: TextInputAction.next,
            validator: validateAnswer,
            onFieldSubmitted: (_) => newPinFocus.requestFocus(),
          ),
          SizedBox(height: 24.h),

          // ── New PIN Section ─────────────────
          Row(
            children: [
              Icon(Icons.lock_reset_outlined,
                  size: 18.r, color: AppColors.primary),
              SizedBox(width: 8.w),
              Text(
                'رمز الدخول الجديد',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          AppTextField.pin(
            label: 'رمز الدخول الجديد',
            controller: newPinController,
            focusNode: newPinFocus,
            validator: Validators.validatePin,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) => confirmPinFocus.requestFocus(),
          ),
          SizedBox(height: 20.h),

          AppTextField.pin(
            label: 'تأكيد رمز الدخول',
            controller: confirmPinController,
            focusNode: confirmPinFocus,
            validator: validateConfirmPin,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => onSubmit(),
          ),
          SizedBox(height: 32.h),

          // ── Submit Button ───────────────────
          AppButton.primary(
            text: 'تغيير رمز الدخول',
            onPressed: isLoading ? null : onSubmit,
            isLoading: isLoading,
            leadingIcon: Icons.lock_reset_outlined,
          ),
          SizedBox(height: 12.h),

          // ── Back to Step 1 ──────────────────
          Center(
            child: TextButton.icon(
              onPressed: onBack,
              icon: Icon(Icons.arrow_forward_ios, size: 14.r),
              label: Text(
                'تغيير رقم الهاتف',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Success ────────────────────────────────────────────

class _SuccessStep extends StatelessWidget {
  final VoidCallback onBackToLogin;
  const _SuccessStep({required this.onBackToLogin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 24.h),

        // ── Success Icon ──────────────────────
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
          'تم تغيير رمز الدخول بنجاح',
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
          'يمكنك الآن تسجيل الدخول\nبرمز الدخول الجديد',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            height: 1.6,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 40.h),

        AppButton.primary(
          text: 'تسجيل الدخول',
          onPressed: onBackToLogin,
          leadingIcon: Icons.login_rounded,
        ),
      ],
    );
  }
}

// ─── Shared ─────────────────────────────────────────────────────

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoBanner({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.info, size: 22.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 13.sp,
                height: 1.6,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}