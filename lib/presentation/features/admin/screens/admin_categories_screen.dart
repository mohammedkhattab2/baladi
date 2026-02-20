import 'dart:ui';

import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/network/api_client.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/domain/entities/category.dart';
import 'package:baladi/presentation/cubits/admin/admin_categories_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_categories_state.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Admin screen for managing categories (create / edit / delete).
///
/// Uses the existing `/api/categories` backend endpoints which are protected
/// so that only admins can create/update/delete.
class AdminCategoriesScreen extends StatelessWidget {
  const AdminCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AdminCategoriesCubit(apiClient: getIt<ApiClient>())..loadCategories(),
      child: const _AdminCategoriesView(),
    );
  }
}

class _AdminCategoriesView extends StatelessWidget {
  const _AdminCategoriesView();

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'إدارة التصنيفات',
      currentRoute: RouteNames.adminCategories,
      floatingActionButton: _LuxuryFab(
        onPressed: () => _openCategoryForm(context),
      ),
      child: Container(
        decoration: BoxDecoration(
          // Match welcome/auth visual identity: deep navy + green gradient
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A), // Deep navy
              Color(0xFF1B263B), // Dark blue
              Color(0xFF2D5A27), // Forest green (primary tone)
              Color(0xFF1A3A16), // Dark green
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft glowing orbs in background (use app primary/secondary)
            Positioned(
              top: -80.h,
              left: -40.w,
              child: _GlowOrb(
                size: 180.r,
                color: AppColors.primary,
                opacity: 0.22,
              ),
            ),
            Positioned(
              bottom: -60.h,
              right: -20.w,
              child: _GlowOrb(
                size: 160.r,
                color: AppColors.secondary,
                opacity: 0.20,
              ),
            ),
            // Content
            BlocConsumer<AdminCategoriesCubit, AdminCategoriesState>(
              listener: (context, state) {
                if (state is AdminCategoriesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      content: Text(
                        state.message,
                        style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                } else if (state is AdminCategoriesActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.all(16.r),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      content: Text(
                        state.message,
                        style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                      ),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is AdminCategoriesLoading ||
                    state is AdminCategoriesInitial ||
                    state is AdminCategoriesActionLoading) {
                  return const Center(child: LoadingWidget());
                }

                if (state is AdminCategoriesError) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 520.w),
                      child: AppErrorWidget(
                        message: state.message,
                        onRetry: () => context
                            .read<AdminCategoriesCubit>()
                            .loadCategories(),
                      ),
                    ),
                  );
                }

                // For both Loaded and ActionSuccess we have a categories list to show.
                final categories = switch (state) {
                  AdminCategoriesLoaded s => s.categories,
                  AdminCategoriesActionSuccess s => s.categories,
                  _ => const <Category>[],
                };

