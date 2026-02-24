import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/router/route_names.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/domain/entities/order_item.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/cart/cart_state.dart';
import 'package:baladi/presentation/cubits/checkout/checkout_cubit.dart';
import 'package:baladi/presentation/cubits/checkout/checkout_state.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart';
import 'package:baladi/presentation/cubits/customer/customer_profile_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _summaryInitialized = false;
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _tryInitSummary(BuildContext context) {
    if (_summaryInitialized) return;

    final cartState = context.read<CartCubit>().state;
    final profileState = context.read<CustomerProfileCubit>().state;

    if (cartState is! CartLoaded ||
        cartState.isEmpty ||
        cartState.shopId == null ||
        profileState is! CustomerProfileLoaded) {
      return;
    }

    final customer = profileState.customer;
    final address = customer.addressText ?? 'بدون عنوان';

    context.read<CheckoutCubit>().initCheckout(
          shopId: cartState.shopId!,
          items: cartState.items,
          // TODO: عدل القيم دي حسب بيانات المتجر الفعلية لو متاحة
          deliveryFee: 0,          // مؤقتاً 0 – الباك إند يحسب الفعلي
          commissionRate: 0,       // مؤقتاً 0 – أو حسب إعداد المتجر
          deliveryAddress: address,
          deliveryLandmark: customer.landmark,
          customerNotes: null,
          isFreeDelivery: false,
        );

    _summaryInitialized = true;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<CartCubit>()..loadCart()),
        BlocProvider(create: (_) => getIt<CustomerProfileCubit>()..loadProfile()),
        BlocProvider(create: (_) => getIt<CheckoutCubit>()),
      ],
      child: Builder(
        builder: (context) {
          return Scaffold(
            backgroundColor: const Color(0xFFF8FAFC),
            appBar: AppBar(
              title: Text(
                'إتمام الطلب',
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
            body: MultiBlocListener(
              listeners: [
                BlocListener<CartCubit, CartState>(
                  listener: (context, _) => _tryInitSummary(context),
                ),
                BlocListener<CustomerProfileCubit, CustomerProfileState>(
                  listener: (context, _) => _tryInitSummary(context),
                ),
                BlocListener<CheckoutCubit, CheckoutState>(
                  listener: (context, state) {
                    if (state is CheckoutError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
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
                    if (state is CheckoutOrderPlaced) {
                      // امسح السلة واذهب لتفاصيل الطلب
                      context.read<CartCubit>().clearCart();
                      final orderId = state.order.id;
                      context.goNamed(
                        RouteNames.customerOrderDetails,
                        pathParameters: {'id': orderId},
                      );
                    }
                  },
                ),
              ],
              child: BlocBuilder<CheckoutCubit, CheckoutState>(
                builder: (context, state) {
                  if (state is CheckoutCalculating ||
                      state is CheckoutInitial) {
                    return const Center(child: LoadingWidget());
                  }
                  if (state is CheckoutError &&
                      !_summaryInitialized) {
                    return AppErrorWidget(
                      message: state.message,
                      onRetry: () => _tryInitSummary(context),
                    );
                  }
                  if (state is CheckoutSummaryLoaded) {
                    return _buildSummary(context, state);
                  }
                  if (state is CheckoutPlacingOrder) {
                    return const Center(child: LoadingWidget());
                  }
                  // لو حصل حالة غير متوقعة حاول تهيئة الملخص
                  _tryInitSummary(context);
                  return const Center(child: LoadingWidget());
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummary(BuildContext context, CheckoutSummaryLoaded s) {
    final cartState = context.read<CartCubit>().state;
    final List<OrderItem> items =
        cartState is CartLoaded ? cartState.items : [];

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // عنوان التوصيل
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: BlocBuilder<CustomerProfileCubit, CustomerProfileState>(
              builder: (context, state) {
                String address = s.deliveryAddress;
                String? landmark = s.deliveryLandmark;

                if (state is CustomerProfileLoaded) {
                  address = state.customer.addressText ?? address;
                  landmark = state.customer.landmark ?? landmark;
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'عنوان التوصيل',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      address,
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 13.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (landmark != null && landmark.isNotEmpty) ...[
                      SizedBox(height: 2.h),
                      Text(
                        landmark,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                    SizedBox(height: 8.h),
                    Text(
                      'يمكنك تعديل العنوان من صفحة الحساب.',
                      style: TextStyle(
                        fontFamily: AppTextStyles.fontFamily,
                        fontSize: 11.sp,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(height: 12.h),

          // ملخص الأسعار
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملخص الطلب',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                _SummaryRow(
                  label: 'الإجمالي الفرعي',
                  value: Formatters.formatCurrency(s.subtotal),
                ),
                _SummaryRow(
                  label: 'رسوم التوصيل',
                  value: s.isFreeDelivery
                      ? 'مجاني'
                      : Formatters.formatCurrency(s.deliveryFee),
                ),
                _SummaryRow(
                  label: 'خصم النقاط',
                  value: s.pointsDiscount > 0
                      ? '- ${Formatters.formatCurrency(s.pointsDiscount)}'
                      : '0',
                ),
                const Divider(),
                _SummaryRow(
                  label: 'الإجمالي المستحق',
                  value: Formatters.formatCurrency(s.totalAmount),
                  bold: true,
                ),
                SizedBox(height: 8.h),
                Text(
                  'سوف تكسب ${s.pointsToEarn} نقطة من هذا الطلب.',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // النقاط
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'استخدام النقاط',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'رصيد نقاطك: ${s.availablePoints} نقطة',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        s.pointsToRedeem > 0
                            ? 'سيتم استخدام ${s.pointsToRedeem} نقطة'
                            : 'لا يتم استخدام نقاط في هذا الطلب.',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: s.availablePoints == 0
                          ? null
                          : () async {
                              final used = await _showPointsDialog(
                                context,
                                s.availablePoints,
                                s.pointsToRedeem,
                              );
                              if (used != null) {
                                context
                                    .read<CheckoutCubit>()
                                    .updatePointsToRedeem(used);
                              }
                            },
                      child: Text(
                        'تعديل',
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 12.sp,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          // ملاحظات العميل
          AppCard(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ملاحظات للمتجر',
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'مثال: بدون بصل، أو أي تعليمات خاصة.',
                    hintStyle: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 12.sp,
                      color: AppColors.textHint,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    isDense: true,
                  ),
                  onChanged: (v) => context
                      .read<CheckoutCubit>()
                      .updateCustomerNotes(v.trim().isEmpty ? null : v.trim()),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // زر تأكيد الطلب
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: items.isEmpty
                  ? null
                  : () => context
                      .read<CheckoutCubit>()
                      .placeOrder(items: items),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
              child: Text(
                'تأكيد الطلب',
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<int?> _showPointsDialog(
    BuildContext context,
    int available,
    int current,
  ) async {
    final controller = TextEditingController(text: current > 0 ? '$current' : '');
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            'استخدام النقاط',
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'بحد أقصى $available نقطة',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final value = int.tryParse(controller.text.trim());
                if (value == null || value < 0) {
                  Navigator.of(ctx).pop();
                  return;
                }
                Navigator.of(ctx).pop(value);
              },
              child: const Text('تطبيق'),
            ),
          ],
        );
      },
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: AppTextStyles.fontFamily,
      fontSize: 13.sp,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: bold ? AppColors.textPrimary : AppColors.textSecondary,
    );
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.h),
      child: Row(
        children: [
          Text(label, style: style),
          const Spacer(),
          Text(value, style: style),
        ],
      ),
    );
  }
}