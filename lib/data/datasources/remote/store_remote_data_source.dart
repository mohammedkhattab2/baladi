/// Remote data source for store operations.
///
/// This interface defines the contract for store API calls.
/// Implementation will use Supabase or similar service.
library;

import '../../dto/store_dto.dart';

/// Remote data source interface for stores.
abstract class StoreRemoteDataSource {
  /// Get all stores.
  ///
  /// Returns list of [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<StoreDto>> getAllStores({
    String? categoryId,
    bool? isActive,
    int page = 1,
    int limit = 20,
  });

  /// Get store by ID.
  ///
  /// Returns [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [NotFoundException] if store not found.
  Future<StoreDto> getStoreById(String storeId);

  /// Get store by user ID (for store owner).
  ///
  /// Returns [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  /// Throws [NotFoundException] if store not found.
  Future<StoreDto> getStoreByUserId(String userId);

  /// Create a new store.
  ///
  /// Returns [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<StoreDto> createStore({
    required String userId,
    required String name,
    String? nameAr,
    required String categoryId,
    String? description,
    String? phone,
    String? address,
    String? logoUrl,
    String? coverImageUrl,
    double commissionRate = 0.10,
    double minOrderAmount = 0,
  });

  /// Update store details.
  ///
  /// Returns updated [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<StoreDto> updateStore({
    required String storeId,
    String? name,
    String? nameAr,
    String? description,
    String? phone,
    String? address,
    String? logoUrl,
    String? coverImageUrl,
    double? commissionRate,
    double? minOrderAmount,
  });

  /// Update store open/close status.
  ///
  /// Returns updated [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<StoreDto> updateStoreStatus({
    required String storeId,
    required bool isOpen,
  });

  /// Approve or reject store (admin only).
  ///
  /// Returns updated [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<StoreDto> setStoreApproval({
    required String storeId,
    required bool isApproved,
  });

  /// Activate or deactivate store (admin only).
  ///
  /// Returns updated [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<StoreDto> setStoreActive({
    required String storeId,
    required bool isActive,
  });

  /// Get stores by category.
  ///
  /// Returns list of [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<StoreDto>> getStoresByCategory({
    required String categoryId,
    int page = 1,
    int limit = 20,
  });

  /// Search stores by name.
  ///
  /// Returns list of [StoreDto] on success.
  /// Throws [ServerException] on API failure.
  Future<List<StoreDto>> searchStores({
    required String query,
    int page = 1,
    int limit = 20,
  });

  /// Get store statistics.
  ///
  /// Returns map of statistics.
  /// Throws [ServerException] on API failure.
  Future<Map<String, dynamic>> getStoreStatistics({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  });

  /// Delete store (admin only).
  ///
  /// Throws [ServerException] on API failure.
  Future<void> deleteStore(String storeId);
}
