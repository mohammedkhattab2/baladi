import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/user.dart';
import 'package:baladi/domain/enums/user_role.dart';
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
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

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
        children: [
          AppSearchField(
            controller: _searchController,
            hint: "بحث بالاسم أو رقم الهاتف...",
            onChanged: (value) {
              //// TODO: Implement local search filtering Implement search logic here
            },
          ),
          SizedBox(height: 12.h),
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
        ],
      ),
    );
  }

  void _onRoleFilter(String? role) {
    setState(() => _selectedRole = role);
    _loadUser();
  }

  void _loadUser() {
    context.read<AdminCubit>().loadUsers(role: _selectedRole);
  }

  Widget _buildUsersList(AdminUsersLoaded state) {
    if (state.users.isEmpty) {
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
        itemCount: state.users.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.users.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          return _UseCard(
            user: state.users[index],
            onToggleStatus: () => _showToggleDialog(state.users[index]),
          );
        },
      ),
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
              ? 'هل تريد تعطيل حساب ${user.displayIdentifier}؟'
              : 'هل تريد تفعيل حساب ${user.displayIdentifier}؟',
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

  const _UseCard({
    required this.user,
    required this.onToggleStatus,
  });
  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      borderColor: user.isActive? null : AppColors.error,
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
                        user.displayIdentifier,
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
            onSelected: (value) {
              if (value == 'toggle') {
                onToggleStatus();
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
                      user.isActive ? "تفعيل الحساب" : "تعطيل الحساب",
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        
                      ),
                    )
                  ],
                )
              )
            ]
            )
        ],

      )
    );
  }

Color  _getRoleColor(UserRole role) {
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
