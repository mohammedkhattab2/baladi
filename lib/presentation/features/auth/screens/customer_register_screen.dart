import 'package:baladi/core/constants/app_constants.dart';
import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
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
import 'package:go_router/go_router.dart';

class CustomerRegisterScreen extends StatefulWidget {
  const CustomerRegisterScreen({super.key});

  @override
  State<CustomerRegisterScreen> createState() => _CustomerRegisterScreenState();
}

class _CustomerRegisterScreenState extends State<CustomerRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _referralController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _pinFocus = FocusNode();
  final _confirmPinFocus = FocusNode();
  final _referralFocus = FocusNode();

  /// Server-side field errors from 422 responses.
  Map<String, String>? _fieldErrors;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _referralController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _pinFocus.dispose();
    _confirmPinFocus.dispose();
    _referralFocus.dispose();
    super.dispose();
  }

  // ─── Validators ─────────────────────────────────────────────────

  /// Client-side: must match [_pinController].
  String? _validateConfirmPin(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'تأكيد رمز الدخول مطلوب';
    }
    if (value.trim() != _pinController.text.trim()) {
      return 'رمز الدخول غير متطابق';
    }
    return null;
  }

  /// Only validates if a value was entered (optional field).
  String? _validateOptionalReferral(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return Validators.validateReferralCode(value);
  }

  // ─── Actions ────────────────────────────────────────────────────

  void _handleRegister(BuildContext blocContext) {
    setState(() => _fieldErrors = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(blocContext).unfocus();

    final referral = _referralController.text.trim();

    blocContext.read<AuthCubit>().registerCustomer(
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      pin: _pinController.text.trim(),
      referralCode: referral.isEmpty ? null : referral,
    );
  }

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
                          AppTextField(
                            label: 'الاسم الكامل',
                            hint: "أدخل اسمك الكامل",
                            controller: _nameController,
                            focusNode: _nameFocus,
                            prefixIcon: Icons.person_outline,
                            textCapitalization: TextCapitalization.words,
                            textInputAction: TextInputAction.next,
                            validator: Validators.validateName,
                            errorText: _fieldErrors?["full_name"],
                            onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
                          ),
                          SizedBox(height: 20.h),
                          AppTextField.phone(
                            controller: _phoneController,
                            focusNode: _phoneFocus,
                            validator: Validators.validatePhone,
                            errorText: _fieldErrors?["phone"],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) => _pinFocus.requestFocus(),
                          ),
                          SizedBox(height: 20.h),
                          AppTextField.pin(
                            label: "رمز الدخول",
                            controller: _pinController,
                            focusNode: _pinFocus,
                            validator: Validators.validatePin,
                            errorText: _fieldErrors?["pin"],
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _confirmPinFocus.requestFocus(),
                          ),
                          SizedBox(height: 20.h),
                          AppTextField.pin(
                            label: "تأكيد رمز الدخول",
                            controller: _confirmPinController,
                            focusNode: _confirmPinFocus,
                            validator: _validateConfirmPin,
                            textInputAction: TextInputAction.next,
                            onFieldSubmitted: (_) =>
                                _referralFocus.requestFocus(),
                          ),
                          SizedBox(height: 28.h),
                          const _ReferralSectionLabel(),
                          SizedBox(height: 12.h),
                          AppTextField(
                            label: "رمز إحالة",
                            hint: 'مثال: A3K9X2BF',
                            controller: _referralController,
                            focusNode: _referralFocus,
                            prefixIcon: Icons.card_giftcard_outlined,
                            maxLength: AppConstants.referralCodeLength,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            validator: _validateOptionalReferral,
                            errorText: _fieldErrors?["referral_code"],
                            helperText:
                                "'احصل على ${AppConstants.referralBonus} نقاط مكافأة',",
                            onFieldSubmitted: (_) => _handleRegister(context),
                          ),
                          SizedBox(height: 32.h),
                          AppButton.primary(
                            text: "إنشاء حساب",
                            onPressed: isLoading
                                ? null
                                : () => _handleRegister(context),
                            isLoading: isLoading,
                            leadingIcon: Icons.person_add_outlined,
                          ),
                          SizedBox(height: 24.h),
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

class _LoginLink extends StatelessWidget {
  final VoidCallback onTap;
  const _LoginLink({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "لديك حساب بالفعل؟",
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
            tapTargetSize: MaterialTapTargetSize.shrinkWrap
          ), 
          child: Text(
            "سجل الدخول",
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          )
          )
      ],
    );
  }
}

class _ReferralSectionLabel extends StatelessWidget {
  const _ReferralSectionLabel();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.card_giftcard_outlined,
          size: 18.r,
          color: AppColors.secondary,
        ),
        SizedBox(width: 8.w),
        Text(
          "رمز إحالة",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.secondary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            "اختياري",
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.secondary,
            ),
          ),
        ),
      ],
    );
  }
}
