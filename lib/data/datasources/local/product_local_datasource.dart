// Data - Product local datasource.
//
// Abstract interface and implementation for local product caching.
// Uses Hive via CacheService for offline product access.

import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/cache_service.dart';
import '../../models/product_model.dart';

/// Local datasource contract for product caching operations.
abstract class ProductLocalDatasource {
  /// Retrieves cached products for a specific shop.
  Future<List<ProductModel>> getCachedProducts(String shopId);

  /// Caches products for a specific shop.
  Future<void> cacheProducts(String shopId, List<ProductModel> products);

  /// Clears all cached products.
  Future<void> clearCache();

  /// Clears cached products for a specific shop.
  Future<void> clearShopCache(String shopId);
}

/// Implementation of [ProductLocalDatasource] using [CacheService].
@LazySingleton(as: ProductLocalDatasource)
class ProductLocalDatasourceImpl implements ProductLocalDatasource {
  final CacheService _cacheService;

  /// Creates a [ProductLocalDatasourceImpl].
  ProductLocalDatasourceImpl({required CacheService cacheService})
      : _cacheService = cacheService;

  /// Key prefix for shop products in the products box.
  String _shopKey(String shopId) => 'shop_$shopId';

  @override
  Future<List<ProductModel>> getCachedProducts(String shopId) async {
    final value = _cacheService.get(StorageKeys.productsBox, _shopKey(shopId));
    if (value == null) return [];
    try {
      final list = jsonDecode(value as String) as List<dynamic>;
      return list
          .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheProducts(
    String shopId,
    List<ProductModel> products,
  ) async {
    final jsonList = products.map((p) => p.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _cacheService.put(
      StorageKeys.productsBox,
      _shopKey(shopId),
      jsonString,
    );
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearBox(StorageKeys.productsBox);
  }

  @override
  Future<void> clearShopCache(String shopId) async {
    await _cacheService.delete(StorageKeys.productsBox, _shopKey(shopId));
  }
}