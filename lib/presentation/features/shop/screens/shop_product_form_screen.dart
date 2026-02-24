import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/domain/entities/product.dart';
import 'package:baladi/presentation/common/widgets/app_button.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopProductFormScreen extends StatefulWidget {
  final Product? product; // null = إنشاء، غير كده = تعديل

  const ShopProductFormScreen({super.key, this.product});

  @override
  State<ShopProductFormScreen> createState() => _ShopProductFormScreenState();
}

class _ShopProductFormScreenState extends State<ShopProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nameArController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _imageUrlController;

  bool get isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameController = TextEditingController(text: p?.name ?? '');
    _nameArController = TextEditingController(text: p?.nameAr ?? '');
    _descriptionController = TextEditingController(text: p?.description ?? '');
    _priceController =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _imageUrlController = TextEditingController(text: p?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameArController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'تعديل منتج' : 'منتج جديد',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
      ),
      body: BlocConsumer<ShopManagementCubit, ShopManagementState>(
        listener: (context, state) {
          if (state is ShopManagementError) {
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
          if (state is ShopProductsLoaded && mounted) {
            Navigator.of(context).maybePop();
          }
        },
        builder: (context, state) {
          final isLoading = state is ShopProductActionLoading ||
              state is ShopManagementLoading;

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: AppCard(
                  padding: EdgeInsets.all(20.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          label: 'اسم المنتج (إنجليزي)',
                          controller: _nameController,
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'اسم المنتج مطلوب';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          label: 'اسم المنتج (عربي)',
                          controller: _nameArController,
                        ),
                        SizedBox(height: 12.h),
                        AppTextField.textArea(
                          label: 'الوصف',
                          controller: _descriptionController,
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          label: 'السعر (جنيه)',
                          controller: _priceController,
                          keyboardType:
                              const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'السعر مطلوب';
                            }
                            final parsed = double.tryParse(v.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'أدخل سعر صحيح أكبر من صفر';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          label: 'رابط الصورة (اختياري)',
                          controller: _imageUrlController,
                        ),
                        SizedBox(height: 24.h),
                        AppButton.primary(
                          text: isEdit ? 'حفظ التعديلات' : 'إضافة المنتج',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final cubit = context.read<ShopManagementCubit>();
    final price = double.parse(_priceController.text.trim());

    if (isEdit) {
      cubit.updateProduct(
        productId: widget.product!.id,
        name: _nameController.text.trim(),
        nameAr: _nameArController.text.trim().isEmpty
            ? null
            : _nameArController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );
    } else {
      cubit.createProduct(
        name: _nameController.text.trim(),
        nameAr: _nameArController.text.trim().isEmpty
            ? null
            : _nameArController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        price: price,
        imageUrl: _imageUrlController.text.trim().isEmpty
            ? null
            : _imageUrlController.text.trim(),
      );
    }
  }
}