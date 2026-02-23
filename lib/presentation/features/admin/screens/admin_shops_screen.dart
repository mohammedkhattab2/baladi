import 'dart:ui';

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
    final ownerPhoneController = TextEditingController();
    final ownerPasswordController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      elevation: 0,
      builder: (ctx) {
        return Stack(
          children: [
            // Background gradient
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
            // Glow orbs
            Positioned(
              top: -40,
              left: -20,
              child: _GlowOrb(
                size: 140,
                color: AppColors.primary,
                opacity: 0.22,
              ),
            ),
            Positioned(
              bottom: 80,
              right: -16,
              child: _GlowOrb(
                size: 120,
                color: AppColors.secondary,
                opacity: 0.20,
              ),
            ),
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
                          // Header
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
                                      color: AppColors.primary
                                          .withValues(alpha: 0.45),
                                      blurRadius: 18,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  isEdit
                                      ? Icons.edit_rounded
                                      : Icons.storefront_rounded,
                                  color: Colors.white,
                                  size: 20.r,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                isEdit ? 'تعديل بيانات المحل' : 'إضافة محل جديد',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                isEdit
                                    ? 'قم بتحديث بيانات المحل الحالية'
                                    : 'أنشئ متجرًا جديداً للمنصة',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 12.sp,
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),
                          // Inner glass card for fields
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20.r),
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.14),
                                  Colors.white.withValues(alpha: 0.06),
                                ],
                              ),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.24),
                                width: 1.2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  blurRadius: 22,
                                  offset: const Offset(0, 12),
                                ),
                                BoxShadow(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.28),
                                  blurRadius: 28,
                                  offset: const Offset(0, 14),
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
                                AppTextField(
                    controller: nameController,
                    label: 'اسم المحل (بالإنجليزية)',
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
                    DropdownButtonFormField<String>(
                      initialValue: categoryIdController.text.isNotEmpty
                          ? categoryIdController.text
                          : null,
                      decoration: InputDecoration(
                        labelText: 'فئة المحل',
                        helperText: _categories.isEmpty
                            ? 'لا توجد تصنيفات متاحة، قم بإضافتها من شاشة التصنيفات'
                            : null,
                      ),
                      items: _categories
                          .map(
                            (c) => DropdownMenuItem<String>(
                              value: c.id,
                              child: Text(
                                c.nameAr,
                                style: TextStyle(
                                  fontFamily: AppTextStyles.fontFamily,
                                  fontSize: 14.sp,
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
                  ),
                  SizedBox(height: 8.h),
                  AppTextField(
                    controller: commissionController,
                    label: 'نسبة العمولة (%)',
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
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                  if (!isEdit) ...[
                    SizedBox(height: 16.h),
                    Text(
                      'بيانات صاحب المحل',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: ownerNameController,
                      label: 'اسم صاحب المحل',
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'من فضلك أدخل اسم صاحب المحل';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 8.h),
                    AppTextField(
                      controller: ownerPhoneController,
                      label: 'رقم جوال صاحب المحل',
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
                  SizedBox(height: 16.h),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(),
                                      style: TextButton.styleFrom(
                                        foregroundColor:
                                            Colors.white.withValues(alpha: 0.7),
                                      ),
                                      child: Text(
                                        'إلغاء',
                                        style: TextStyle(
                                          fontFamily: AppTextStyles.fontFamily,
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                            vertical: 12.h,
                                          ),
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16.r),
                                          ),
                                          backgroundColor: AppColors.primary,
                                          shadowColor: AppColors.primary
                                              .withValues(alpha: 0.3),
                                        ),
                                        onPressed: () async {
                            if (!formKey.currentState!.validate()) {
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
                              'username': ownerPhoneController.text.trim(),
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
                                        child: Text(
                                          isEdit ? 'تحديث' : 'حفظ',
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

  const _ShopCard({
    required this.shop,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor =
        shop.isActive ? AppColors.secondary : AppColors.error;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.03),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: baseColor.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: AppCard(
        margin: EdgeInsets.zero,
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
                        Icons.storefront,
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
                          IconButton(
                            onPressed: onEdit,
                            icon: const Icon(
                              Icons.edit,
                              size: 18,
                            ),
                            color: AppColors.primaryLight,
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
                            color: Colors.white.withValues(alpha: 0.8),
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
            color: Colors.white.withValues(alpha: 0.75),
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
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
              ],
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
                color: Colors.white.withValues(alpha: 0.75),
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
