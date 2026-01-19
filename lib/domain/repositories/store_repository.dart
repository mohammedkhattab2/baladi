/// Repository interface for store operations.
/// 
/// This defines the contract for store-related data access.
/// Includes store management, categories, and store settings.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/store.dart';

/// Store repository interface.
abstract class StoreRepository {
  /// Get store by ID.
  Future<Result<Store>> getStoreById(String storeId);

  /// Get all active stores.
  /// 
  /// Supports pagination and category filtering.
  Future<Result<List<Store>>> getStores({
    String? categoryId,
    bool activeOnly = true,
    int page = 1,
    int pageSize = 20,
  });

  /// Get stores by category.
  Future<Result<List<Store>>> getStoresByCategory(String categoryId);

  /// Search stores by name.
  Future<Result<List<Store>>> searchStores({
    required String query,
    String? categoryId,
    int page = 1,
    int pageSize = 20,
  });

  /// Get featured stores.
  Future<Result<List<Store>>> getFeaturedStores({int limit = 10});

  /// Get nearby stores (for future map integration).
  Future<Result<List<Store>>> getNearbyStores({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
    String? categoryId,
  });

  /// Create a new store (admin only).
  Future<Result<Store>> createStore(Store store);

  /// Update store details.
  Future<Result<Store>> updateStore(Store store);

  /// Update store status (active/inactive).
  Future<Result<Store>> updateStoreStatus({
    required String storeId,
    required bool isActive,
  });

  /// Update store settings.
  Future<Result<Store>> updateStoreSettings({
    required String storeId,
    double? minimumOrder,
    double? deliveryFee,
    bool? acceptsOrders,
    String? openingTime,
    String? closingTime,
  });

  /// Get store statistics.
  Future<Result<StoreStatistics>> getStoreStatistics({
    required String storeId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get store categories.
  Future<Result<List<StoreCategory>>> getCategories();

  /// Watch store updates.
  Stream<Store> watchStore(String storeId);

  /// Watch stores list updates.
  Stream<List<Store>> watchStores({String? categoryId});
}

/// Store statistics data.
class StoreStatistics {
  final String storeId;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double totalCommission;
  final double averageOrderValue;
  final double averageRating;
  final int totalReviews;
  final DateTime periodStart;
  final DateTime periodEnd;

  const StoreStatistics({
    required this.storeId,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.totalCommission,
    required this.averageOrderValue,
    required this.averageRating,
    required this.totalReviews,
    required this.periodStart,
    required this.periodEnd,
  });
}

/// Store category.
class StoreCategory {
  final String id;
  final String name;
  final String nameAr;
  final String? iconUrl;
  final int sortOrder;
  final bool isActive;

  const StoreCategory({
    required this.id,
    required this.name,
    required this.nameAr,
    this.iconUrl,
    required this.sortOrder,
    required this.isActive,
  });
}