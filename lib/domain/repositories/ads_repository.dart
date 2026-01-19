/// Repository interface for ads/daily offers operations.
/// 
/// This defines the contract for ads-related data access.
/// Shops can post "Daily Offers" ads at 10 EGP/day.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';

/// Ads repository interface.
abstract class AdsRepository {
  /// Get ad by ID.
  Future<Result<Ad>> getAdById(String adId);

  /// Get active ads for display.
  Future<Result<List<Ad>>> getActiveAds({
    String? categoryId,
    int limit = 10,
  });

  /// Get ads for a store.
  Future<Result<List<Ad>>> getStoreAds({
    required String storeId,
    bool activeOnly = false,
    int page = 1,
    int pageSize = 20,
  });

  /// Create a new ad.
  Future<Result<Ad>> createAd({
    required String storeId,
    required String title,
    required String titleAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Update ad details.
  Future<Result<Ad>> updateAd(Ad ad);

  /// Pause/resume an ad.
  Future<Result<Ad>> toggleAdStatus({
    required String adId,
    required bool isActive,
  });

  /// Delete an ad.
  Future<Result<void>> deleteAd(String adId);

  /// Get ads cost for settlement period.
  Future<Result<List<AdCostItem>>> getAdsCostForPeriod({
    required DateTime startDate,
    required DateTime endDate,
    String? storeId,
  });

  /// Calculate total ads cost for a store in period.
  Future<Result<double>> calculateAdsCost({
    required String storeId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Get ad statistics.
  Future<Result<AdStatistics>> getAdStatistics(String adId);

  /// Watch active ads.
  Stream<List<Ad>> watchActiveAds({String? categoryId});
}

/// Ad entity.
class Ad {
  final String id;
  final String storeId;
  final String storeName;
  final String title;
  final String titleAr;
  final String? description;
  final String? descriptionAr;
  final String? imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final double costPerDay;
  final bool isActive;
  final int impressions;
  final int clicks;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Ad({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.title,
    required this.titleAr,
    this.description,
    this.descriptionAr,
    this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.costPerDay,
    required this.isActive,
    required this.impressions,
    required this.clicks,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calculate total days for this ad.
  int get totalDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Calculate total cost for this ad.
  double get totalCost => totalDays * costPerDay;

  /// Check if ad is currently running.
  bool get isRunning {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Check if ad has ended.
  bool get hasEnded => DateTime.now().isAfter(endDate);

  /// Copy with updated fields.
  Ad copyWith({
    String? id,
    String? storeId,
    String? storeName,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    String? imageUrl,
    DateTime? startDate,
    DateTime? endDate,
    double? costPerDay,
    bool? isActive,
    int? impressions,
    int? clicks,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ad(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      storeName: storeName ?? this.storeName,
      title: title ?? this.title,
      titleAr: titleAr ?? this.titleAr,
      description: description ?? this.description,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      imageUrl: imageUrl ?? this.imageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      costPerDay: costPerDay ?? this.costPerDay,
      isActive: isActive ?? this.isActive,
      impressions: impressions ?? this.impressions,
      clicks: clicks ?? this.clicks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Ad cost item for settlement.
class AdCostItem {
  final String adId;
  final String storeId;
  final String storeName;
  final String adTitle;
  final int days;
  final double costPerDay;
  final double totalCost;

  const AdCostItem({
    required this.adId,
    required this.storeId,
    required this.storeName,
    required this.adTitle,
    required this.days,
    required this.costPerDay,
    required this.totalCost,
  });
}

/// Ad statistics.
class AdStatistics {
  final String adId;
  final int totalImpressions;
  final int totalClicks;
  final double clickThroughRate;
  final int totalDays;
  final double totalCost;
  final double costPerClick;

  const AdStatistics({
    required this.adId,
    required this.totalImpressions,
    required this.totalClicks,
    required this.clickThroughRate,
    required this.totalDays,
    required this.totalCost,
    required this.costPerClick,
  });
}