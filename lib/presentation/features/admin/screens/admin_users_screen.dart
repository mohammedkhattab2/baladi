import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/user.dart';
import 'package:baladi/domain/entities/shop.dart';
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
  AdminUsersLoaded? _lastUsersState; // Store the last users state

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
      child: Container(
        decoration: const BoxDecoration(
          // نفس الجريدينت العميق المستخدم في لوحة التحكم الرئيسية
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A),
              Color(0xFF1B263B),
              Color(0xFF2D5A27),
              Color(0xFF1A3A16),
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Glow Orbs في الخلفية عشان نفس العالم البصري للـ Admin
            Positioned(
              top: -70,
              left: -30,
              child: _GlowOrb(
                size: 160,
                color: AppColors.primary,
                opacity: 0.22,
              ),
            ),
            Positioned(
              bottom: -60,
              right: -40,
              child: _GlowOrb(
                size: 150,
                color: AppColors.secondary,
                opacity: 0.20,
              ),
            ),
            // المحتوى الرئيسي
            SafeArea(
              child: Column(
                children: [
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: const _UsersHeaderCard(),
                  ),
                  SizedBox(height: 16.h),
                  // فلاتر داخل كارت نصف شفاف فوق الخلفية الداكنة
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: _buildFilters(),
                  ),
                  SizedBox(height: 8.h),
                  Expanded(
                    child: BlocConsumer<AdminCubit, AdminState>(
                      // Only listen for temporary states (errors and success messages)
                      listenWhen: (previous, current) =>
                        current is AdminError || current is AdminUserPasswordReset,
                      listener: (context, state) {
                        if (state is AdminError) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16.r),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              backgroundColor: AppColors.error,
                              content: Text(
                                state.message,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                            ),
                          );
                        } else if (state is AdminUserPasswordReset) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              behavior: SnackBarBehavior.floating,
                              margin: EdgeInsets.all(16.r),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              backgroundColor: AppColors.success,
                              content: Text(
                                state.message ??
                                    'تم إعادة تعيين كلمة المرور بنجاح',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                      // Only rebuild for states that actually affect the UI
                      buildWhen: (previous, current) {
                        // Save the users state when we get it
                        if (current is AdminUsersLoaded) {
                          _lastUsersState = current;
                          return true;
                        }
                        // Only rebuild for loading state or error when we don't have users
                        return current is AdminLoading ||
                               (current is AdminError && _lastUsersState == null);
                      },
                      builder: (context, state) {
                        if (state is AdminLoading && _lastUsersState == null) {
                          return const Center(child: LoadingWidget());
                        }
                        
                        // Show error screen only if we don't have any loaded users
                        if (state is AdminError && _lastUsersState == null) {
                          return Center(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: 520.w),
                              child: AppErrorWidget(
                                message: state.message,
                                onRetry: () => _loadUser(),
                              ),
                            ),
                          );
                        }
                        
                        // Always show the last users state if available
                        if (_lastUsersState != null) {
                          return _buildUsersList(_lastUsersState!);
                        }
                        
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.04),
          ],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.30),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchField(
            controller: _searchController,
            hint: "بحث بالاسم أو رقم الهاتف...",
            // نفس ستايل البحث في عالم الـ Admin الداكن
            backgroundColor: Colors.white.withValues(alpha: 0.12),
            textColor: Colors.white,
            iconColor: Colors.white70,
            hintColor: Colors.white60,
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
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A2332),
                  Color(0xFF0F1720),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.info.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.info,
                              AppColors.info.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.lock_reset_rounded,
                          color: Colors.white,
                          size: 36.r,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'إعادة تعيين كلمة المرور',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info badge
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _getRoleIcon(user.role),
                                color: _getRoleColor(user.role),
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _getUserDisplayName(user),
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        // Password requirements info
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.warning,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'متطلبات كلمة المرور:',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    _buildRequirement('8 أحرف على الأقل'),
                                    _buildRequirement('حرف كبير واحد على الأقل'),
                                    _buildRequirement('حرف صغير واحد على الأقل'),
                                    _buildRequirement('رقم واحد على الأقل'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        // Password field with modern styling
                        AppTextField(
                          controller: controller,
                          label: 'كلمة المرور الجديدة',
                          hint: '••••••••',
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
                ),
                
                SizedBox(height: 24.h),
                
                // Actions
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
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
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.info,
                                    AppColors.info.withValues(alpha: 0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.info.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.lock_reset_rounded,
                                      color: Colors.white,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'تأكيد التغيير',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _showResetCustomerPinDialog(User user) async {
    final pinController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            constraints: BoxConstraints(maxWidth: 400.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24.r),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A2332),
                  Color(0xFF0F1720),
                ],
              ),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
                BoxShadow(
                  color: AppColors.info.withValues(alpha: 0.2),
                  blurRadius: 40,
                  offset: const Offset(0, 20),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with icon
                Container(
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.info.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.info,
                              AppColors.info.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.info.withValues(alpha: 0.4),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.pin_rounded,
                          color: Colors.white,
                          size: 36.r,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'إعادة تعيين رمز الدخول',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Content
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // User info badge
                        Container(
                          padding: EdgeInsets.all(12.r),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.person_rounded,
                                color: AppColors.primary,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _getUserDisplayName(user),
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        // PIN requirements info
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.warning,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'رمز الدخول الجديد:',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    _buildRequirement('يجب أن يكون 4 أرقام فقط'),
                                    _buildRequirement('لا يمكن استخدام أحرف أو رموز'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                        
                        // PIN field with modern styling
                        AppTextField(
                          controller: pinController,
                          label: 'رمز الدخول الجديد',
                          hint: '••••',
                          keyboardType: TextInputType.number,
                          obscureText: true,
                          maxLength: 4,
                          textAlign: TextAlign.center,
                          validator: (value) {
                            final pin = value?.trim() ?? '';
                            if (pin.isEmpty) {
                              return 'من فضلك أدخل رمز الدخول الجديد';
                            }
                            if (pin.length != 4 || int.tryParse(pin) == null) {
                              return 'رمز الدخول يجب أن يكون 4 أرقام';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                SizedBox(height: 24.h),
                
                // Actions
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => Navigator.of(ctx).pop(),
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white70,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () async {
                              if (!formKey.currentState!.validate()) {
                                return;
                              }

                              final newPin = pinController.text.trim();
                              Navigator.of(ctx).pop();

                              await context.read<AdminCubit>().resetCustomerPin(
                                userId: user.id,
                                newPin: newPin,
                              );
                            },
                            borderRadius: BorderRadius.circular(14.r),
                            child: Container(
                              height: 48.h,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.info,
                                    AppColors.info.withValues(alpha: 0.8),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.info.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.pin_rounded,
                                      color: Colors.white,
                                      size: 20.r,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'تأكيد التغيير',
                                      style: TextStyle(
                                        fontFamily: AppTextStyles.fontFamily,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequirement(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 11.sp,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.sp,
                color: Colors.white60,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showUserDetails(User user) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black87,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A2332),
                Color(0xFF0F1720),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.8),
                blurRadius: 40,
                offset: const Offset(0, -10),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.6,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            expand: false,
            builder: (context, scrollController) {
              return SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Drag Handle
                    Center(
                      child: Container(
                        margin: EdgeInsets.only(top: 12.h),
                        width: 48.w,
                        height: 5.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2.5.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withValues(alpha: 0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Header Section
                    Container(
                      margin: EdgeInsets.all(20.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            _getRoleColor(user.role).withValues(alpha: 0.15),
                            Colors.transparent,
                          ],
                        ),
                        border: Border.all(
                          color: _getRoleColor(user.role).withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 72.r,
                            height: 72.r,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  _getRoleColor(user.role),
                                  _getRoleColor(user.role).withValues(alpha: 0.7),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                              boxShadow: [
                                BoxShadow(
                                  color: _getRoleColor(user.role).withValues(alpha: 0.4),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Icon(
                              _getRoleIcon(user.role),
                              color: Colors.white,
                              size: 36.r,
                            ),
                          ),
                          SizedBox(width: 20.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _getUserDisplayName(user),
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  children: [
                                    _RoleBadge(role: user.role),
                                    SizedBox(width: 10.w),
                                    _StatusBadge(isActive: user.isActive),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // User Details Section
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.r),
                        color: Colors.white.withValues(alpha: 0.05),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white70,
                                size: 20.r,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'معلومات الحساب',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          _DetailItem(
                            icon: Icons.fingerprint_rounded,
                            label: 'المعرف',
                            value: user.id,
                            isMonospace: true,
                          ),
                          if (user.phone != null && user.phone!.isNotEmpty) ...[
                            _DetailItem(
                              icon: Icons.phone_rounded,
                              label: 'رقم الهاتف',
                              value: Formatters.formatPhone(user.phone!),
                            ),
                          ],
                          if (user.username != null && user.username!.isNotEmpty) ...[
                            _DetailItem(
                              icon: Icons.person_rounded,
                              label: 'اسم المستخدم',
                              value: user.username!,
                            ),
                          ],
                          _DetailItem(
                            icon: Icons.calendar_today_rounded,
                            label: 'تاريخ التسجيل',
                            value: Formatters.formatDate(user.createdAt),
                          ),
                          _DetailItem(
                            icon: Icons.update_rounded,
                            label: 'آخر تحديث',
                            value: Formatters.formatDateTime(user.updatedAt),
                          ),
                        ],
                      ),
                    ),
                    
                    // Shop Details Section (if applicable)
                    if (user.role == UserRole.shop && user.shop != null) ...[
                      Container(
                        margin: EdgeInsets.all(20.w),
                        padding: EdgeInsets.all(20.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20.r),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.secondary.withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                          ),
                          border: Border.all(
                            color: AppColors.secondary.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.storefront_rounded,
                                  color: AppColors.secondary,
                                  size: 20.r,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'معلومات المحل',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            _DetailItem(
                              icon: Icons.store_rounded,
                              label: 'اسم المحل',
                              value: user.shop!.displayName,
                              valueColor: AppColors.secondary,
                            ),
                            if (user.shop!.categoryId.isNotEmpty) ...[
                              _DetailItem(
                                icon: Icons.category_rounded,
                                label: 'القسم',
                                value: user.shop!.categoryId,
                              ),
                            ],
                            if (user.shop!.address != null && user.shop!.address!.isNotEmpty) ...[
                              _DetailItem(
                                icon: Icons.location_on_rounded,
                                label: 'العنوان',
                                value: user.shop!.address!,
                              ),
                            ],
                            if (user.shop!.phone != null && user.shop!.phone!.isNotEmpty) ...[
                              _DetailItem(
                                icon: Icons.phone_in_talk_rounded,
                                label: 'هاتف المحل',
                                value: Formatters.formatPhone(user.shop!.phone!),
                              ),
                            ],
                            _DetailItem(
                              icon: Icons.percent_rounded,
                              label: 'نسبة العمولة',
                              value: '${(user.shop!.commissionRate * 100).toStringAsFixed(0)}%',
                              valueColor: AppColors.info,
                            ),
                            _DetailItem(
                              icon: Icons.shopping_cart_rounded,
                              label: 'الحد الأدنى للطلب',
                              value: Formatters.formatCurrency(user.shop!.minOrderAmount),
                              valueColor: AppColors.warning,
                            ),
                            _DetailItem(
                              icon: user.shop!.isOpen ? Icons.door_front_door : Icons.door_back_door,
                              label: 'حالة المحل',
                              value: user.shop!.isOpen ? 'مفتوح' : 'مغلق',
                              valueColor: user.shop!.isOpen ? AppColors.success : AppColors.error,
                            ),
                          ],
                        ),
                      ),
                    ],
                    
                    // Actions Section
                    Container(
                      margin: EdgeInsets.all(20.w),
                      child: Row(
                        children: [
                          if (user.role == UserRole.customer) ...[
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.pin_rounded,
                                label: 'إعادة تعيين PIN',
                                color: AppColors.info,
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  await _showResetCustomerPinDialog(user);
                                },
                              ),
                            ),
                          ] else ...[
                            Expanded(
                              child: _ActionButton(
                                icon: Icons.lock_reset_rounded,
                                label: 'إعادة تعيين كلمة المرور',
                                color: AppColors.info,
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  await _showResetPasswordDialog(user);
                                },
                              ),
                            ),
                          ],
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _ActionButton(
                              icon: user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                              label: user.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
                              color: user.isActive ? AppColors.error : AppColors.success,
                              onTap: () {
                                Navigator.pop(ctx);
                                _showToggleDialog(user);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    SizedBox(height: 20.h),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showToggleDialog(User user) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black87,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          constraints: BoxConstraints(maxWidth: 400.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24.r),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A2332),
                Color(0xFF0F1720),
              ],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.15),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: user.isActive
                    ? AppColors.error.withValues(alpha: 0.2)
                    : AppColors.success.withValues(alpha: 0.2),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with icon
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      user.isActive
                          ? AppColors.error.withValues(alpha: 0.15)
                          : AppColors.success.withValues(alpha: 0.15),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 72.r,
                      height: 72.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: user.isActive
                              ? [AppColors.error, AppColors.error.withValues(alpha: 0.7)]
                              : [AppColors.success, AppColors.success.withValues(alpha: 0.7)],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: user.isActive
                                ? AppColors.error.withValues(alpha: 0.4)
                                : AppColors.success.withValues(alpha: 0.4),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        user.isActive ? Icons.block_rounded : Icons.check_circle_rounded,
                        color: Colors.white,
                        size: 36.r,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      user.isActive ? 'تعطيل الحساب' : 'تفعيل الحساب',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text(
                      user.isActive
                          ? 'هل أنت متأكد من تعطيل حساب'
                          : 'هل أنت متأكد من تفعيل حساب',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 15.sp,
                        color: Colors.white70,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getRoleIcon(user.role),
                            color: _getRoleColor(user.role),
                            size: 20.r,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _getUserDisplayName(user),
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (user.isActive) ...[
                      SizedBox(height: 16.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.error,
                              size: 20.r,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                'سيتم منع المستخدم من الدخول للتطبيق',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12.sp,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Actions
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
                  border: Border(
                    top: BorderSide(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(ctx),
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'إلغاء',
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pop(ctx);
                            context.read<AdminCubit>().toggleUserStatus(
                              userId: user.id,
                              isActive: !user.isActive,
                              role: _selectedRole,
                            );
                          },
                          borderRadius: BorderRadius.circular(14.r),
                          child: Container(
                            height: 48.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14.r),
                              gradient: LinearGradient(
                                colors: user.isActive
                                    ? [AppColors.error, AppColors.error.withValues(alpha: 0.8)]
                                    : [AppColors.success, AppColors.success.withValues(alpha: 0.8)],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: user.isActive
                                      ? AppColors.error.withValues(alpha: 0.3)
                                      : AppColors.success.withValues(alpha: 0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    user.isActive
                                        ? Icons.block_rounded
                                        : Icons.check_circle_rounded,
                                    color: Colors.white,
                                    size: 20.r,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    user.isActive ? 'تعطيل' : 'تفعيل',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UsersHeaderCard extends StatelessWidget {
  const _UsersHeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0B1722),
            Color(0xFF132433),
          ],
        ),
        border: Border.all(
          color: Colors.white24,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 28,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryLight,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.55),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 24.r,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة مستخدمي بلدي',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'مراجعة صلاحيات وأمان حسابات العملاء، المحلات، السائقين، والمديرين.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: Colors.white70,
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

/// Soft glowing background orb for admin users screen (matches admin dashboard)
class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const _GlowOrb({
    required this.size,
    required this.color,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: opacity),
            blurRadius: size / 2,
            spreadRadius: size / 6,
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
      // كارت داكن بنفس روح كروت لوحة التحكم
      backgroundColor: const Color(0xFF0B1722),
      borderColor: user.isActive ? null : AppColors.error,
      onTap: onViewDetails,
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: _getRoleColor(user.role).withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              _getRoleIcon(user.role),
              color: Colors.white,
              size: 24.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getUserDisplayName(user),
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (user.role == UserRole.shop && user.shop != null) ...[
                            SizedBox(height: 2.h),
                            Text(
                              'صاحب ${user.shop!.displayName}',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12.sp,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                    _StatusBadge(isActive: user.isActive),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    _RoleBadge(role: user.role),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'انضم ${Formatters.formatRelativeTime(user.createdAt)}',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.sp,
                          color: Colors.white70,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white70,
              size: 20.r,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            onSelected: (value) async {
              if (value == 'toggle') {
                onToggleStatus();
              } else if (value == 'reset_password') {
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
                    SizedBox(width: 8.w),
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
                      SizedBox(width: 8.w),
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
                      SizedBox(width: 8.w),
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
          ),
        ],
      ),
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
    final baseColor = _getColor();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        role.labelAr,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getColor() {
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
    final baseColor = isActive ? AppColors.success : AppColors.error;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(
            color: baseColor.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        isActive ? 'نشط' : 'معطل',
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 11.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          letterSpacing: 0.5,
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
    final Color bg = isSelected
        ? Colors.white.withValues(alpha: 0.20)
        : Colors.white.withValues(alpha: 0.06);
    final Color border = isSelected
        ? Colors.white.withValues(alpha: 0.60)
        : Colors.white.withValues(alpha: 0.25);
    final Color textColor =
        isSelected ? Colors.white : Colors.white.withValues(alpha: 0.80);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            color: textColor,
          ),
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final bool isMonospace;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.isMonospace = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: Colors.white60,
              size: 18.r,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: Colors.white60,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: isMonospace ? 'monospace' : AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: valueColor ?? Colors.white,
                    letterSpacing: isMonospace ? 0.5 : 0,
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

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            gradient: LinearGradient(
              colors: [
                color,
                color.withValues(alpha: 0.8),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20.r,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
