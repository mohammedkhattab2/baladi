import 'dart:ui';
import 'dart:io';

import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/core/network/api_client.dart';
import 'package:baladi/core/network/api_endpoints.dart';
import 'package:baladi/data/models/category_model.dart';
import 'package:baladi/domain/entities/category.dart';
import 'package:baladi/domain/entities/shop.dart';
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
import 'package:image_picker/image_picker.dart';

class AdminShopsScreen extends StatelessWidget {
  const AdminShopsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadShops(),
      child: const _AdminShopView(),
    );
  }
}

class _AdminShopView extends StatefulWidget {
  const _AdminShopView();

  @override
  State<_AdminShopView> createState() => _AdminShopViewState();
}

class _AdminShopViewState extends State<_AdminShopView> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  // Loaded categories list to use in the shop form dropdown.
  List<Category> _categories = const <Category>[];
  bool _isLoadingCategories = false;
  String? _categoriesError;

  // Local image paths for new shop creation (logo optional, cover required).
  String? _newShopLogoPath;
  String? _newShopCoverPath;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadCategories();
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
      if (state is AdminShopsLoaded && state.hasMore) {
        context.read<AdminCubit>().loadMoreShops();
      }
    }
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.dio.get(ApiEndpoints.categories);
      final data = response.data;

      if (data is Map<String, dynamic>) {
        final list = data['data'] as List? ?? [];
        final categories = list
            .whereType<Map>()
            .map((e) => CategoryModel.fromJson(
                  Map<String, dynamic>.from(e as Map),
                ) as Category)
            .where((c) => c.isActive)
            .toList();

        if (!mounted) return;
        setState(() {
          _categories = categories;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _categoriesError = 'استجابة غير متوقعة أثناء تحميل التصنيفات';
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _categoriesError = 'تعذر تحميل التصنيفات، حاول مرة أخرى';
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: "إدارة المحلات",
      currentRoute: RouteNames.adminShops,
      floatingActionButton: _LuxuryFab(
        onPressed: () => _openCreateShopForm(context),
      ),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0D1B2A), // Deep navy
              Color(0xFF1B263B), // Dark blue
              Color(0xFF2D5A27), // Forest green
              Color(0xFF1A3A16), // Dark green
            ],
            stops: [0.0, 0.35, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Background glow orbs
            Positioned(
              top: -80,
              left: -40,
              child: _GlowOrb(
                size: 180,
                color: AppColors.primary,
                opacity: 0.22,
              ),
            ),
            Positioned(
              bottom: -60,
              right: -20,
              child: _GlowOrb(
                size: 160,
                color: AppColors.secondary,
                opacity: 0.20,
              ),
            ),
            Column(
              children: [
                _buildSearchBar(),
                Expanded(
                  child: BlocConsumer<AdminCubit, AdminState>(
                    listener: (context, state) {
                      if (state is AdminError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            behavior: SnackBarBehavior.floating,
                            margin: EdgeInsets.all(16.r),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            content: Text(
                              state.message,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                              ),
                            ),
                            backgroundColor: AppColors.error,
                          ),
                        );
                      }
                    },
                    builder: (context, state) {
                      if (state is AdminLoading || state is AdminActionLoading) {
                        return const Center(child: LoadingWidget());
                      }
                      if (state is AdminError) {
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 520.w),
                            child: AppErrorWidget(
                              message: state.message,
                              onRetry: () =>
                                  context.read<AdminCubit>().loadShops(),
                            ),
                          ),
                        );
                      }
                      if (state is AdminShopsLoaded) {
                        return _buildShopsList(state);
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 10.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withValues(alpha: 0.16),
              Colors.white.withValues(alpha: 0.08),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.25),
              blurRadius: 26,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        padding: EdgeInsets.all(12.w),
        child: AppSearchField(
          controller: _searchController,
          hint: 'بحث باسم المحل أو رقم الهاتف...',
          // نفس ستايل البحث في عالم الـ Admin الداكن (مطابق لشاشة المستخدمين)
          backgroundColor: Colors.white.withValues(alpha: 0.12),
          textColor: Colors.white,
          iconColor: Colors.white70,
          hintColor: Colors.white60,
          onChanged: (value) {
            // فلترة محلية على البيانات اللي جاية من الـ API بدون استدعاء جديد
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<void> _openCreateShopForm(BuildContext context) async {
    await _openShopForm(context);
  }

  Future<void> _openEditShopForm(BuildContext context, Shop shop) async {
    await _openShopForm(context, shop: shop);
  }

  Future<void> _openShopForm(BuildContext context, {Shop? shop}) async {
    final isEdit = shop != null;
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: isEdit ? shop.name : '');
    final nameArController =
        TextEditingController(text: isEdit ? (shop.nameAr ?? '') : '');
    final phoneController =
        TextEditingController(text: isEdit ? (shop.phone ?? '') : '');
    final addressController =
        TextEditingController(text: isEdit ? (shop.address ?? '') : '');
    // category_id is required by the backend when creating/updating a shop
    final categoryIdController = TextEditingController(
      text: isEdit ? shop.categoryId : '',
    );
    final commissionController = TextEditingController(
      text: isEdit ? shop.commissionRate.toString() : '10',
    );
    final minOrderController = TextEditingController(
      text: isEdit && shop.minOrderAmount > 0
          ? shop.minOrderAmount.toString()
          : '',
    );

    // بيانات مالك المحل (لإنشاء يوزر جديد) – لن نعدلها في وضع التعديل.
    final ownerNameController = TextEditingController();
    final ownerUsernameController = TextEditingController();
    final ownerPhoneController = TextEditingController();
    final ownerPasswordController = TextEditingController();

    // Reset picked images on create.
    if (!isEdit) {
      _newShopLogoPath = null;
      _newShopCoverPath = null;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      elevation: 0,
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(32.r)),
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A2332),
                        Color(0xFF0F1720),
                      ],
                    ),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.18),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.8),
                        blurRadius: 40,
                        offset: const Offset(0, -10),
                      ),
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 30,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      // Decorative glow effects
                      Positioned(
                        top: -50,
                        right: -30,
                        child: _GlowOrb(
                          size: 180,
                          color: isEdit ? AppColors.secondary : AppColors.primary,
                          opacity: 0.15,
                        ),
                      ),
                      Positioned(
                        bottom: 100,
                        left: -40,
                        child: _GlowOrb(
                          size: 150,
                          color: isEdit ? AppColors.primary : AppColors.secondary,
                          opacity: 0.12,
                        ),
                      ),
                      // Content
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(ctx).viewInsets.bottom,
                        ),
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Drag handle
                                Center(
                                  child: Container(
                                    margin: EdgeInsets.only(top: 12.h, bottom: 20.h),
                                    width: 50.w,
                                    height: 5.h,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.25),
                                      borderRadius: BorderRadius.circular(100.r),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                // Header Section
                                Container(
                                  padding: EdgeInsets.all(24.r),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        isEdit
                                          ? AppColors.secondary.withValues(alpha: 0.15)
                                          : AppColors.primary.withValues(alpha: 0.15),
                                        Colors.transparent,
                                      ],
                                    ),
                                    border: Border.all(
                                      color: isEdit
                                        ? AppColors.secondary.withValues(alpha: 0.25)
                                        : AppColors.primary.withValues(alpha: 0.25),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 56.r,
                                        height: 56.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: isEdit ? [
                                              AppColors.secondary,
                                              AppColors.secondary.withValues(alpha: 0.8),
                                            ] : [
                                              AppColors.primary,
                                              AppColors.primaryLight,
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: isEdit
                                                ? AppColors.secondary.withValues(alpha: 0.4)
                                                : AppColors.primary.withValues(alpha: 0.4),
                                              blurRadius: 20,
                                              spreadRadius: 2,
                                            ),
                                          ],
                                        ),
                                        child: Icon(
                                          isEdit
                                              ? Icons.edit_rounded
                                              : Icons.storefront_rounded,
                                          color: Colors.white,
                                          size: 28.r,
                                        ),
                                      ),
                                      SizedBox(width: 16.w),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              isEdit ? 'تعديل بيانات المحل' : 'إضافة محل جديد',
                                              style: TextStyle(
                                                fontFamily: AppTextStyles.fontFamily,
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.w800,
                                                color: Colors.white,
                                                letterSpacing: 0.3,
                                              ),
                                            ),
                                            SizedBox(height: 4.h),
                                            Text(
                                              isEdit
                                                  ? 'قم بتحديث بيانات المحل الحالية'
                                                  : 'أنشئ متجرًا جديداً للمنصة',
                                              style: TextStyle(
                                                fontFamily: AppTextStyles.fontFamily,
                                                fontSize: 13.sp,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                // Fields container with enhanced glassmorphism
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Colors.white.withValues(alpha: 0.08),
                                        Colors.white.withValues(alpha: 0.04),
                                      ],
                                    ),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.25),
                                        blurRadius: 20,
                                        offset: const Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(20.r),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppTextField(
                    controller: nameController,
                    label: 'اسم المحل (بالإنجليزية)',
                    labelColor: Colors.white,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'من فضلك أدخل اسم المحل';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: nameArController,
                    label: 'اسم المحل (بالعربية)',
                    labelColor: Colors.white,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'من فضلك أدخل اسم المحل بالعربية';
                      }
                      if (value.trim().length < 2) {
                        return 'اسم المحل بالعربية يجب أن يكون حرفين على الأقل';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  if (_isLoadingCategories) ...[
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'جاري تحميل التصنيفات...',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    Text(
                      'فئة المحل',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    DropdownButtonFormField<String>(
                      initialValue: categoryIdController.text.isNotEmpty
                          ? categoryIdController.text
                          : null,
                      decoration: InputDecoration(
                        hintText: 'اختر الفئة',
                        helperText: _categories.isEmpty
                            ? 'لا توجد تصنيفات متاحة، قم بإضافتها من شاشة التصنيفات'
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 12.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: 0.08),
                      ),
                      dropdownColor: const Color(0xFF1A2332),
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        color: Colors.white,
                      ),
                      icon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Text(
                                  c.nameAr,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 14.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          categoryIdController.text = value ?? '';
                        });
                      },
                      validator: (_) {
                        final v = categoryIdController.text.trim();
                        if (v.isEmpty) {
                          return 'من فضلك اختر الفئة';
                        }
                        return null;
                      },
                    ),
                    if (_categoriesError != null) ...[
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _categoriesError!,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11.sp,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _loadCategories,
                            child: Text(
                              'إعادة المحاولة',
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 11.sp,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: phoneController,
                    label: 'رقم الهاتف',
                    labelColor: Colors.white,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'من فضلك أدخل رقم الهاتف';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: addressController,
                    label: 'العنوان',
                    labelColor: Colors.white,
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: commissionController,
                    label: 'نسبة العمولة (%)',
                    labelColor: Colors.white,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'من فضلك أدخل نسبة العمولة';
                      }
                      final v = double.tryParse(value.replaceAll(',', '.'));
                      if (v == null || v <= 0) {
                        return 'نسبة عمولة غير صحيحة';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: minOrderController,
                    label: 'الحد الأدنى للطلب (اختياري)',
                    labelColor: Colors.white,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  // صور المحل (لوجو اختياري، غلاف إجباري عند الإضافة)
                  SizedBox(height: 8.h),
                  Text(
                    'صور المحل',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'اختيار لوجو (اختياري) وصورة غلاف (إجباري عند إضافة محل جديد).',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11.sp,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Logo (optional)
                  Text(
                    'لوجو المحل (اختياري)',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _newShopLogoPath = picked.path;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.45),
                          width: 1.2,
                        ),
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      padding: EdgeInsets.all(10.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.primary.withValues(alpha: 0.18),
                            ),
                            child: Icon(
                              Icons.logo_dev_rounded,
                              color: AppColors.primaryLight,
                              size: 22.r,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _newShopLogoPath == null
                                      ? 'اختر لوجو من المعرض (اختياري)'
                                      : 'تم اختيار لوجو',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _newShopLogoPath ?? 'سيتم استخدام أيقونة افتراضية عند عدم اختيار لوجو',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_newShopLogoPath != null) ...[
                            SizedBox(width: 8.w),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.file(
                                File(_newShopLogoPath!),
                                width: 42.r,
                                height: 42.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  // Cover image (required for create)
                  Text(
                    'صورة الغلاف (إجباري عند الإضافة)',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  GestureDetector(
                    onTap: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 85,
                      );
                      if (picked != null && mounted) {
                        setState(() {
                          _newShopCoverPath = picked.path;
                        });
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(
                          color: AppColors.secondary.withValues(alpha: 0.6),
                          width: 1.2,
                        ),
                        color: Colors.white.withValues(alpha: 0.06),
                      ),
                      padding: EdgeInsets.all(10.r),
                      child: Row(
                        children: [
                          Container(
                            width: 40.r,
                            height: 40.r,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.r),
                              color: AppColors.secondary.withValues(alpha: 0.18),
                            ),
                            child: Icon(
                              Icons.photo_library_rounded,
                              color: AppColors.secondary,
                              size: 22.r,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _newShopCoverPath == null
                                      ? 'اختر صورة غلاف من المعرض'
                                      : 'تم اختيار صورة الغلاف',
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  _newShopCoverPath ??
                                      'هذه الصورة ستظهر كغلاف للمحل داخل التطبيق',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: AppTextStyles.fontFamily,
                                    fontSize: 11.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_newShopCoverPath != null) ...[
                            SizedBox(width: 8.w),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: Image.file(
                                File(_newShopCoverPath!),
                                width: 42.r,
                                height: 42.r,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (!isEdit) ...[
                    SizedBox(height: 16.h),
                    Text(
                      'بيانات صاحب المحل',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: ownerNameController,
                      label: 'اسم صاحب المحل',
                      labelColor: Colors.white,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'من فضلك أدخل اسم صاحب المحل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: ownerUsernameController,
                      label: 'اسم المستخدم (للدخول للتطبيق)',
                      labelColor: Colors.white,
                      validator: (value) {
                        final v = value?.trim() ?? '';
                        if (v.isEmpty) {
                          return 'من فضلك أدخل اسم المستخدم';
                        }
                        if (v.length < 3) {
                          return 'اسم المستخدم يجب أن يكون 3 أحرف على الأقل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: ownerPhoneController,
                      label: 'رقم جوال صاحب المحل',
                      labelColor: Colors.white,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'من فضلك أدخل رقم جوال صاحب المحل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: ownerPasswordController,
                      label: 'كلمة مرور الحساب',
                      labelColor: Colors.white,
                      obscureText: true,
                      validator: (value) {
                        final password = value?.trim() ?? '';
                        if (password.isEmpty) {
                          return 'من فضلك أدخل كلمة المرور';
                        }
                        if (password.length < 8) {
                          return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
                        }
                        final hasUpper =
                            password.contains(RegExp(r'[A-Z]'));
                        final hasLower =
                            password.contains(RegExp(r'[a-z]'));
                        final hasDigit = password.contains(RegExp(r'\d'));
                        if (!hasUpper || !hasLower || !hasDigit) {
                          return 'يجب أن تحتوي على حرف كبير، حرف صغير، ورقم';
                        }
                        return null;
                      },
                    ),
                  ],
                  SizedBox(height: 24.h),
                  // Action buttons with enhanced styling
                  Row(
                    children: [
                      // Cancel button
                      Expanded(
                                     child: Material(
                                       color: Colors.transparent,
                                       child: InkWell(
                                         onTap: () => Navigator.of(ctx).pop(),
                                         borderRadius: BorderRadius.circular(16.r),
                                         child: Container(
                                           height: 52.h,
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(16.r),
                                             border: Border.all(
                                               color: Colors.white.withValues(alpha: 0.2),
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
                                                 color: Colors.white,
                                               ),
                                             ),
                                           ),
                                         ),
                                       ),
                                     ),
                                   ),
                                   SizedBox(width: 12.w),
                                   // Submit button
                                   Expanded(
                                     flex: 2,
                                     child: Material(
                                       color: Colors.transparent,
                                       child: InkWell(
                                         borderRadius: BorderRadius.circular(16.r),
                                         onTap: () async {
                             if (!formKey.currentState!.validate()) {
                               return;
                             }

                             // For create flow, require a cover image.
                             if (!isEdit &&
                                 (_newShopCoverPath == null ||
                                     _newShopCoverPath!.isEmpty)) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   behavior: SnackBarBehavior.floating,
                                   margin: EdgeInsets.all(16.r),
                                   shape: RoundedRectangleBorder(
                                     borderRadius: BorderRadius.circular(16.r),
                                   ),
                                   content: Text(
                                     'من فضلك اختر صورة غلاف للمحل قبل الحفظ',
                                     style: TextStyle(
                                       fontFamily: AppTextStyles.fontFamily,
                                     ),
                                   ),
                                   backgroundColor: AppColors.error,
                                 ),
                               );
                               return;
                             }

                             final commission =
                                 double.tryParse(commissionController.text
                                         .replaceAll(',', '.')) ??
                                     10;
                             final minOrder =
                                 double.tryParse(minOrderController.text
                                         .replaceAll(',', '.')) ??
                                     0;

                             // Backend expects a FLAT body (no nested shop/owner objects)
                             // according to createShopSchema in admin.validation.js:
                             // {
                             //   username, password, name, name_ar, category_id,
                             //   phone, address, area, commission_rate, min_order_amount, delivery_fee
                             // }
                             final payload = <String, dynamic>{
                               'username': ownerUsernameController.text.trim(),
                               'password': ownerPasswordController.text.trim(),
                               'name': nameController.text.trim(),
                               'name_ar': nameArController.text.trim(),
                               'category_id': categoryIdController.text.trim(),
                               'phone': phoneController.text.trim(),
                               'address': addressController.text.trim(),
                               'commission_rate': commission / 100,
                               'min_order_amount': minOrder,
                               // Optional fields not currently collected in UI:
                               // 'area': null,
                               // 'delivery_fee': 10, // backend default
                             };

                             Navigator.of(ctx).pop();

                             final cubit = context.read<AdminCubit>();
                             if (isEdit) {
                               // Debug log to check shop ID
                               print('Updating shop with ID: ${shop.id}');
                               
                               if (shop.id.isEmpty) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                   SnackBar(
                                     behavior: SnackBarBehavior.floating,
                                     margin: EdgeInsets.all(16.r),
                                     shape: RoundedRectangleBorder(
                                       borderRadius: BorderRadius.circular(16.r),
                                     ),
                                     content: Text(
                                       'خطأ: معرف المحل غير صحيح',
                                       style: TextStyle(
                                         fontFamily: AppTextStyles.fontFamily,
                                       ),
                                     ),
                                     backgroundColor: AppColors.error,
                                   ),
                                 );
                                 return;
                               }
                               
                               await cubit.updateShopAsAdmin(
                                 shopId: shop.id,
                                 payload: {
                                   'name': nameController.text.trim(),
                                   'name_ar': nameArController.text.trim(),
                                   'category_id':
                                       categoryIdController.text.trim(),
                                   'phone': phoneController.text.trim(),
                                   'address': addressController.text.trim(),
                                   'commission_rate': commission / 100,
                                   'min_order_amount': minOrder,
                                 },
                               );
                             } else {
                               await cubit.createShopAsAdmin(
                                 payload: payload,
                                 logoPath: _newShopLogoPath,
                                 coverImagePath: _newShopCoverPath,
                               );
                             }

                             // في حالة النجاح، حالة الـ Cubit هتكون AdminShopsLoaded (أما الأخطاء فيتم عرضها في الـ listener)
                             final currentState = cubit.state;
                             if (currentState is AdminShopsLoaded && context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 SnackBar(
                                   content: Text(
                                     isEdit
                                         ? 'تم تحديث بيانات المحل بنجاح'
                                         : 'تم إضافة المحل بنجاح',
                                   style: TextStyle(
                                     fontFamily: AppTextStyles.fontFamily,
                                   ),
                                   ),
                                   backgroundColor: AppColors.success,
                                 ),
                               );
                             }
                                           },
                                         child: Container(
                                           height: 52.h,
                                           decoration: BoxDecoration(
                                             borderRadius: BorderRadius.circular(16.r),
                                             gradient: LinearGradient(
                                               colors: isEdit ? [
                                                 AppColors.secondary,
                                                 AppColors.secondary.withValues(alpha: 0.8),
                                               ] : [
                                                 AppColors.primary,
                                                 AppColors.primaryLight,
                                               ],
                                             ),
                                             boxShadow: [
                                               BoxShadow(
                                                 color: isEdit
                                                   ? AppColors.secondary.withValues(alpha: 0.3)
                                                   : AppColors.primary.withValues(alpha: 0.3),
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
                                                   isEdit
                                                     ? Icons.update_rounded
                                                     : Icons.save_rounded,
                                                   color: Colors.white,
                                                   size: 20.r,
                                                 ),
                                                 SizedBox(width: 8.w),
                                                 Text(
                                                   isEdit ? 'تحديث البيانات' : 'حفظ المحل',
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
                               SizedBox(height: 24.h),
                             ],
                           ),
                         ),
                       ],
                     ),
                   ),
                 ),
               ),
             ],
           ),
         ),
       ),
     );
         },
       );
     },
   );
  }

  IconData _getCategoryIconForShop(Shop shop) {
    // نحاول نجيب الكاتيجوري المرتبطة بالمحل من اللي اتحملت في الشاشة
    final category = _categories.firstWhere(
      (c) => c.id == shop.categoryId,
      orElse: () => Category(
        id: '',
        name: '',
        nameAr: '',
        slug: '',
        icon: '',
        isActive: true,
        sortOrder: 0,
      ),
    );

    final iconSource = category.icon?.isNotEmpty == true
        ? category.icon!
        : category.slug?.isNotEmpty == true
            ? category.slug!
            : (category.name ?? '');
    final iconKey = iconSource.toLowerCase();

    // مابين الكاتيجوريز المعروفة و أيقونات الـ Material
    if (iconKey.contains('pharmacy') ||
        iconKey.contains('صيد') ||
        iconKey.contains('دواء')) {
      return Icons.local_pharmacy;
    }
    if (iconKey.contains('restaurant') ||
        iconKey.contains('مطعم') ||
        iconKey.contains('food') ||
        iconKey.contains('اكل') ||
        iconKey.contains('وجبات')) {
      return Icons.restaurant;
    }
    if (iconKey.contains('market') ||
        iconKey.contains('grocery') ||
        iconKey.contains('سوبر') ||
        iconKey.contains('بقال')) {
      return Icons.local_grocery_store;
    }
    if (iconKey.contains('butcher') ||
        iconKey.contains('لحوم') ||
        iconKey.contains('جزار')) {
      return Icons.set_meal;
    }
    if (iconKey.contains('bakery') ||
        iconKey.contains('مخبز') ||
        iconKey.contains('حلويات') ||
        iconKey.contains('كيك')) {
      return Icons.cake;
    }
    if (iconKey.contains('phone') ||
        iconKey.contains('mobile') ||
        iconKey.contains('موبايل') ||
        iconKey.contains('جوال')) {
      return Icons.phone_iphone;
    }
    if (iconKey.contains('electronics') ||
        iconKey.contains('الكترونيات') ||
        iconKey.contains('كهرب')) {
      return Icons.electrical_services;
    }

    // أي كاتيجوري مش متعرّفة هتستخدم أيقونة محل عامة
    return Icons.storefront;
  }

  Widget _buildShopsList(AdminShopsLoaded state) {
    final query = _searchController.text.trim().toLowerCase();

    // فلترة محلية باسم المحل أو رقم الهاتف
    final filteredShops = state.shops.where((shop) {
      if (query.isEmpty) return true;

      final name = shop.displayName.toLowerCase();
      final phone = (shop.phone ?? '').toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();

    if (state.shops.isEmpty) {
      return const AppEmptyState(
        icon: Icons.storefront_outlined,
        title: "لا يوجد محلات",
        description: 'لم يتم تسجيل أي محلات بعد',
      );
    }

    if (filteredShops.isEmpty) {
      return const AppEmptyState(
        icon: Icons.search_off,
        title: "لا توجد نتائج",
        description: 'جرّب البحث باسم أو رقم مختلف',
      );
    }

    final showLoaderAtEnd = state.hasMore && query.isEmpty;

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadShops(),
      color: AppColors.primary,
      backgroundColor: Colors.transparent,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: filteredShops.length + (showLoaderAtEnd ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredShops.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final shop = filteredShops[index];
          return _ShopCard(
            shop: shop,
            icon: _getCategoryIconForShop(shop),
            onEdit: () => _openEditShopForm(context, shop),
          );
        },
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final VoidCallback onEdit;
  final IconData icon;

  const _ShopCard({
    required this.shop,
    required this.onEdit,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor =
        shop.isActive ? AppColors.secondary : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      // كارت داكن بنفس روح كروت لوحة التحكم / شاشة المستخدمين
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        color: const Color(0xFF0B1722),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.22),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        // خلفية الكارت نفسها داكنة عشان ما يبقاش فيه أي أبيض من AppCard
        backgroundColor: const Color(0xFF0B1722),
        borderColor: Colors.transparent,
        onTap: () => _showDetails(context),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Glowing icon
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 52.r,
                      height: 52.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            baseColor.withValues(alpha: 0.18),
                            baseColor.withValues(alpha: 0.08),
                          ],
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
                       icon,
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
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              shop.displayName,
                              style: TextStyle(
                                fontFamily: AppTextStyles.fontFamily,
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(left: 8.w),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: IconButton(
                              onPressed: onEdit,
                              tooltip: 'تعديل بيانات المحل',
                              icon: Icon(
                                Icons.edit_rounded,
                                size: 20.r,
                              ),
                              color: AppColors.primary,
                              padding: EdgeInsets.all(8.r),
                              constraints: BoxConstraints(
                                minWidth: 36.r,
                                minHeight: 36.r,
                              ),
                            ),
                          ),
                          _ShopStatusBadge(
                            isActive: shop.isActive,
                            isOpen: shop.isOpen,
                          ),
                        ],
                      ),
                      if (shop.phone != null && shop.phone!.isNotEmpty) ...[
                        SizedBox(height: 4.h),
                        Text(
                          Formatters.formatPhone(shop.phone!),
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 12.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Divider(
              color: Colors.white.withValues(alpha: 0.12),
              height: 1,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.percent,
                    label: 'العمولة',
                    value: Formatters.formatPercentage(shop.commissionRate),
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.shopping_bag_outlined,
                    label: 'الحد الأدنى',
                    value: shop.minOrderAmount > 0
                        ? Formatters.formatCurrency(shop.minOrderAmount)
                        : 'لا يوجد',
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.h),
            _InfoItem(
              icon: Icons.calendar_today_outlined,
              label: "تاريخ التسجيل",
              value: Formatters.formatDate(shop.createdAt),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      elevation: 0,
      builder: (ctx) {
        return Align(
          alignment: Alignment.bottomCenter,
          child: _GlassBottomSheet(
            child: _ShopDetailsSheet(shop: shop),
          ),
        );
      },
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16.r,
          color: Colors.white.withValues(alpha: 0.8),
        ),
        SizedBox(width: 4.w),
        Text(
          "$label: ",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.sp,
            color: Colors.white,
          ),
        ),
        SizedBox(width: 4.w),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

class _ShopDetailsSheet extends StatelessWidget {
  final Shop shop;
  const _ShopDetailsSheet({required this.shop});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
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
                  width: 48.w,
                  height: 5.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.secondary.withValues(alpha: 0.95),
                          AppColors.secondary.withValues(alpha: 0.75),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color:
                              AppColors.secondary.withValues(alpha: 0.5),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.storefront,
                      color: Colors.white,
                      size: 32.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          shop.displayName,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        _ShopStatusBadge(
                          isActive: shop.isActive,
                          isOpen: shop.isOpen,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _DetailRow(
                label: 'رقم الهاتف',
                value: shop.phone != null && shop.phone!.isNotEmpty
                    ? Formatters.formatPhone(shop.phone!)
                    : '-',
              ),
              _DetailRow(
                label: 'العنوان',
                value: shop.address ?? '-',
              ),
              _DetailRow(
                label: 'نسبة العمولة',
                value: Formatters.formatPercentage(shop.commissionRate),
              ),
              _DetailRow(
                label: 'الحد الأدنى للطلب',
                value: shop.minOrderAmount > 0
                    ? Formatters.formatCurrency(shop.minOrderAmount)
                    : 'لا يوجد',
              ),
              _DetailRow(
                label: 'تاريخ التسجيل',
                value: Formatters.formatDate(shop.createdAt),
              ),
              _DetailRow(
                label: 'آخر تحديث',
                value: Formatters.formatDate(shop.updatedAt),
              ),
              SizedBox(height: 24.h),
              if (shop.description != null && shop.description!.isNotEmpty) ...[
                Text(
                  "الوصف",
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  shop.description!,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: Colors.white,
                  ),
                ),
              ],
              SizedBox(height: 32.h),
              // Edit button in details sheet
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context); // Close details sheet
                    // Get the parent context and call edit method
                    final parentState = context.findAncestorStateOfType<_AdminShopViewState>();
                    if (parentState != null) {
                      parentState._openEditShopForm(parentState.context, shop);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  icon: Icon(
                    Icons.edit_rounded,
                    size: 20.r,
                    color: Colors.white,
                  ),
                  label: Text(
                    'تعديل بيانات المحل',
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
        );
      },
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                color: Colors.white,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopStatusBadge extends StatelessWidget {
  final bool isActive;
  final bool isOpen;
  const _ShopStatusBadge({required this.isActive, required this.isOpen});
  @override
  Widget build(BuildContext context) {
    String label;
    Color color;

    if (!isActive) {
      label = 'معطل';
      color = AppColors.error;
    } else if (isOpen) {
      label = 'مفتوح';
      color = AppColors.success;
    } else {
      label = 'مغلق';
      color = AppColors.warning;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.18),
            color.withValues(alpha: 0.30),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.45),
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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Soft glowing background orb
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

/// Floating luxury FAB (matches admin/categories/orders identity)
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
              'محل جديد',
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
