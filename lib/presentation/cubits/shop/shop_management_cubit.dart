// Presentation - Shop management cubit.
//
// Manages shop owner state including dashboard, open/close status,
// product CRUD, orders, and settlements.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/enums/order_status.dart';
import '../../../domain/repositories/shop_repository.dart';
import '../../../domain/usecases/order/update_order_status.dart';
import '../../../domain/usecases/shop/get_shop_dashboard.dart';
import '../../../domain/usecases/shop/get_shop_orders.dart';
import '../../../domain/usecases/shop/get_shop_settlements.dart';
import '../../../domain/usecases/shop/manage_product.dart';
import 'shop_management_state.dart';

/// Cubit that manages all shop-owner operations.
///
/// Handles dashboard loading, shop open/close toggling, product CRUD,
/// order management (accept, prepare), and settlement viewing.
@injectable
class ShopManagementCubit extends Cubit<ShopManagementState> {
  final GetShopDashboard _getShopDashboard;
  final GetShopOrders _getShopOrders;
  final GetShopSettlements _getShopSettlements;
  final CreateProduct _createProduct;
  final UpdateProduct _updateProduct;
  final DeleteProduct _deleteProduct;
  final UpdateOrderStatus _updateOrderStatus;
  final ShopRepository _shopRepository;

