import 'package:baladi/core/di/injection_container.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
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
      if (state is AdminShopsLoaded && state.hasMore) {
        context.read<AdminCubit>().loadMoreShops();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return AdminShell(
      title: "إدارة المحلات",
      currentRoute: RouteNames.adminShops,
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
          // TODO: ممكن تعمل فلترة محلية هنا لو حبيت
        },
      ),
    );
  }

  Widget _buildShopsList(AdminShopsLoaded state) {
    if (state.shops.isEmpty) {
      return const AppEmptyState(
        icon: Icons.storefront_outlined,
        title: "لا يوجد محلات",
        description: 'لم يتم تسجيل أي محلات بعد',
      );
    }
    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadShops(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: state.shops.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == state.shops.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            );
          }
          final shop = state.shops[index];
          return _ShopCard(shop: shop);
        },
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  const _ShopCard({required this.shop});
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
