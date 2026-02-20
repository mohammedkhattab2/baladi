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
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openCreateShopForm(context),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocConsumer<AdminCubit, AdminState>(
              listener: (context, state) {
                if (state is AdminError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        state.message,
                        style: TextStyle(fontFamily: AppTextStyles.fontFamily),
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
                  return AppErrorWidget(
                    message: state.message,
                    onRetry: () => context.read<AdminCubit>().loadShops(),
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
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: AppColors.surface,
      child: AppSearchField(
        controller: _searchController,
        hint: 'بحث باسم المحل أو رقم الهاتف...',
        onChanged: (value) {
          // فلترة محلية على البيانات اللي جاية من الـ API بدون استدعاء جديد
          setState(() {});
        },
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
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.w,
            right: 16.w,
            top: 16.h,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16.h,
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
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    isEdit ? 'تعديل بيانات المحل' : 'إضافة محل جديد',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 16.h),
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
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
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
                                  'category_id': categoryIdController.text.trim(),
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
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      borderColor: shop.isActive ? null : AppColors.error,
      onTap: () => _showDetails(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.storefront,
                  color: AppColors.secondary,
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
                          child: Text(
                            shop.displayName,
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
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
                          color: AppColors.primary,
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
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppColors.divider, height: 1),
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
          SizedBox(height: 4.h,),
          _InfoItem(
            icon: Icons.calendar_today_outlined, 
            label: "تاريخ التسجيل", 
            value: Formatters.formatDate(shop.createdAt)
            )
        ],
      ),
    );
  }

  void _showDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => _ShopDetailsSheet(shop: shop),
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
          color: AppColors.textSecondary,
        ),
        SizedBox(width: 4.w),
        Text(
          "$label: ",
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
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
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.storefront,
                      color: AppColors.secondary,
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
              _DetailRow(label: 'العنوان', value: shop.address ?? '-'),
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
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  shop.description!,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
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
            width: 12.w,
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 14.sp,
                color: AppColors.textSecondary,
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
                color: AppColors.textPrimary,
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTextStyles.fontFamily,
          fontSize: 10.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
