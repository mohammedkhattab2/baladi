// Domain - Product repository interface.
//
// Defines the contract for product-related operations
// including fetching, searching, and local caching.

import '../../core/result/result.dart';
import '../entities/product.dart';

/// Repository contract for product-related operations.
///
/// Handles product retrieval and local caching for offline access.
/// Product creation/update/delete is handled by [ShopRepository].
abstract class ProductRepository {
  /// Fetches products for a specific shop.
  ///
  /// - [shopId]: The shop's unique identifier.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Product>>> getProductsByShop({
    required String shopId,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches a single product by its ID.
  ///
  /// - [productId]: The product's unique identifier.
  Future<Result<Product>> getProductById(String productId);

  /// Returns locally cached products for a shop, or empty list if none.
  Future<List<Product>> getCachedProducts(String shopId);

  /// Caches products locally for offline access.
  Future<void> cacheProducts(String shopId, List<Product> products);

  /// Clears all cached products.
  Future<void> clearCache();

  /// Clears cached products for a specific shop.
  Future<void> clearShopCache(String shopId);
}