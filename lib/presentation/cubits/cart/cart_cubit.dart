// Presentation - Cart cubit.
//
// Manages the shopping cart state including adding, updating,
// removing items, and clearing the cart. Cart is local-only
// (persisted via CartLocalDatasource).

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../data/datasources/local/cart_local_datasource.dart';
import '../../../data/models/order_item_model.dart';
import '../../../domain/entities/order_item.dart';
import '../../../domain/entities/product.dart';
import 'cart_state.dart';

/// Cubit that manages the shopping cart lifecycle.
///
/// Handles adding products to cart, updating quantities,
/// removing items, clearing the cart, and computing totals.
/// Cart is persisted locally via [CartLocalDatasource].
@injectable
class CartCubit extends Cubit<CartState> {
  final CartLocalDatasource _cartDatasource;

  /// Creates a [CartCubit].
  CartCubit({
    required CartLocalDatasource cartDatasource,
  })  : _cartDatasource = cartDatasource,
        super(const CartInitial());

  /// Loads the cart from local storage.
  Future<void> loadCart() async {
    emit(const CartLoading());
    try {
      final items = await _cartDatasource.getCartItems();
      final shopId = await _cartDatasource.getCartShopId();
      _emitLoaded(shopId: shopId, items: items);
    } catch (e) {
      emit(CartError(message: 'فشل في تحميل السلة'));
    }
  }

  /// Adds a product to the cart.
  ///
  /// If the cart already has items from a different shop, it will
  /// clear the cart first. If the product already exists, its
  /// quantity is incremented.
  Future<void> addProduct({
    required Product product,
    required String shopId,
    int quantity = 1,
    String? notes,
  }) async {
    try {
      final currentShopId = await _cartDatasource.getCartShopId();

      // If switching shops, clear existing cart.
      if (currentShopId != null && currentShopId != shopId) {
        await _cartDatasource.clearCart();
      }

      await _cartDatasource.setCartShopId(shopId);

      final existingItems = await _cartDatasource.getCartItems();
      final existingIndex = existingItems.indexWhere(
        (i) => i.productId == product.id,
      );

      if (existingIndex >= 0) {
        // Update existing item quantity.
        final existing = existingItems[existingIndex];
        final newQuantity = existing.quantity + quantity;
        await _cartDatasource.updateItemQuantity(product.id, newQuantity);
      } else {
        // Add new item.
        final item = OrderItemModel(
          id: 'cart_${product.id}',
          orderId: '',
          productId: product.id,
          productName: product.name,
          price: product.price,
          quantity: quantity,
          subtotal: product.price * quantity,
          notes: notes,
        );
        await _cartDatasource.addItem(item);
      }

      final updatedItems = await _cartDatasource.getCartItems();
      _emitLoaded(shopId: shopId, items: updatedItems);
    } catch (e) {
      emit(CartError(message: 'فشل في إضافة المنتج إلى السلة'));
    }
  }

  /// Updates the quantity of an item in the cart.
  Future<void> updateQuantity({
    required String productId,
    required int quantity,
  }) async {
    try {
      if (quantity <= 0) {
        await _cartDatasource.removeItem(productId);
      } else {
        await _cartDatasource.updateItemQuantity(productId, quantity);
      }
      final items = await _cartDatasource.getCartItems();
      final shopId = await _cartDatasource.getCartShopId();
      _emitLoaded(shopId: shopId, items: items);
    } catch (e) {
      emit(CartError(message: 'فشل في تحديث الكمية'));
    }
  }

  /// Removes an item from the cart.
  Future<void> removeItem(String productId) async {
    try {
      await _cartDatasource.removeItem(productId);
      final items = await _cartDatasource.getCartItems();
      final shopId = await _cartDatasource.getCartShopId();
      _emitLoaded(shopId: shopId, items: items);
    } catch (e) {
      emit(CartError(message: 'فشل في حذف المنتج من السلة'));
    }
  }

  /// Clears all items from the cart.
  Future<void> clearCart() async {
    try {
      await _cartDatasource.clearCart();
      _emitLoaded(shopId: null, items: []);
    } catch (e) {
      emit(CartError(message: 'فشل في مسح السلة'));
    }
  }

  /// Emits a [CartLoaded] state with computed totals.
  void _emitLoaded({
    required String? shopId,
    required List<OrderItem> items,
  }) {
    final totalItems =
        items.fold<int>(0, (sum, item) => sum + item.quantity);
    final subtotal =
        items.fold<double>(0, (sum, item) => sum + item.subtotal);
    emit(CartLoaded(
      shopId: shopId,
      items: items,
      totalItems: totalItems,
      subtotal: subtotal,
    ));
  }
}