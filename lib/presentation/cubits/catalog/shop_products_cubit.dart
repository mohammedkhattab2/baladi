// Presentation - Shop products cubit.
//
// Manages shop products state including fetching products
// for a specific shop with pagination support.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/usecases/catalog/get_shop_products.dart';
import 'shop_products_state.dart';

/// Cubit that manages the shop products lifecycle.
///
/// Handles loading products for a given shop with pagination.
@injectable
class ShopProductsCubit extends Cubit<ShopProductsState> {
  final GetShopProducts _getShopProducts;

  /// Creates a [ShopProductsCubit].
  ShopProductsCubit({
    required GetShopProducts getShopProducts,
  })  : _getShopProducts = getShopProducts,
        super(const ShopProductsInitial());

  /// Fetches the first page of products for a shop.
  Future<void> loadProducts({
    required String shopId,
    int perPage = 20,
  }) async {
    emit(const ShopProductsLoading());
    final result = await _getShopProducts(GetShopProductsParams(
      shopId: shopId,
      page: 1,
      perPage: perPage,
    ));
    result.fold(
      onSuccess: (products) {
        emit(ShopProductsLoaded(
          products: products,
          currentPage: 1,
          hasMore: products.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopProductsError(message: failure.message));
      },
    );
  }

  /// Loads the next page of products for pagination.
  Future<void> loadMore({
    required String shopId,
    int perPage = 20,
  }) async {
    final currentProducts = _currentProducts;
    final currentPage = _currentPage;
    emit(ShopProductsLoadingMore(products: currentProducts));
    final result = await _getShopProducts(GetShopProductsParams(
      shopId: shopId,
      page: currentPage + 1,
      perPage: perPage,
    ));
    result.fold(
      onSuccess: (newProducts) {
        final allProducts = [...currentProducts, ...newProducts];
        emit(ShopProductsLoaded(
          products: allProducts,
          currentPage: currentPage + 1,
          hasMore: newProducts.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopProductsError(
          message: failure.message,
          products: currentProducts,
        ));
      },
    );
  }

  /// Extracts current products from state if available.
  List<Product> get _currentProducts {
    final s = state;
    if (s is ShopProductsLoaded) return s.products;
    if (s is ShopProductsLoadingMore) return s.products;
    if (s is ShopProductsError) return s.products;
    return [];
  }

  /// Extracts current page from state if available.
  int get _currentPage {
    final s = state;
    if (s is ShopProductsLoaded) return s.currentPage;
    return 1;
  }
}