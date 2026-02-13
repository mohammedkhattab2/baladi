// Data - Cart local datasource.
//
// Abstract interface and implementation for local shopping cart persistence.
// Uses Hive via CacheService for cart state across app sessions.

import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/cache_service.dart';
import '../../models/order_item_model.dart';

/// Local datasource contract for shopping cart operations.
abstract class CartLocalDatasource {
  /// Retrieves all items in the cart.
  Future<List<OrderItemModel>> getCartItems();

  /// Adds or updates an item in the cart.
  Future<void> addItem(OrderItemModel item);

  /// Updates the quantity of a cart item.
  Future<void> updateItemQuantity(String productId, int quantity);

  /// Removes an item from the cart.
  Future<void> removeItem(String productId);

  /// Clears all items from the cart.
  Future<void> clearCart();

  /// Returns the current shop ID associated with the cart, or `null` if empty.
  Future<String?> getCartShopId();

  /// Sets the shop ID for the current cart session.
  Future<void> setCartShopId(String shopId);

  /// Returns the total number of items in the cart.
  Future<int> getItemCount();
}

/// Implementation of [CartLocalDatasource] using [CacheService].
@LazySingleton(as: CartLocalDatasource)
class CartLocalDatasourceImpl implements CartLocalDatasource {
  final CacheService _cacheService;

  /// Key for the list of cart items.
  static const String _cartItemsKey = 'cart_items';

  /// Key for the shop ID associated with the cart.
  static const String _cartShopIdKey = 'cart_shop_id';

  /// Creates a [CartLocalDatasourceImpl].
  CartLocalDatasourceImpl({required CacheService cacheService})
      : _cacheService = cacheService;

  @override
  Future<List<OrderItemModel>> getCartItems() async {
    final value = _cacheService.get(StorageKeys.cartBox, _cartItemsKey);
    if (value == null) return [];
    try {
      final list = jsonDecode(value as String) as List<dynamic>;
      return list
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> addItem(OrderItemModel item) async {
    final items = await getCartItems();
    final existingIndex = items.indexWhere(
      (i) => i.productId == item.productId,
    );
    if (existingIndex >= 0) {
      // Update existing item (replace with new data).
      items[existingIndex] = item;
    } else {
      items.add(item);
    }
    await _saveItems(items);
  }

  @override
  Future<void> updateItemQuantity(String productId, int quantity) async {
    final items = await getCartItems();
    final index = items.indexWhere((i) => i.productId == productId);
    if (index >= 0) {
      final existing = items[index];
      items[index] = OrderItemModel(
        id: existing.id,
        orderId: existing.orderId,
        productId: existing.productId,
        productName: existing.productName,
        price: existing.price,
        quantity: quantity,
        subtotal: existing.price * quantity,
        notes: existing.notes,
      );
      await _saveItems(items);
    }
  }

  @override
  Future<void> removeItem(String productId) async {
    final items = await getCartItems();
    items.removeWhere((i) => i.productId == productId);
    await _saveItems(items);
  }

  @override
  Future<void> clearCart() async {
    await _cacheService.clearBox(StorageKeys.cartBox);
  }

  @override
  Future<String?> getCartShopId() async {
    final value = _cacheService.get(StorageKeys.cartBox, _cartShopIdKey);
    return value as String?;
  }

  @override
  Future<void> setCartShopId(String shopId) async {
    await _cacheService.put(StorageKeys.cartBox, _cartShopIdKey, shopId);
  }

  @override
  Future<int> getItemCount() async {
    final items = await getCartItems();
    return items.fold<int>(0, (sum, item) => sum + item.quantity);
  }

  /// Persists the current cart items list.
  Future<void> _saveItems(List<OrderItemModel> items) async {
    final jsonList = items.map((i) => OrderItemModel.fromEntity(i).toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _cacheService.put(StorageKeys.cartBox, _cartItemsKey, jsonString);
  }
}