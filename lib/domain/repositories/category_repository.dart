// Domain - Category repository interface.
//
// Defines the contract for fetching product categories
// and their associated shops.

import '../../core/result/result.dart';
import '../entities/category.dart';
import '../entities/shop.dart';

/// Repository contract for category-related operations.
///
/// Handles fetching the category list and shops within each category.
/// Supports local caching for offline access.
abstract class CategoryRepository {
  /// Fetches all active categories.
  ///
  /// Returns categories sorted by [sortOrder].
  Future<Result<List<Category>>> getCategories();

  /// Fetches shops belonging to a specific category.
  ///
  /// - [categorySlug]: The URL-friendly slug of the category.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Shop>>> getCategoryShops({
    required String categorySlug,
    int page = 1,
    int perPage = 20,
  });

  /// Returns locally cached categories, or `null` if not cached.
  Future<List<Category>?> getCachedCategories();

  /// Caches the category list locally.
  Future<void> cacheCategories(List<Category> categories);

  /// Clears the cached categories.
  Future<void> clearCache();
}