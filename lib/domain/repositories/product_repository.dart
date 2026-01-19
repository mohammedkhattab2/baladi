/// Repository interface for product operations.
/// 
/// This defines the contract for product-related data access.
/// Includes product CRUD, inventory, and search functionality.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/product.dart';

/// Product repository interface.
abstract class ProductRepository {
  /// Get product by ID.
  Future<Result<Product>> getProductById(String productId);

  /// Get products for a store.
  /// 
  /// Supports pagination and category filtering.
  Future<Result<List<Product>>> getStoreProducts({
    required String storeId,
    String? categoryId,
    bool availableOnly = true,
    int page = 1,
    int pageSize = 20,
  });

  /// Search products.
  Future<Result<List<Product>>> searchProducts({
    required String query,
    String? storeId,
    String? categoryId,
    bool availableOnly = true,
    int page = 1,
    int pageSize = 20,
  });

  /// Get featured products for a store.
  Future<Result<List<Product>>> getFeaturedProducts({
    required String storeId,
    int limit = 10,
  });

  /// Get products by category.
  Future<Result<List<Product>>> getProductsByCategory({
    required String storeId,
    required String categoryId,
    bool availableOnly = true,
  });

  /// Create a new product (store owner only).
  Future<Result<Product>> createProduct(Product product);

  /// Update product details.
  Future<Result<Product>> updateProduct(Product product);

  /// Update product price.
  Future<Result<Product>> updateProductPrice({
    required String productId,
    required double newPrice,
    double? oldPrice,
  });

  /// Update product availability.
  Future<Result<Product>> updateProductAvailability({
    required String productId,
    required bool isAvailable,
  });

  /// Update product stock quantity.
  Future<Result<Product>> updateProductStock({
    required String productId,
    required int quantity,
  });

  /// Delete product (soft delete).
  Future<Result<void>> deleteProduct(String productId);

  /// Get product categories for a store.
  Future<Result<List<ProductCategory>>> getProductCategories(String storeId);

  /// Create product category.
  Future<Result<ProductCategory>> createCategory({
    required String storeId,
    required String name,
    required String nameAr,
    int? sortOrder,
  });

  /// Update product category.
  Future<Result<ProductCategory>> updateCategory(ProductCategory category);

  /// Delete product category.
  Future<Result<void>> deleteCategory(String categoryId);

  /// Watch product updates.
  Stream<Product> watchProduct(String productId);

  /// Watch store products list.
  Stream<List<Product>> watchStoreProducts({
    required String storeId,
    String? categoryId,
  });

  /// Bulk update product prices.
  Future<Result<List<Product>>> bulkUpdatePrices({
    required String storeId,
    required Map<String, double> productPrices,
  });

  /// Bulk update product availability.
  Future<Result<List<Product>>> bulkUpdateAvailability({
    required String storeId,
    required Map<String, bool> productAvailability,
  });
}

/// Product category.
class ProductCategory {
  final String id;
  final String storeId;
  final String name;
  final String nameAr;
  final int sortOrder;
  final bool isActive;
  final int productCount;

  const ProductCategory({
    required this.id,
    required this.storeId,
    required this.name,
    required this.nameAr,
    required this.sortOrder,
    required this.isActive,
    required this.productCount,
  });
}