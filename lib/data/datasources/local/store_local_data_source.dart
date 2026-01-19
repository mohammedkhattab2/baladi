/// Local data source for store operations.
///
/// This interface defines the contract for local store data storage.
/// Implementation will use SQLite or Hive for structured local storage.
library;

import '../../dto/store_dto.dart';
import '../../dto/product_dto.dart';

/// Local data source interface for stores.
abstract class StoreLocalDataSource {
  /// Cache store data.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheStore(StoreDto store);

  /// Cache multiple stores.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheStores(List<StoreDto> stores);

  /// Get cached store by ID.
  /// 
  /// Returns [StoreDto] if found.
  /// Returns null if not cached.
  /// Throws [CacheException] on storage failure.
  Future<StoreDto?> getCachedStore(String storeId);

  /// Get cached store by user ID.
  /// 
  /// Returns [StoreDto] if found.
  /// Returns null if not cached.
  /// Throws [CacheException] on storage failure.
  Future<StoreDto?> getCachedStoreByUserId(String userId);

  /// Get all cached stores.
  /// 
  /// Returns list of [StoreDto].
  /// Throws [CacheException] on storage failure.
  Future<List<StoreDto>> getAllCachedStores();

  /// Get cached stores by category.
  /// 
  /// Returns list of [StoreDto].
  /// Throws [CacheException] on storage failure.
  Future<List<StoreDto>> getCachedStoresByCategory(String categoryId);

  /// Update cached store.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateCachedStore(StoreDto store);

  /// Delete cached store.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> deleteCachedStore(String storeId);

  /// Clear all cached stores.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> clearAllCachedStores();

  /// Cache products for a store.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> cacheStoreProducts(String storeId, List<ProductDto> products);

  /// Get cached products for a store.
  /// 
  /// Returns list of [ProductDto].
  /// Throws [CacheException] on storage failure.
  Future<List<ProductDto>> getCachedStoreProducts(String storeId);

  /// Get last cache update timestamp for stores.
  /// 
  /// Returns DateTime if available.
  Future<DateTime?> getLastCacheUpdate();

  /// Update last cache timestamp.
  /// 
  /// Throws [CacheException] on storage failure.
  Future<void> updateLastCacheTimestamp();

  /// Search cached stores by name.
  /// 
  /// Returns list of [StoreDto] matching query.
  Future<List<StoreDto>> searchCachedStores(String query);
}