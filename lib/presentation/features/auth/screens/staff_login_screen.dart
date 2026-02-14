import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/extensions.dart';
import 'package:baladi/domain/enums/user_role.dart';
import 'package:baladi/presentation/common/widgets/app_button.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart';
import 'package:baladi/presentation/cubits/auth/auth_state.dart';
import 'package:baladi/presentation/features/auth/widgets/auth_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class StaffLoginScreen extends StatefulWidget {
  const StaffLoginScreen({super.key});

  @override
  State<StaffLoginScreen> createState() => _StaffLoginScreenState();
}

class _StaffLoginScreenState extends State<StaffLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameFocus = FocusNode();
  final _passwordFocus = FocusNode();

  /// Currently selected staff role.
  UserRole _selectedRole = UserRole.shop;

  /// Server-side field errors.
  Map<String, String>? _fieldErrors;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _usernameFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  // ─── Validators ───────────────────────────────────────────────

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'اسم المستخدم مطلوب';
    }
    if (value.trim().length < 3) {
      return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    if (value.trim().length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    return null;
  }

  // ─── Actions ──────────────────────────────────────────────────

  void _handleLogin(BuildContext blocContext) {
    setState(() => _fieldErrors = null);
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(blocContext).unfocus();

    blocContext.read<AuthCubit>().loginUser(
      username: _usernameController.text.trim(),
      password: _passwordController.text.trim(),
      role: _selectedRole,
    );
  }

  /// Navigates to the correct dashboard based on [role].
  void _navigateToDashboard(BuildContext context, UserRole role) {
    final routeName = switch (role) {
      UserRole.shop => RouteNames.shopDashboard,
      UserRole.rider => RouteNames.riderDashboard,
      UserRole.admin => RouteNames.adminDashboard,
      _ => RouteNames.welcome,
    };
    context.goNamed(routeName);
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
                    title: 'فريق العمل',
                    subtitle: "سجل دخولك للوحة التحكم",
                  ),
                  SizedBox(height: 28.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _RoleSelectorSection(
                            selectedRole: _selectedRole,
                            onRoleChanged: (role) =>
                                setState(() => _selectedRole = role),
                          ),
                          SizedBox(height: 28.h,),
                          AppTextField(
                            label: 'اسم المستخدم',
                            hint: 'أدخل اسم المستخدم',
                            controller: _usernameController,
                            focusNode: _usernameFocus,
                            prefixIcon: Icons.person_outline,
                            textInputAction: TextInputAction.next,
                            validator: _validateUsername,
                            errorText: _fieldErrors?['username'],
                            onFieldSubmitted: (_) =>
                                _passwordFocus.requestFocus(),
                          ),
                          SizedBox(height: 20.h,),
                          AppTextField(
                            label: 'كلمة المرور',
                            hint: 'أدخل كلمة المرور',
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            prefixIcon: Icons.lock_outline,
                            obscureText: true,
                            textInputAction: TextInputAction.done,
                            validator: _validatePassword,
                            errorText: _fieldErrors?['password'],
                            onFieldSubmitted: (_) => _handleLogin(context),
                          ),
                          SizedBox(height: 32.h,),
                          AppButton.primary(
                            text: "تسجيل الدخول",
                            onPressed: isLoading
                            ? null
                            : () => _handleLogin(context),
                            leadingIcon: Icons.login_rounded, 
                          ),
                          SizedBox(height: 24.h,),
                          Center(
                            child: TextButton.icon(
                              onPressed: ()=> Navigator.of(context).pop(),
                              icon: Icon(
                                Icons.arrow_back_ios_new_rounded, 
                                size: 14.r
                              ), 
                              label: Text(
                                "العودة للصفحة الرئيسية",
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14.sp,
                                  
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

  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is AuthAuthenticated) {
      _navigateToDashboard(context, state.role);
    } else if (state is AuthError) {
      if (state.fieldErrors != null && state.fieldErrors!.isNotEmpty) {
        setState(() => _fieldErrors = state.fieldErrors);
      } else {
        context.showErrorSnackBar(state.message);
      }
    }
  }
}

class _RoleSelectorSection extends StatelessWidget {
  final UserRole selectedRole;
  final ValueChanged<UserRole> onRoleChanged;
  const _RoleSelectorSection({
    required this.selectedRole,
    required this.onRoleChanged,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.group_outlined, size: 18.r, color: AppColors.primary),
            SizedBox(width: 8.w),
            Text(
              'اختر نوع الحساب',
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
        Row(
          children: [
            Expanded(
              child: _RoleChip(
                icon: Icons.storefront_outlined,
                label: 'متجر',
                isSelected: selectedRole == UserRole.shop,
                onTap: () => onRoleChanged(UserRole.shop),
              ),
            ),
            SizedBox(width: 10.w,),
            Expanded(
              child:_RoleChip(
                icon: Icons.delivery_dining_outlined, 
                label: "سائق توصيل", 
                isSelected: selectedRole == UserRole.rider, 
                onTap: ()=> onRoleChanged(UserRole.rider),
                ) 
            ),
            SizedBox(width: 10.w,),
            Expanded(
              child: _RoleChip(
                icon: Icons.admin_panel_settings_outlined,
                label: "مدير",
                isSelected: selectedRole == UserRole.admin,
                onTap: ()=> onRoleChanged(UserRole.admin),
              ) 
            )
          ],
        ),
      ],
    );
  }
}

class _RoleChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isSelected ? AppColors.primary : AppColors.surfaceVariant;
    final fgColor = isSelected
        ? AppColors.textOnPrimary
        : AppColors.textSecondary;
    final borderColor = isSelected ? AppColors.primary : AppColors.border;

    return Material(
      color:  bgColor,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child:  Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border:  Border.all(
              color: borderColor,
              width: isSelected ? 2 : 1 ,
            )
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: fgColor, size: 28.r,),
              SizedBox(height: 8.h,),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 13.sp,
                  fontWeight: 
                       isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: fgColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
      
  }
}
