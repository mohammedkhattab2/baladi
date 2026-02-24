import 'package:baladi/core/di/injection.dart';
import 'package:baladi/core/theme/app_colors.dart';
import 'package:baladi/core/theme/app_text_styles.dart';
import 'package:baladi/core/utils/formatters.dart';
import 'package:baladi/core/result/result.dart';
import 'package:baladi/domain/entities/product.dart';
import 'package:baladi/domain/entities/shop.dart';
import 'package:baladi/domain/usecases/catalog/get_shop_products.dart';
import 'package:baladi/presentation/common/widgets/app_card.dart';
import 'package:baladi/presentation/common/widgets/empty_state.dart';
import 'package:baladi/presentation/common/widgets/error_widget.dart';
import 'package:baladi/presentation/common/widgets/loading_widget.dart';
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart';
import 'package:baladi/presentation/cubits/cart/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ShopDetailsScreen extends StatefulWidget {
  final String shopId;
  final Shop? initialShop; // لو جاي من CategoryShops بنبعت الـ Shop هنا

  const ShopDetailsScreen({
    super.key,
    required this.shopId,
    this.initialShop,
  });

  @override
  State<ShopDetailsScreen> createState() => _ShopDetailsScreenState();
}

class _ShopDetailsScreenState extends State<ShopDetailsScreen> {
  final _scrollController = ScrollController();

  final _getShopProducts = getIt<GetShopProducts>();

  List<Product> _products = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = false;
  int _currentPage = 1;
  String? _error;

  static const int _perPage = 20;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadFirstPage();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadFirstPage() async {
    setState(() {
      _loading = true;
      _error = null;
      _currentPage = 1;
    });

    final Result<List<Product>> result = await _getShopProducts(
      GetShopProductsParams(
        shopId: widget.shopId,
        page: 1,
        perPage: _perPage,
      ),
    );

    result.fold(
      onSuccess: (products) {
        setState(() {
          _products = products;
          _hasMore = products.length >= _perPage;
          _loading = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _error = failure.message;
          _loading = false;
        });
      },
    );
  }

  Future<void> _loadMore() async {
    setState(() {
      _loadingMore = true;
    });

    final nextPage = _currentPage + 1;

    final Result<List<Product>> result = await _getShopProducts(
      GetShopProductsParams(
        shopId: widget.shopId,
        page: nextPage,
        perPage: _perPage,
      ),
    );

    result.fold(
      onSuccess: (products) {
        setState(() {
          _products.addAll(products);
          _currentPage = nextPage;
          _hasMore = products.length >= _perPage;
          _loadingMore = false;
        });
      },
      onFailure: (failure) {
        setState(() {
          _error = failure.message;
          _loadingMore = false;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // نوفر CartCubit هنا عشان نقدر نضيف للسلة
    return BlocProvider(
      create: (_) => getIt<CartCubit>()..loadCart(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: Text(
            widget.initialShop?.displayName ?? 'تفاصيل المتجر',
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
        body: BlocListener<CartCubit, CartState>(
          listener: (context, state) {
            if (state is CartError) {
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
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: LoadingWidget());
    }

    if (_error != null && _products.isEmpty) {
      return AppErrorWidget(
        message: _error!,
        onRetry: _loadFirstPage,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFirstPage,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // هيدر المتجر
          SliverToBoxAdapter(
            child: _ShopHeader(shop: widget.initialShop),
          ),
          // المنتجات
          if (_products.isEmpty)
            const SliverToBoxAdapter(
              child: AppEmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'لا توجد منتجات متاحة',
                description: 'عند إضافة منتجات من المتجر ستظهر هنا.',
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
              sliver: SliverList.separated(
                itemBuilder: (context, index) {
                  if (index == _products.length && _loadingMore) {
                    return Padding(
                      padding: EdgeInsets.all(16.r),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  }
                  if (index >= _products.length) return const SizedBox.shrink();
                  final product = _products[index];
                  return _ProductCard(
                    product: product,
                    shopId: widget.shopId,
                  );
                },
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemCount: _products.length + (_loadingMore ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }
}

class _ShopHeader extends StatelessWidget {
  final Shop? shop;

  const _ShopHeader({this.shop});

  @override
  Widget build(BuildContext context) {
    if (shop == null) {
      // لو جاي من Ad من غير بيانات المتجر، نعرض هيدر بسيط
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        child: Text(
          'منتجات المتجر',
          style: TextStyle(
            fontFamily: AppTextStyles.fontFamily,
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      );
    }

    final isOpen = shop!.isOpen && shop!.isActive;
    final minOrder = shop!.minOrderAmount;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
      child: AppCard(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // الاسم + حالة الفتح
            Row(
              children: [
                Container(
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha:  0.08),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.storefront,
                    color: AppColors.primary,
                    size: 22.r,
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop!.displayName,
                        style: TextStyle(
                          fontFamily: AppTextStyles.fontFamily,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (shop!.address != null &&
                          shop!.address!.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Text(
                          shop!.address!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: AppTextStyles.fontFamily,
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                _OpenStatusChip(isOpen: isOpen),
              ],
            ),
            if (shop!.description != null &&
                shop!.description!.trim().isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                shop!.description!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTextStyles.fontFamily,
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
            if (minOrder > 0) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16.r,
                    color: AppColors.textSecondary,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'حد أدنى للطلب: ${Formatters.formatCurrency(minOrder)}',
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _OpenStatusChip extends StatelessWidget {
  final bool isOpen;

  const _OpenStatusChip({required this.isOpen});

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? AppColors.success : AppColors.textSecondary;
    final label = isOpen ? 'مفتوح الآن' : 'مغلق حالياً';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOpen ? Icons.check_circle : Icons.schedule,
            size: 12.r,
            color: color,
          ),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTextStyles.fontFamily,
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Product product;
  final String shopId;

  const _ProductCard({
    required this.product,
    required this.shopId,
  });

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();
    final isAvailable = product.isAvailable;

    return AppCard(
      child: Row(
        children: [
          // صورة / أيقونة
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.fastfood_outlined,
              color: AppColors.primary,
              size: 24.r,
            ),
          ),
          SizedBox(width: 10.w),

          // معلومات المنتج
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName,
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    product.description!,
                    style: TextStyle(
                      fontFamily: AppTextStyles.fontFamily,
                      fontSize: 11.sp,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                SizedBox(height: 4.h),
                Text(
                  Formatters.formatCurrency(product.price),
                  style: TextStyle(
                    fontFamily: AppTextStyles.fontFamily,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 8.w),

          // زر الإضافة للسلة
          ElevatedButton(
            onPressed: !isAvailable
                ? null
                : () async {
                    await cartCubit.addProduct(
                      product: product,
                      shopId: shopId,
                      quantity: 1,
                    );
                    // SnackBar بسيط للتأكيد
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم إضافة ${product.displayName} إلى السلة',
                            style: TextStyle(
                              fontFamily: AppTextStyles.fontFamily,
                            ),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    }
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  isAvailable ? AppColors.primary : AppColors.textHint,
              foregroundColor: AppColors.textOnPrimary,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              isAvailable ? 'إضافة' : 'غير متاح',
              style: TextStyle(
                fontFamily: AppTextStyles.fontFamily,
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}