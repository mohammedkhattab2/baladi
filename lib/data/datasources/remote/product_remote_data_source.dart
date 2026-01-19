/// Remote data source for product operations.
///
/// This interface defines the contract for product API calls.
/// Implementation will use Supabase or similar service.
library;

import '../../dto/product_dto.dart';

/// Remote data source interface for products.
abstract class ProductRemoteDataSource {
  /// Get all products for a store.
  ///
  /// Returns list of [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<ProductDto>> getProductsByStore({
    required String storeId,
    String? category,
    bool? isAvailable,
    int page = 1,
    int limit = 50,
  });

  /// Get product by ID.
  ///
  /// Returns [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [NotFoundException] if product not found.
  Future<ProductDto> getProductById(String productId);

  /// Create a new product.
  ///
  /// Returns [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<ProductDto> createProduct({
    required String storeId,
    required String name,
    String? nameAr,
    String? description,
    required double price,
    double? discountPrice,
    String? imageUrl,
    String? category,
    bool isAvailable = true,
    int sortOrder = 0,
  });

  /// Update product details.
  ///
  /// Returns updated [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<ProductDto> updateProduct({
    required String productId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    int? sortOrder,
  });

  /// Update product availability.
  ///
  /// Returns updated [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<ProductDto> updateProductAvailability({
    required String productId,
    required bool isAvailable,
  });

  /// Update product price.
  ///
  /// Returns updated [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<ProductDto> updateProductPrice({
    required String productId,
    required double price,
    double? discountPrice,
  });

  /// Delete product.
  ///
  /// Throws [ServerException] on API failure.
  Future<void> deleteProduct(String productId);

  /// Bulk update product availability.
  ///
  /// Returns list of updated [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<ProductDto>> bulkUpdateAvailability({
    required List<String> productIds,
    required bool isAvailable,
  });

  /// Search products by name.
  ///
  /// Returns list of [ProductDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<ProductDto>> searchProducts({
    required String query,
    String? storeId,
    int page = 1,
    int limit = 20,
  });

  /// Get product categories for a store.
  ///
  /// Returns list of category names.
  /// Throws [ServerException] on API failure.
  Future<List<String>> getProductCategories(String storeId);

  /// Reorder products (update sort order).
  ///
  /// Throws [ServerException] on API failure.
  Future<void> reorderProducts({
    required String storeId,
    required List<String> productIds,
  });
}
