import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/user.dart';
import 'package:baladi/domain/enums/user_role.dart';
import 'package:baladi/domain/repositories/auth_repository.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_state.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadUsers(),
      child: const _AdminUsersView(),
    );
  }
}

class _AdminUsersView extends StatefulWidget {
  const _AdminUsersView();

  @override
  State<_AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends State<_AdminUsersView> {
  String? _selectedRole;
  bool? _activeFilter; // null = كل الحالات، true = نشط فقط، false = معطّل فقط
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminCubit>().state;
      if (state is AdminUsersLoaded && state.hasMore) {
        context.read<AdminCubit>().loadMoreUsers(role: _selectedRole);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'إدارة المستخدمين',
      currentRoute: RouteNames.adminUsers,
      child: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (state is AdminUserPasswordReset) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message ?? 'تم إعادة تعيين كلمة المرور بنجاح',
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminLoading) {
                  return const Center(child: LoadingWidget());
                }
                if (state is AdminError) {
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => _loadUser(),
                  );
                }
                if (state is AdminUsersLoaded) {
                  return _buildUsersList(state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchField(
            controller: _searchController,
            hint: "بحث بالاسم أو رقم الهاتف...",
            onChanged: (value) {
              setState(() {
                _searchQuery = value.trim();
              });
            },
          ),
          SizedBox(height: 12.h),
          // فلترة حسب الدور
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'الكل',
                  isSelected: _selectedRole == null,
                  onTap: () => _onRoleFilter(null),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'العملاء',
                  isSelected: _selectedRole == 'customer',
                  onTap: () => _onRoleFilter('customer'),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'المحلات',
                  isSelected: _selectedRole == 'shop',
                  onTap: () => _onRoleFilter('shop'),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'السائقين',
                  isSelected: _selectedRole == 'rider',
                  onTap: () => _onRoleFilter('rider'),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'المديرين',
                  isSelected: _selectedRole == 'admin',
                  onTap: () => _onRoleFilter('admin'),
                ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          // فلترة حسب حالة الحساب (نشط / معطّل)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'كل الحالات',
                  isSelected: _activeFilter == null,
                  onTap: () => _onStatusFilter(null),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'الحسابات النشطة',
                  isSelected: _activeFilter == true,
                  onTap: () => _onStatusFilter(true),
                ),
                SizedBox(width: 8.w),
                _FilterChip(
                  label: 'الحسابات المعطّلة',
                  isSelected: _activeFilter == false,
                  onTap: () => _onStatusFilter(false),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onRoleFilter(String? role) {
    setState(() => _selectedRole = role);
    _loadUser();
  }

  void _onStatusFilter(bool? isActive) {
    // فلترة محلية فقط على القائمة المحمّلة من الـ API
    setState(() {
      _activeFilter = isActive;
    });
  }

  void _loadUser() {
    context.read<AdminCubit>().loadUsers(role: _selectedRole);
  }

  Widget _buildUsersList(AdminUsersLoaded state) {
    // تطبيق فلترة البحث المحلية + حالة الحساب على النتيجة القادمة من الـ API
    final filteredUsers = state.users.where((user) {
      // فلترة بالحالة (نشط/معطل) لو فيه فلتر محدد
      if (_activeFilter != null && user.isActive != _activeFilter) {
        return false;
      }

      // فلترة بالبحث المحلي على اسم المستخدم أو رقم الهاتف أو الـ displayIdentifier
      if (_searchQuery.isEmpty) return true;
      final query = _searchQuery.toLowerCase();
      final parts = [
        user.username ?? '',
        user.phone ?? '',
        user.displayIdentifier,
      ].join(' ').toLowerCase();
      return parts.contains(query);
    }).toList();

    if (filteredUsers.isEmpty) {
      return const AppEmptyState(
        icon: Icons.people_outline,
        title: 'لا يوجد مستخدمين',
        description: 'لم يتم العثور على مستخدمين بهذه المعايير',
      );
    }

    return RefreshIndicator(
      onRefresh: () async => _loadUser(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: filteredUsers.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredUsers.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final user = filteredUsers[index];
          return _UseCard(
            user: user,
            onToggleStatus: () => _showToggleDialog(user),
            onViewDetails: () => _showUserDetails(user),
          );
        },
      ),
    );
  }

  Future<void> _showResetPasswordDialog(User user) async {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'إعادة تعيين كلمة المرور',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'سيتم تعيين كلمة مرور جديدة لحساب ${_getUserDisplayName(user)}.\n'
                  'يجب أن تحتوي كلمة المرور على 8 أحرف على الأقل، وحرف كبير، وحرف صغير، ورقم.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                AppTextField(
                  controller: controller,
                  label: 'كلمة المرور الجديدة',
                  obscureText: true,
                  validator: (value) {
                    final password = value?.trim() ?? '';
                    if (password.isEmpty) {
                      return 'من فضلك أدخل كلمة المرور الجديدة';
                    }
                    if (password.length < 8) {
                      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                    }
                    final hasUpper = password.contains(RegExp(r'[A-Z]'));
                    final hasLower = password.contains(RegExp(r'[a-z]'));
                    final hasDigit = password.contains(RegExp(r'\d'));
                    if (!hasUpper || !hasLower || !hasDigit) {
                      return 'يجب أن تحتوي على حرف كبير، حرف صغير، ورقم';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }
                final password = controller.text.trim();
                Navigator.of(ctx).pop();
                await context.read<AdminCubit>().resetUserPassword(
                      userId: user.id,
                      newPassword: password,
                    );
              },
              child: Text(
                'تأكيد',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetCustomerPinDialog(User user) async {
    final phone = user.phone;
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('لا يوجد رقم هاتف مسجّل لهذا العميل'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final authRepository = getIt<AuthRepository>();

    // Step 1: fetch security question for this phone
    final questionResult =
        await authRepository.getSecurityQuestion(phone: phone);

    String? securityQuestion;
    questionResult.fold(
      onSuccess: (q) => securityQuestion = q,
      onFailure: (failure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(failure.message),
            backgroundColor: AppColors.error,
          ),
        );
      },
    );

    if (securityQuestion == null) {
      return;
    }

    final answerController = TextEditingController();
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'إعادة تعيين رمز الدخول للعميل',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'سيتم تعيين PIN جديد لحساب ${_getUserDisplayName(user)}.\n'
                    'تأكّد أن لديك موافقة العميل وأنك أدخلت الإجابة الصحيحة للسؤال السري.',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'رقم الهاتف',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    Formatters.formatPhone(phone),
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    'السؤال السري',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    securityQuestion!,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    controller: answerController,
                    label: 'إجابة السؤال السري',
                    validator: (value) {
                      final answer = value?.trim() ?? '';
                      if (answer.isEmpty) {
                        return 'من فضلك أدخل إجابة السؤال السري';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 12.h),
                  AppTextField(
                    controller: pinController,
                    label: 'الـ PIN الجديد (4 أرقام)',
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      final pin = value?.trim() ?? '';
                      if (pin.isEmpty) {
                        return 'من فضلك أدخل الـ PIN الجديد';
                      }
                      if (pin.length != 4 || int.tryParse(pin) == null) {
                        return 'الـ PIN يجب أن يكون 4 أرقام';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) {
                  return;
                }

                final answer = answerController.text.trim();
                final newPin = pinController.text.trim();

                Navigator.of(ctx).pop();

                final resetResult = await authRepository.resetPin(
                  phone: phone,
                  securityAnswer: answer,
                  newPin: newPin,
                );

                resetResult.fold(
                  onSuccess: (_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'تم إعادة تعيين رمز الدخول (PIN) بنجاح'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  },
                  onFailure: (failure) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(failure.message),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  },
                );
              },
              child: Text(
                'تأكيد',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUserDetails(User user) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.all(24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    children: [
                      Container(
                        width: 56.r,
                        height: 56.r,
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        child: Icon(
                          _getRoleIcon(user.role),
                          color: _getRoleColor(user.role),
                          size: 28.r,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getUserDisplayName(user),
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.h),
                            Row(
                              children: [
                                _RoleBadge(role: user.role),
                                SizedBox(width: 8.w),
                                _StatusBadge(isActive: user.isActive),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  _UserDetailRow(
                    label: 'المعرف',
                    value: user.id,
                  ),
                  if (user.phone != null && user.phone!.isNotEmpty) ...[
                    _UserDetailRow(
                      label: 'رقم الهاتف',
                      value: Formatters.formatPhone(user.phone!),
                    ),
                  ],
                  if (user.username != null && user.username!.isNotEmpty) ...[
                    _UserDetailRow(
                      label: 'اسم المستخدم',
                      value: user.username!,
                    ),
                  ],
                  _UserDetailRow(
                    label: 'تاريخ التسجيل',
                    value: Formatters.formatDate(user.createdAt),
                  ),
                  _UserDetailRow(
                    label: 'آخر تحديث',
                    value: Formatters.formatDateTime(user.updatedAt),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showToggleDialog(User user) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          user.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          user.isActive
              ? 'هل تريد تعطيل حساب ${_getUserDisplayName(user)}؟'
              : 'هل تريد تفعيل حساب ${_getUserDisplayName(user)}؟',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 14.sp,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              "إلغاء",
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AdminCubit>().toggleUserStatus(
                userId: user.id,
                isActive: !user.isActive,
                role: _selectedRole,
              );
            },
            child: Text(
              user.isActive ? 'تعطيل' : 'تفعيل',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                color: user.isActive ? AppColors.error : AppColors.success,
                fontWeight: FontWeight.w600,
              )
            ),
          ),
        ],
      ),
    );
  }
}

class _UseCard extends StatelessWidget {
  final User user;
  final VoidCallback onToggleStatus;
  final VoidCallback onViewDetails;

  const _UseCard({
    required this.user,
    required this.onToggleStatus,
    required this.onViewDetails,
  });
  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      borderColor: user.isActive? null : AppColors.error,
      onTap: onViewDetails,
      child:  Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha:  0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getRoleIcon(user.role),
              color: _getRoleColor(user.role),
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w,),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getUserDisplayName(user),
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary
                        ),
                        overflow: TextOverflow.ellipsis,
                      ) 
                    ),
                    _StatusBadge(isActive: user.isActive),
                  ],
                ),
                SizedBox(height: 4.h,),
                Row(
                  children: [
                    _RoleBadge(role: user.role),
                    SizedBox(width: 8.w,),
                    Expanded(
                      child: Text(
                        'انضم ${Formatters.formatRelativeTime(user.createdAt)}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ) 
                    )
                  ],
                )
              ],
            ) 
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppColors.textSecondary,
              size: 20.r,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r)
            ),
            onSelected: (value) async {
              if (value == 'toggle') {
                onToggleStatus();
              } else if (value == 'reset_password') {
                // Delegate to the parent stateful widget via context
                final state =
                    context.findAncestorStateOfType<_AdminUsersViewState>();
                if (state != null) {
                  await state._showResetPasswordDialog(user);
                }
              } else if (value == 'reset_pin') {
                final state =
                    context.findAncestorStateOfType<_AdminUsersViewState>();
                if (state != null) {
                  await state._showResetCustomerPinDialog(user);
                }
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: "toggle",
                child: Row(
                  children: [
                    Icon(
                      user.isActive ? Icons.block : Icons.check_circle,
                      size: 18.r,
                      color: user.isActive ? AppColors.error : AppColors.success,
                    ),
                    SizedBox(width: 8.w,),
                    Text(
                      user.isActive ? "تعطيل الحساب" : "تفعيل الحساب",
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                      ),
                    )
                  ],
                ),
              ),
              if (user.role != UserRole.customer)
                PopupMenuItem(
                  value: "reset_password",
                  child: Row(
                    children: [
                      Icon(
                        Icons.lock_reset,
                        size: 18.r,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w,),
                      Text(
                        "إعادة تعيين كلمة المرور",
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                        ),
                      )
                    ],
                  ),
                ),
              if (user.role == UserRole.customer)
                PopupMenuItem(
                  value: "reset_pin",
                  child: Row(
                    children: [
                      Icon(
                        Icons.pin,
                        size: 18.r,
                        color: AppColors.info,
                      ),
                      SizedBox(width: 8.w,),
                      Text(
                        "إعادة تعيين رمز الدخول (PIN)",
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                        ),
                      )
                    ],
                  ),
                ),
            ],
          )
        ],

      )
    );
  }
}

