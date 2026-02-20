import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/rider.dart';
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

class AdminRidersScreen extends StatelessWidget {
  const AdminRidersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AdminCubit>()..loadRiders(),
      child: const _AdminRidersView(),
    );
  }
}

class _AdminRidersView extends StatefulWidget {
  const _AdminRidersView();

  @override
  State<_AdminRidersView> createState() => _AdminRidersViewState();
}

class _AdminRidersViewState extends State<_AdminRidersView> {
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
      if (state is AdminRidersLoaded && state.hasMore) {
        context.read<AdminCubit>().loadMoreRiders();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AdminShell(
      title: 'إدارة السائقين',
      currentRoute: RouteNames.adminRiders,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openRiderForm(context),
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
                    onRetry: () => context.read<AdminCubit>().loadRiders(),
                  );
                }
                if (state is AdminRidersLoaded) {
                  return _buildRidersList(state);
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
        hint: 'بحث باسم السائق أو رقم الهاتف...',
        onChanged: (value) {
          // فلترة محلية على البيانات اللي جاية من الـ API بدون استدعاء جديد للسيرفر
          setState(() {});
        },
      ),
    );
  }

  void _openRiderForm(BuildContext context, [Rider? rider]) {
    final isEdit = rider != null;

    final nameController = TextEditingController(text: rider?.fullName ?? '');
    final phoneController = TextEditingController(text: rider?.phone ?? '');
    final deliveryFeeController = TextEditingController(
      text: rider != null ? rider.deliveryFee.toStringAsFixed(0) : '10',
    );

    // سيتم استخدام هذه الحقول فقط عند إنشاء سائق جديد (حساب المستخدم)
    final userNameController =
        TextEditingController(text: rider?.fullName ?? '');
    final userPhoneController =
        TextEditingController(text: rider?.phone ?? '');
    final userPasswordController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
            top: 24.h,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              final formKey = GlobalKey<FormState>();
              return Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
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
                        isEdit ? 'تعديل بيانات السائق' : 'إضافة سائق جديد',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppTextField(
                        controller: nameController,
                        label: 'اسم السائق',
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'الاسم مطلوب';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      AppTextField(
                        controller: phoneController,
                        label: 'رقم الهاتف',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'رقم الهاتف مطلوب';
                          }
                          if (value.trim().length < 8) {
                            return 'رقم هاتف غير صالح';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 12.h),
                      AppTextField(
                        controller: deliveryFeeController,
                        label: 'أجرة التوصيل (جنيه)',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'أجرة التوصيل مطلوبة';
                          }
                          final fee = double.tryParse(value.trim());
                          if (fee == null || fee <= 0) {
                            return 'أدخل قيمة صحيحة';
                          }
                          return null;
                        },
                      ),
                      if (!isEdit) ...[
                        SizedBox(height: 20.h),
                        Text(
                          'بيانات حساب المستخدم للسائق',
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        AppTextField(
                          controller: userNameController,
                          label: 'اسم المستخدم',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'الاسم مطلوب';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          controller: userPhoneController,
                          label: 'رقم هاتف المستخدم',
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'رقم الهاتف مطلوب';
                            }
                            if (value.trim().length < 8) {
                              return 'رقم هاتف غير صالح';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 12.h),
                        AppTextField(
                          controller: userPasswordController,
                          label: 'كلمة المرور المبدئية',
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'كلمة المرور مطلوبة';
                            }
                            final pwd = value.trim();
                            if (pwd.length < 8) {
                              return 'على الأقل 8 حروف';
                            }
                            if (!RegExp(r'[A-Z]').hasMatch(pwd) ||
                                !RegExp(r'[a-z]').hasMatch(pwd) ||
                                !RegExp(r'[0-9]').hasMatch(pwd)) {
                              return 'لابد أن تحتوي على حرف كبير وصغير ورقم';
                            }
                            return null;
                          },
                        ),
                      ],
                      SizedBox(height: 24.h),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) {
                              return;
                            }

                            final fee =
                                double.parse(deliveryFeeController.text.trim());

                            final payload = <String, dynamic>{
                              'rider': {
                                'full_name': nameController.text.trim(),
                                'phone': phoneController.text.trim(),
                                'delivery_fee': fee,
                              },
                            };

                            if (!isEdit) {
                              payload['user'] = {
                                'name': userNameController.text.trim(),
                                'phone': userPhoneController.text.trim(),
                                'password': userPasswordController.text.trim(),
                              };
                            }

                            final cubit = context.read<AdminCubit>();
                            if (isEdit) {
                              await cubit.updateRiderAsAdmin(
                                riderId: rider!.id,
                                payload: payload,
                              );
                            } else {
                              await cubit.createRiderAsAdmin(
                                payload: payload,
                              );
                            }

                            if (!context.mounted) return;
                            Navigator.of(context).pop();

                            // لو الحالة الحالية ليست خطأ، اعتبر العملية نجحت واعرض رسالة نجاح
                            final currentState = cubit.state;
                            if (currentState is! AdminError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    isEdit
                                        ? 'تم تحديث بيانات السائق بنجاح'
                                        : 'تم إضافة السائق بنجاح',
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
                            isEdit ? 'حفظ التعديلات' : 'إضافة السائق',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRidersList(AdminRidersLoaded state) {
    final query = _searchController.text.trim().toLowerCase();

    // فلترة محلية باسم السائق أو رقم الهاتف
    final filteredRiders = state.riders.where((rider) {
      if (query.isEmpty) return true;

      final name = rider.fullName.toLowerCase();
      final phone = rider.phone.toLowerCase();

      return name.contains(query) || phone.contains(query);
    }).toList();

    if (state.riders.isEmpty) {
      return const AppEmptyState.deliveries(
        title: 'لا يوجد سائقين',
        description: "لم يتم تسجيل أي سائقين بعد",
      );
    }

    if (filteredRiders.isEmpty) {
      return const AppEmptyState.deliveries(
        title: 'لا توجد نتائج',
        description: "جرّب البحث باسم أو رقم مختلف",
      );
    }

    final showLoaderAtEnd = state.hasMore && query.isEmpty;

    return RefreshIndicator(
      onRefresh: () async => context.read<AdminCubit>().loadRiders(),
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: filteredRiders.length + (showLoaderAtEnd ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == filteredRiders.length) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final rider = filteredRiders[index];
          return _RiderCard(
            rider: rider,
            onEdit: () => _openRiderForm(context, rider),
          );
        },
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  final Rider rider;
  final VoidCallback onEdit;
  const _RiderCard({required this.rider, required this.onEdit});
  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: EdgeInsets.only(bottom: 12.h),
      borderColor: rider.isActive ? null : AppColors.error,
      onTap: () => _showDetails(context),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.delivery_dining,
              color: AppColors.info,
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
                        rider.fullName,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ) 
                    ),
                    _ActiveBadge(isActive: rider.isActive)
                  ],
                ),
                SizedBox(height: 4.h,),
                Row(
                  children: [
                    if (rider.phone.isNotEmpty)...[
                      Icon(
                        Icons.phone,
                        size: 14.r,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(width: 4.w,),
                      Text(
                        Formatters.formatPhone(rider.phone),
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      )
                    ],
                    const Spacer(),
                    IconButton(
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit, size: 18),
                      color: AppColors.primary,
                    ),
                    _AvailabilityBadge(isAvailable: rider.isAvailable),
                  ],
                ),
                SizedBox(height: 6.h,),
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 14.r,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w,),
                    Text(
                      'توصيلات: ${rider.totalDeliveries}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(width: 12.w,),
                    Icon(
                      Icons.payment_outlined,
                      size: 14.r,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(width: 4.w,),
                    Text(
                      'أجرة: ${Formatters.formatCurrency(rider.deliveryFee)}',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.sp,
                        color: AppColors.textSecondary,
                      ),
                    )
                  ],
                ),
                SizedBox(height: 4.h,),
                Text(
                  'انضم ${Formatters.formatRelativeTime(rider.createdAt)}',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                )
              ],
            ) 
          ),
          Icon(
            Icons.chevron_right,
            color: AppColors.textHint,
            size: 20.r,
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
      builder: (ctx) => _RiderDetailsSheet(rider: rider),
    );
  }
}