                if (state is AdminCategoriesLoaded ||
                    state is AdminCategoriesActionSuccess) {
                  if (categories.isEmpty) {
                    return const Center(
                      child: AppEmptyState(
                        icon: Icons.category_outlined,
                        title: 'لا توجد تصنيفات',
                        description: 'لم يتم إضافة أي تصنيفات بعد',
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<AdminCategoriesCubit>().loadCategories(),
                    color: AppColors.primary,
                    backgroundColor: Colors.white,
                    child: ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 32.h),
                      itemCount: state.categories.length,
                      itemBuilder: (context, index) {
                        final category = state.categories[index];
                        return _CategoryCard(
                          index: index,
                          totalCount: state.categories.length,
                          category: category,
                          onEdit: () =>
                              _openCategoryForm(context, category: category),
                          onDelete: () =>
                              _confirmDelete(context, categoryId: category.id),
                        );
                      },
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _openCategoryForm(
    BuildContext context, {
    Category? category,
  }) async {
    final isEdit = category != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: category?.name ?? '');
    final nameArController = TextEditingController(
      text: category?.nameAr ?? '',
    );
    final slugController = TextEditingController(text: category?.slug ?? '');
    final descriptionController = TextEditingController();
    final sortOrderController = TextEditingController(
      text: category != null && category.sortOrder != 0
          ? category.sortOrder.toString()
          : '',
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha:  0.65),
      elevation: 0,
      builder: (ctx) {
        return Stack(
          children: [
            // الخلفية: نفس الجريدينت الأساسي بتاع هوية Baladi (admin / welcome)
            Container(
              decoration: const BoxDecoration(
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
            ),
            // أوربز إضاءة ناعمة في الخلفية عشان تحس إنها نفس العالم البصري
            Positioned(
              top: -40.h,
              left: -20.w,
              child: _GlowOrb(
                size: 140.r,
                color: AppColors.primary,
                opacity: 0.22,
              ),
            ),
            Positioned(
              bottom: 80.h,
              right: -16.w,
              child: _GlowOrb(
                size: 120.r,
                color: AppColors.secondary,
                opacity: 0.20,
              ),
            ),
            // الشيت الزجاجي نفسه
            Align(
              alignment: Alignment.bottomCenter,
              child: _GlassBottomSheet(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 18.h,
                    bottom: MediaQuery.of(ctx).viewInsets.bottom + 22.h,
                  ),
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Container(
                              width: 48.w,
                              height: 5.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.35),
                                borderRadius: BorderRadius.circular(100.r),
                              ),
                            ),
                          ),
                          SizedBox(height: 18.h),
                          // Header بنفس روح شاشات الـ Auth / Welcome (متمركز في المنتصف)
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.r),
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
                                      color: AppColors.primary.withValues(alpha: 0.45),
                                      blurRadius: 18,
                                      offset: Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isEdit ? Icons.edit_rounded : Icons.add_rounded,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                isEdit ? 'تعديل التصنيف' : 'إضافة تصنيف جديد',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                isEdit
                                    ? 'قم بتحديث بيانات التصنيف الحالية'
                                    : 'أنشئ تصنيفاً جديداً لتنظيم المتاجر',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // Glass card for fields (matches auth identity)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.95),
                                  Colors.white.withValues(alpha: 0.92),
                                ],
                              ),
                              border: Border.all(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.04),
                                  blurRadius: 18,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: AppColors.primary.withValues(alpha: 0.10),
                                  blurRadius: 26,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 16.h,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Section chip - basic info
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: AppColors.primary.withValues(alpha: 0.06),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.info_outline_rounded,
                                        size: 14.r,
                                        color: AppColors.primary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'البيانات الأساسية',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                const _FormLabel(text: 'الاسم (بالإنجليزية)'),
                                AppTextField(
                                  controller: nameController,
                                  label: 'مثال: Restaurants',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'من فضلك أدخل الاسم بالإنجليزية';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'الاسم يجب أن يكون حرفين على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 12.h),
                                const _FormLabel(text: 'الاسم (بالعربية)'),
                                AppTextField(
                                  controller: nameArController,
                                  label: 'مثال: مطاعم',
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'من فضلك أدخل الاسم بالعربية';
                                    }
                                    if (value.trim().length < 2) {
                                      return 'الاسم بالعربية يجب أن يكون حرفين على الأقل';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 12.h),
                                const _FormLabel(text: 'المسار (Slug)'),
                                AppTextField(
                                  controller: slugController,
                                  label: 'مثال: restaurants',
                                  helperText:
                                      'حروف إنجليزية صغيرة، أرقام، وشرطات فقط (مثال: restaurants)',
                                  validator: (value) {
                                    final v = value?.trim() ?? '';
                                    if (v.isEmpty) {
                                      return 'من فضلك أدخل المسار (slug)';
                                    }
                                    final regex = RegExp(r'^[a-z0-9-]+$');
                                    if (!regex.hasMatch(v)) {
                                      return 'المسار يجب أن يحتوي على حروف إنجليزية صغيرة، أرقام وشرطات فقط';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 16.h),
                                Divider(
                                  height: 1,
                                  color: AppColors.textSecondary.withValues(alpha: 0.08),
                                ),
                                SizedBox(height: 14.h),
                                // Section chip - advanced options
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(999),
                                    color: AppColors.secondary.withValues(alpha: 0.06),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.tune_rounded,
                                        size: 14.r,
                                        color: AppColors.secondary,
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        'خيارات العرض',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 11.sp,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 14.h),
                                const _FormLabel(text: 'الوصف (اختياري)'),
                                AppTextField(
                                  controller: descriptionController,
                                  label: 'نبذة قصيرة عن هذا التصنيف...',
                                  maxLines: 3,
                                ),
                                SizedBox(height: 12.h),
                                const _FormLabel(text: 'ترتيب العرض (اختياري)'),
                                AppTextField(
                                  controller: sortOrderController,
                                  label: 'مثال: 1',
                                  keyboardType:
                                      const TextInputType.numberWithOptions(
                                        decimal: false,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20.h),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppColors.textSecondary,
                                  ),
                                  child: Text(
                                    'إلغاء',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 13.sp,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                flex: 2,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                      vertical: 12.h,
                                    ),
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                    backgroundColor: AppColors.primary,
                                    shadowColor: AppColors.primary.withValues(alpha: 0.3),
                                  ),
                                  onPressed: () async {
                                    if (!(formKey.currentState?.validate() ??
                                        false)) {
                                      return;
                                    }

                                    final sortOrder =
                                        int.tryParse(
                                          sortOrderController.text.trim(),
                                        ) ??
                                        0;

                                    final payload = <String, dynamic>{
                                      'name': nameController.text.trim(),
                                      'name_ar': nameArController.text.trim(),
                                      'slug': slugController.text.trim(),
                                      if (descriptionController.text
                                          .trim()
                                          .isNotEmpty)
                                        'description': descriptionController
                                            .text
                                            .trim(),
                                      'sort_order': sortOrder,
                                    };

                                    Navigator.of(ctx).pop();

                                    final cubit = context
                                        .read<AdminCategoriesCubit>();
                                    if (isEdit) {
                                      await cubit.updateCategory(
                                        categoryId: category.id,
                                        payload: payload,
                                      );
                                    } else {
                                      await cubit.createCategory(
                                        payload: payload,
                                      );
                                    }
                                  },
                                  child: Text(
                                    isEdit ? 'تحديث التصنيف' : 'حفظ التصنيف',
                                    style: TextStyle(
                                      fontFamily: AppTextStyles.fontFamily,
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _confirmDelete(
    BuildContext context, {
    required String categoryId,
  }) async {
    final cubit = context.read<AdminCategoriesCubit>();

    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) => Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 420.w),
          child: Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: _GlassDialog(
              child: Padding(
                padding: EdgeInsets.all(20.r),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: EdgeInsets.all(14.r),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.error,
                            AppColors.error.withValues(alpha: 0.8),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.error.withValues(alpha: 0.45),
                            blurRadius: 18,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.delete_forever_rounded,
                        color: Colors.white,
                        size: 26.r,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    Text(
                      'حذف التصنيف',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontWeight: FontWeight.w700,
                        fontSize: 18.sp,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'هل أنت متأكد من حذف هذا التصنيف؟ لا يمكن التراجع عن هذه العملية.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.sp,
                        color: AppColors.textSecondary.withValues(alpha: 0.95),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              backgroundColor: AppColors.error,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                            ),
                            onPressed: () async {
                              Navigator.of(ctx).pop();
                              await cubit.deleteCategory(
                                categoryId: categoryId,
                              );
                            },
                            child: Text(
                              'حذف نهائياً',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final int index;
  final int totalCount;

  const _CategoryCard({
    required this.category,
    required this.onEdit,
    required this.onDelete,
    required this.index,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = category.isActive;

    final baseColor = isActive ? AppColors.success : AppColors.error;
    final tileColor = baseColor.withValues(alpha: 0.12);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.06),
            Colors.white.withValues(alpha: 0.02),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: 0.20),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        onTap: onEdit,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: icon + names + status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon + decorative ring
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [tileColor, tileColor.withValues(alpha: 0.4)],
                        ),
                      ),
                    ),
                    Container(
                      width: 42.r,
                      height: 42.r,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            baseColor.withValues(alpha: 0.95),
                            baseColor.withValues(alpha: 0.75),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: baseColor.withValues(alpha: 0.55),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.category_rounded,
                        color: Colors.white,
                        size: 22.r,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic name (primary)
                      Text(
                        category.nameAr,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 3.h),
                      // English name + slug chip
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              category.name,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                                color: AppColors.textSecondary.withValues(
                                  alpha: 0.95,
                                ),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 3.h,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: Colors.white.withValues(alpha: 0.06),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.link_rounded,
                                  size: 11.r,
                                  color: AppColors.textSecondary.withValues(
                                    alpha: 0.9,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  category.slug,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 10.sp,
                                    color: AppColors.textSecondary.withValues(
                                      alpha: 0.9,
                                    ),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                // Status pill
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    gradient: LinearGradient(
                      colors: isActive
                          ? [
                              AppColors.success.withValues(alpha:  0.16),
                              AppColors.success.withValues ( alpha: 0.26),
                            ]
                          : [
                              AppColors.error.withValues(alpha: 0.16),
                              AppColors.error.withValues(alpha: 0.26),
                            ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isActive ? AppColors.success : AppColors.error)
                            .withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.r,
                        height: 6.r,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isActive ? 'نشط' : 'معطل',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            // Bottom row: sort order + actions
            Row(
              children: [
                if (category.sortOrder != 0) ...[
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 3.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.primary.withValues(alpha: 0.08),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sort_rounded,
                          size: 12.r,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'ترتيب #${category.sortOrder}',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11.sp,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                ],
                Spacer(),
                TextButton.icon(
                  onPressed: onEdit,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: Icon(Icons.edit_rounded, size: 16.r),
                  label: Text(
                    'تعديل',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                TextButton.icon(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.error,
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  icon: Icon(Icons.delete_outline_rounded, size: 16.r),
                  label: Text(
                    'حذف',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Soft glowing background orb used in admin screens
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

/// Floating luxury FAB
class _LuxuryFab extends StatelessWidget {
  final VoidCallback onPressed;

  const _LuxuryFab({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
        borderRadius: BorderRadius.circular(999),
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary,
              AppColors.primaryLight,
              AppColors.secondary.withValues(alpha: 0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: FloatingActionButton.extended(
          onPressed: onPressed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.16),
            ),
            child: const Icon(Icons.add_rounded, size: 18, color: Colors.white),
          ),
          label: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Text(
              'تصنيف جديد',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontWeight: FontWeight.w700,
                fontSize: 14.sp,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Glassmorphism wrapper for bottom sheets
class _GlassBottomSheet extends StatelessWidget {
  final Widget child;

  const _GlassBottomSheet({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
            // خلي الشيت شبه زجاج شفاف فوق الجريدينت الغامق (مش أبيض مصمت)
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.16),
                Colors.white.withValues(alpha: 0.06),
              ],
            ),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.30),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 24,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Glassmorphism wrapper for dialogs
class _GlassDialog extends StatelessWidget {
  final Widget child;

  const _GlassDialog({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.92),
                Colors.white.withValues(alpha: 0.98),
              ],
            ),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.8),
              width: 1.4,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Small label above form fields
class _FormLabel extends StatelessWidget {
  final String text;

  const _FormLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary.withValues(alpha: 0.95),
        ),
      ),
    );
  }
}