String _getUserDisplayName(User user) {
  // فضّل اسم المستخدم إن وُجد، ثم رقم الهاتف، وإلا fallback للمعرّف الحالي
  if (user.username != null && user.username!.trim().isNotEmpty) {
    return user.username!.trim();
  }
  if (user.phone != null && user.phone!.trim().isNotEmpty) {
    return Formatters.formatPhone(user.phone!.trim());
  }
  return user.displayIdentifier;
}

Color _getRoleColor(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return AppColors.primary;
    case UserRole.shop:
      return AppColors.secondary;
    case UserRole.rider:
      return AppColors.info;
    case UserRole.admin:
      return Colors.purple;
  }
}

IconData _getRoleIcon(UserRole role) {
  switch (role) {
    case UserRole.customer:
      return Icons.person;
    case UserRole.shop:
      return Icons.storefront;
    case UserRole.rider:
      return Icons.delivery_dining;
    case UserRole.admin:
      return Icons.admin_panel_settings;
  }
}

class _UserDetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _UserDetailRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110.w,
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
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  final UserRole role;

  const _RoleBadge({required this.role});
   @override
   Widget build(BuildContext context) {
     return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: _getColor().withValues(alpha:  0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        role.labelAr,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: _getColor()
        ),
      ),
     );
   }
   
   Color  _getColor() {
    switch (role) {
      case UserRole.customer:
        return AppColors.primary;
      case UserRole.shop:
        return AppColors.secondary;
      case UserRole.rider:
        return AppColors.info;
      case UserRole.admin:
        return Colors.purple;
    }
  }
   }


class _StatusBadge extends StatelessWidget {
  final bool isActive;

  const _StatusBadge({required this.isActive});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4.r)
      ),
      child: Text(
        isActive ?'نشط' : 'معطل',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: isActive ? AppColors.success : AppColors.error,
        ),
      ),
    );
  }

  
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: isSelected ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}