  /// Creates a [ShopManagementCubit].
  ShopManagementCubit({
    required GetShopDashboard getShopDashboard,
    required GetShopOrders getShopOrders,
    required GetShopSettlements getShopSettlements,
    required CreateProduct createProduct,
    required UpdateProduct updateProduct,
    required DeleteProduct deleteProduct,
    required UpdateOrderStatus updateOrderStatus,
    required ShopRepository shopRepository,
  })  : _getShopDashboard = getShopDashboard,
        _getShopOrders = getShopOrders,
        _getShopSettlements = getShopSettlements,
        _createProduct = createProduct,
        _updateProduct = updateProduct,
        _deleteProduct = deleteProduct,
        _updateOrderStatus = updateOrderStatus,
        _shopRepository = shopRepository,
        super(const ShopManagementInitial());

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  /// Loads the shop profile and dashboard statistics.
  Future<void> loadDashboard() async {
    emit(const ShopManagementLoading());

    final results = await Future.wait([
      _shopRepository.getShopProfile(),
      _getShopDashboard(const NoParams()),
    ]);

    final profileResult = results[0] as Result;
    final dashboardResult = results[1] as Result;

    if (profileResult.isSuccess && dashboardResult.isSuccess) {
      emit(ShopDashboardLoaded(
        shop: profileResult.data,
        dashboard: dashboardResult.data,
      ));
    } else {
      final failure = profileResult.isFailure
          ? profileResult.failure
          : dashboardResult.failure;
      emit(ShopManagementError(message: failure!.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Shop Status (open/close)
  // ---------------------------------------------------------------------------

  /// Toggles the shop's open/closed status.
  ///
  /// - [isOpen]: Whether the shop should be open for orders.
  Future<void> toggleShopStatus({required bool isOpen}) async {
    final currentState = state;
    if (currentState is ShopDashboardLoaded) {
      emit(ShopStatusToggling(shop: currentState.shop));
    }

    final result = await _shopRepository.updateShopStatus(isOpen: isOpen);

    result.fold(
      onSuccess: (_) async {
        // Reload dashboard to reflect new status
        await loadDashboard();
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Products
  // ---------------------------------------------------------------------------

  /// Loads the shop's own products.
  Future<void> loadProducts({int perPage = AppConstants.defaultPageSize}) async {
    emit(const ShopManagementLoading());

    final result = await _shopRepository.getOwnProducts(
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (products) {
        emit(ShopProductsLoaded(
          products: products,
          currentPage: 1,
          hasMore: products.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Loads more products (next page).
  Future<void> loadMoreProducts({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! ShopProductsLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;
    emit(ShopProductActionLoading(products: currentState.products));

    final result = await _shopRepository.getOwnProducts(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newProducts) {
        emit(ShopProductsLoaded(
          products: [...currentState.products, ...newProducts],
          currentPage: nextPage,
          hasMore: newProducts.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Creates a new product.
  Future<void> createProduct({
    required String name,
    String? nameAr,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    final existingProducts = _currentProducts;
    if (existingProducts != null) {
      emit(ShopProductActionLoading(products: existingProducts));
    } else {
      emit(const ShopManagementLoading());
    }

    final result = await _createProduct(CreateProductParams(
      name: name,
      nameAr: nameAr,
      description: description,
      price: price,
      imageUrl: imageUrl,
    ));

    result.fold(
      onSuccess: (_) async {
        await loadProducts();
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Updates an existing product.
  Future<void> updateProduct({
    required String productId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    final existingProducts = _currentProducts;
    if (existingProducts != null) {
      emit(ShopProductActionLoading(products: existingProducts));
    } else {
      emit(const ShopManagementLoading());
    }

    final result = await _updateProduct(UpdateProductParams(
      productId: productId,
      name: name,
      nameAr: nameAr,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
    ));

    result.fold(
      onSuccess: (_) async {
        await loadProducts();
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Deletes a product.
  Future<void> deleteProduct(String productId) async {
    final existingProducts = _currentProducts;
    if (existingProducts != null) {
      emit(ShopProductActionLoading(products: existingProducts));
    } else {
      emit(const ShopManagementLoading());
    }

    final result = await _deleteProduct(
      DeleteProductParams(productId: productId),
    );

    result.fold(
      onSuccess: (_) async {
        await loadProducts();
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  /// Loads shop orders, optionally filtered by status.
  Future<void> loadOrders({
    OrderStatus? status,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const ShopManagementLoading());

    final result = await _getShopOrders(GetShopOrdersParams(
      status: status,
      page: 1,
      perPage: perPage,
    ));

    result.fold(
      onSuccess: (orders) {
        emit(ShopOrdersLoaded(
          orders: orders,
          currentPage: 1,
          hasMore: orders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Loads more shop orders (next page).
  Future<void> loadMoreOrders({
    OrderStatus? status,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! ShopOrdersLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _getShopOrders(GetShopOrdersParams(
      status: status,
      page: nextPage,
      perPage: perPage,
    ));

    result.fold(
      onSuccess: (newOrders) {
        emit(ShopOrdersLoaded(
          orders: [...currentState.orders, ...newOrders],
          currentPage: nextPage,
          hasMore: newOrders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Accepts an incoming order (transitions to [OrderStatus.accepted]).
  Future<void> acceptOrder(String orderId) async {
    final result = await _updateOrderStatus(
      UpdateOrderStatusParams(
        orderId: orderId,
        newStatus: OrderStatus.accepted,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        await loadOrders();
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Marks an order as preparing (transitions to [OrderStatus.preparing]).
  Future<void> markPreparing(String orderId) async {
    final result = await _updateOrderStatus(
      UpdateOrderStatusParams(
        orderId: orderId,
        newStatus: OrderStatus.preparing,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        await loadOrders();
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Settlements
  // ---------------------------------------------------------------------------

  /// Loads the shop's settlement history.
  Future<void> loadSettlements({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const ShopManagementLoading());

    final result = await _getShopSettlements(
      GetShopSettlementsParams(page: 1, perPage: perPage),
    );

    result.fold(
      onSuccess: (settlements) {
        emit(ShopSettlementsLoaded(
          settlements: settlements,
          currentPage: 1,
          hasMore: settlements.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  /// Loads more settlements (next page).
  Future<void> loadMoreSettlements({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! ShopSettlementsLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _getShopSettlements(
      GetShopSettlementsParams(page: nextPage, perPage: perPage),
    );

    result.fold(
      onSuccess: (newSettlements) {
        emit(ShopSettlementsLoaded(
          settlements: [...currentState.settlements, ...newSettlements],
          currentPage: nextPage,
          hasMore: newSettlements.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(ShopManagementError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Extracts current products list from current state, if any.
  List<Product>? get _currentProducts {
    final s = state;
    if (s is ShopProductsLoaded) return s.products;
    if (s is ShopProductActionLoading) return s.products;
    return null;
  }
}