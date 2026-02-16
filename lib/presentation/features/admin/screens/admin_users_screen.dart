import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
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
      child: Column(children: [_buildFilters()]),
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
