// Presentation - Customer registration screen.
//
// Multi-field form: name, phone, PIN (confirmed), security question
// + answer, and optional referral code. Uses AuthCubit.

import 'package:baladi/presentation/features/auth/widgets/security_question_field.dart';
import 'package:baladi/presentation/features/auth/widgets/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/validators.dart';
import '../../../common/widgets/app_button.dart';
import '../../../common/widgets/app_text_field.dart';
import '../../../cubits/auth/auth_cubit.dart';
import '../../../cubits/auth/auth_state.dart';

/// Customer registration with security question for PIN recovery.
class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() =>
      _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // ─── Controllers ──────────────────────────────────────────────
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _securityAnswerController = TextEditingController();
  final _referralController = TextEditingController();

  // ─── Focus Nodes ──────────────────────────────────────────────
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();
  final _securityAnswerFocus = FocusNode();
  final _referralFocus = FocusNode();

  // ─── State ────────────────────────────────────────────────────
  String? _selectedQuestion;
  Map<String, String>? _fieldErrors;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _securityAnswerController.dispose();
    _referralController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    _securityAnswerFocus.dispose();
    _referralFocus.dispose();
    super.dispose();
  }

  // ─── Validators ───────────────────────────────────────────────

  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تأكيد رمز الدخول مطلوب';
    }
    if (value.trim() != _pinController.text.trim()) {
      return 'رمز الدخول غير متطابق';
    }
    return null;
  }

  String? _validateOptionalReferral(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.validateReferralCode(value);
  }

  // ─── Actions ──────────────────────────────────────────────────

  void _handleRegister(BuildContext blocContext) {
    setState(() => _fieldErrors = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(blocContext).unfocus();

    final referral = _referralController.text.trim();

    blocContext.read<AuthCubit>().registerCustomer(
          fullName: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          pin: _pinController.text.trim(),
          // TODO: أضف securityQuestion و securityAnswer
          // في RegisterCustomerParams لما تعدّل الـ use case
          // securityQuestion: _selectedQuestion!,
          // securityAnswer: _securityAnswerController.text.trim(),
          referralCode: referral.isEmpty ? null : referral,
        );
  }

  // ─── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AuthCubit>(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: _onAuthStateChanged,
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            backgroundColor: AppColors.background,
            body: SingleChildScrollView(
              child: Column(
                children: [
                  const AuthHeader(
                    title: 'حساب جديد',
                    subtitle: 'أنشئ حسابك وابدأ الطلب',
                  ),
                  SizedBox(height: 28.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // ── 1. الاسم ───────────────
                          _SectionLabel(
                            icon: Icons.person_outlined,
                            label: 'البيانات الشخصية',
                          ),
                          SizedBox(height: 12.h),

                          AppTextField(
                            label: 'الاسم الكامل',
                            hint: 'أدخل اسمك الكامل',
                            controller: _nameController,
                            focusNode: _nameFocus,
                            prefixIcon: Icons.person_outlined,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: Validators.validateName,
                            errorText: _fieldErrors?['full_name'],
                            onFieldSubmitted: (_) =>
                                _phoneFocus.requestFocus(),
                          ),
                          SizedBox(height: 20.h),

                          // ── 2. الهاتف ──────────────
                          AppTextField.phone(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            validator: Validators.validatePhone,
                            errorText: _fieldErrors?['phone'],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _pinFocus.requestFocus(),
                          ),
                          SizedBox(height: 28.h),

                          // ── 3. رمز الدخول ──────────
                          _SectionLabel(
                            icon: Icons.lock_outlined,
                            label: 'الأمان',
                          ),
                          SizedBox(height: 12.h),

                          AppTextField.pin(
                            label: 'رمز الدخول',
                            controller: _pinController,
                            focusNode: _pinFocus,
                            validator: Validators.validatePin,
                            errorText: _fieldErrors?['pin'],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _confirmPinFocus.requestFocus(),
                          ),
                          SizedBox(height: 20.h),

                          // ── 4. تأكيد رمز الدخول ────
                          AppTextField.pin(
                            label: 'تأكيد رمز الدخول',
                            controller: _confirmPinController,
                            focusNode: _confirmPinFocus,
                            validator: _validateConfirmPin,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _securityAnswerFocus.requestFocus(),
                          ),
                          SizedBox(height: 28.h),

                          // ── 5. سؤال الأمان ─────────
                          _SectionLabel(
                            icon: Icons.shield_outlined,
                            label: 'سؤال الأمان',
                            subtitle: 'لاستعادة رمز الدخول لاحقاً',
                          ),
                          SizedBox(height: 12.h),

                          SecurityQuestionField(
                            selectedQuestion: _selectedQuestion,
                            onQuestionChanged: (q) =>
                                setState(() => _selectedQuestion = q),
                            answerController: _securityAnswerController,
                            answerFocusNode: _securityAnswerFocus,
                            answerTextInputAction: TextInputAction.next,
                            questionError:
                                _fieldErrors?['security_question'],
                            answerError:
                                _fieldErrors?['security_answer'],
                            onAnswerSubmitted: (_) =>
                                _referralFocus.requestFocus(),
                          ),
                          SizedBox(height: 28.h),

                          // ── 6. رمز الإحالة (اختياري)
                          _SectionLabel(
                            icon: Icons.card_giftcard_outlined,
                            label: 'رمز إحالة',
                            badge: 'اختياري',
                          ),
                          SizedBox(height: 12.h),

                          AppTextField(
                            label: 'رمز الإحالة',
                            hint: 'مثال: A3K9X2BF',
                            controller: _referralController,
                            focusNode: _referralFocus,
                            prefixIcon: Icons.card_giftcard_outlined,
                            maxLength: AppConstants.referralCodeLength,
                            textCapitalization:
                                TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            validator: _validateOptionalReferral,
                            errorText: _fieldErrors?['referral_code'],
                            onFieldSubmitted: (_) =>
                                _handleRegister(context),
                          ),
                          SizedBox(height: 32.h),

                          // ── زر التسجيل ─────────────
                          AppButton.primary(
                            text: 'إنشاء حساب',
                            onPressed: isLoading
                                ? null
                                : () => _handleRegister(context),
                            isLoading: isLoading,
                            leadingIcon: Icons.person_add_outlined,
                          ),
                          SizedBox(height: 24.h),

                          // ── رابط تسجيل الدخول ──────
                          _LoginLink(onTap: () => context.pop()),
                          SizedBox(height: 32.h),
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

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      context.goNamed(RouteNames.customerHome);
    } else if (state is AuthError) {
      if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
        setState(() => _fieldErrors = state.fieldErrors);
      } else {
        context.showErrorSnackBar(state.message);
      }
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
// ─── Private Widgets ─────────────────────────────────────────────
// ═══════════════════════════════════════════════════════════════════

/// Section label with icon, text, and optional subtitle or badge.
class _SectionLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final String? badge;

  const _SectionLabel({
    required this.icon,
    required this.label,
    this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18.r, color: AppColors.primary),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (badge != null) ...[
          SizedBox(width: 8.w),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              badge!,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
        if (subtitle != null) ...[
          const Spacer(),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.sp,
              color: AppColors.textHint,
            ),
          ),
        ],
      ],
    );
  }
}

/// "لديك حساب بالفعل؟ سجل الدخول" row.
class _LoginLink extends StatelessWidget {
  final VoidCallback onTap;
  const _LoginLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'لديك حساب بالفعل؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 6.w),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            'سجل الدخول',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}