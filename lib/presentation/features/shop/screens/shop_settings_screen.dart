import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/shop.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart';
import 'package:baladi/presentation/cubits/shop/shop_management_state.dart';
import 'package:baladi/presentation/features/shop/shell/shop_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopSettingsScreen extends StatelessWidget {
  const ShopSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ShopManagementCubit>()..loadDashboard(),
      child: const _ShopSettingsView(),
    );
  }
}

class _ShopSettingsView extends StatelessWidget {
  const _ShopSettingsView();

  @override
  Widget build(BuildContext context) {
    return ShopShell(
      currentRoute: RouteNames.shopSettings,
      title: 'إعدادات المتجر',
      child: BlocConsumer<ShopManagementCubit, ShopManagementState>(
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
        },
        builder: (context, state) {
          if (state is ShopManagementLoading ||
              state is ShopStatusToggling) {
            return const Center(child: LoadingWidget());
          }
          if (state is ShopManagementError) {
            return AppErrorWidget(
              message: state.message,
              onRetry: () =>
                  context.read<ShopManagementCubit>().loadDashboard(),
            );
          }
          if (state is ShopDashboardLoaded) {
            return _SettingsContent(shop: state.shop);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _SettingsContent extends StatelessWidget {
  final Shop shop;

  const _SettingsContent({required this.shop});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: AppCard(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'بيانات المتجر',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                _DetailRow(label: 'اسم المتجر', value: shop.displayName),
                _DetailRow(
                  label: 'رقم الهاتف',
                  value: shop.phone ?? '-',
                ),
                _DetailRow(
                  label: 'العنوان',
                  value: shop.address ?? '-',
                ),
                _DetailRow(
                  label: 'معرّف التصنيف',
                  value: shop.categoryId,
                ),
                SizedBox(height: 12.h),
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
                SizedBox(height: 12.h),
                _DetailRow(
                  label: 'حالة المتجر',
                  value: shop.isActive
                      ? (shop.isOpen ? 'نشط ويفتح للطلبات' : 'نشط لكن مغلق')
                      : 'معطل',
                ),
                SizedBox(height: 12.h),
                _DetailRow(
                  label: 'تاريخ الإنشاء',
                  value: Formatters.formatDateTime(shop.createdAt),
                ),
                _DetailRow(
                  label: 'آخر تحديث',
                  value: Formatters.formatDateTime(shop.updatedAt),
                ),
                if (shop.description != null &&
                    shop.description!.trim().isNotEmpty) ...[
                  SizedBox(height: 16.h),
                  Text(
                    'وصف المتجر',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    shop.description!,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                SizedBox(height: 8.h),
                const Divider(),
                SizedBox(height: 8.h),
                Text(
                  'تعديل بيانات المتجر (الاسم، الهاتف، العنوان، الوصف) هتحتاج API منفصل في الـ backend. حالياً الشاشة للعرض فقط.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140.w,
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