import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/presentation/common/widgets/app_button.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/app_text_field.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart';
import 'package:baladi/presentation/cubits/admin/admin_state.dart';
import 'package:baladi/presentation/features/admin/shell/admin_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AdminPointsScreen extends StatelessWidget {
  const AdminPointsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>(),
      child: const _AdminPointsView(),
    );
  }
}

class _AdminPointsView extends StatefulWidget {
  const _AdminPointsView();

  @override
  State<_AdminPointsView> createState() => _AdminPointsViewState();
}

class _AdminPointsViewState extends State<_AdminPointsView> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _pointsController = TextEditingController();
  final _reasonController = TextEditingController();

  /// true = إضافة نقاط، false = خصم نقاط
  bool _isAdd = true;

  @override
  void dispose() {
    _customerIdController.dispose();
    _pointsController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      currentRoute: RouteNames.adminPoints,
      title: 'إدارة النقاط',
      child: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminPointsAdjusted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'تم تعديل نقاط العميل بنجاح',
                  style: TextStyle(fontFamily: AppTextStyles.fontFamily),
                ),
                backgroundColor: AppColors.success,
              ),
            );
            _formKey.currentState?.reset();
            _pointsController.clear();
            _reasonController.clear();
          } else if (state is AdminError) {
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
          final isLoading = state is AdminActionLoading;

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
                        Text(
                          'تعديل نقاط عميل',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'يمكنك إضافة أو خصم نقاط من رصيد عميل لأي سبب إداري (تعويض، خطأ في الطلب، إلخ).',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 13.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 20.h),

                        // Customer ID
                        AppTextField(
                          label: 'معرّف العميل (customerId)',
                          hint: 'example: cst_12345',
                          controller: _customerIdController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'حقل معرّف العميل مطلوب';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Add / Subtract toggle
                        Text(
                          'نوع العملية',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            _TypeChip(
                              label: 'إضافة نقاط',
                              isSelected: _isAdd,
                              color: AppColors.success,
                              onTap: () => setState(() => _isAdd = true),
                            ),
                            SizedBox(width: 8.w),
                            _TypeChip(
                              label: 'خصم نقاط',
                              isSelected: !_isAdd,
                              color: AppColors.error,
                              onTap: () => setState(() => _isAdd = false),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),

                        // Points amount
                        AppTextField(
                          label: 'عدد النقاط',
                          hint: 'مثال: 10',
                          controller: _pointsController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'برجاء إدخال عدد النقاط';
                            }
                            final parsed = int.tryParse(value.trim());
                            if (parsed == null || parsed <= 0) {
                              return 'أدخل رقم صحيح أكبر من صفر';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),

                        // Reason
                        AppTextField.textArea(
                          label: 'السبب',
                          hint: 'مثال: تعويض عن مشكلة في الطلب، مكافأة خاصة، ...',
                          controller: _reasonController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'السبب مطلوب للتوثيق';
                            }
                            if (value.trim().length < 5) {
                              return 'السبب قصير جداً';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 24.h),

                        if (state is AdminError) ...[
                          AppErrorWidget(
                            message: state.message,
                            onRetry: null,
                          ),
                          SizedBox(height: 16.h),
                        ],

                        AppButton.primary(
                          text: 'حفظ التعديل',
                          isLoading: isLoading,
                          onPressed: isLoading ? null : () => _submit(context),
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

  void _submit(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;

    final points = int.parse(_pointsController.text.trim());
    final signedPoints = _isAdd ? points : -points;

    context.read<AdminCubit>().adjustPoints(
          customerId: _customerIdController.text.trim(),
          points: signedPoints,
          reason: _reasonController.text.trim(),
        );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isSelected ? color : AppColors.surfaceVariant;
    final textColor = isSelected ? AppColors.textOnPrimary : AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? color : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 14.r,
              color: textColor,
            ),
            SizedBox(width: 6.w),
            Text(
              label,
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}