class _RiderDetailsSheet extends StatelessWidget {
  final Rider rider;
  const _RiderDetailsSheet({required this.rider});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.55,
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
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Icon(
                      Icons.delivery_dining,
                      color: AppColors.info,
                      size: 32.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          rider.fullName,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            _ActiveBadge(isActive: rider.isActive),
                            SizedBox(width: 8.w),
                            _AvailabilityBadge(isAvailable: rider.isAvailable),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _DetailRow(
                label: 'رقم الهاتف',
                value: Formatters.formatPhone(rider.phone),
              ),
              _DetailRow(
                label: 'أجرة التوصيل',
                value: Formatters.formatCurrency(rider.deliveryFee),
              ),
              _DetailRow(
                label: 'إجمالي التوصيلات',
                value: rider.totalDeliveries.toString(),
              ),
              _DetailRow(
                label: 'تاريخ التسجيل',
                value: Formatters.formatDate(rider.createdAt),
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
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityBadge extends StatelessWidget {
  final bool isAvailable;
  const _AvailabilityBadge({required this.isAvailable});

  @override
  Widget build(BuildContext context) {
    final color = isAvailable ? AppColors.success : AppColors.textSecondary;
    final label = isAvailable ? 'متاح' : 'غير متاح';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.schedule,
            size: 12.r,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool isActive;
  const _ActiveBadge({required this.isActive});

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.success : AppColors.error;
    final label = isActive ? 'نشط' : 'غير نشط';

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
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
