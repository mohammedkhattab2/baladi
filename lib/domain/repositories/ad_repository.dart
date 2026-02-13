// Domain - Ad repository interface.
//
// Defines the contract for advertisement operations including
// fetching active ads and managing shop advertisements.

import '../../core/result/result.dart';
import '../entities/ad.dart';

/// Repository contract for advertisement operations.
///
/// Handles fetching active ads for customers and managing
/// ad creation/retrieval for shop owners.
abstract class AdRepository {
  /// Fetches all currently active advertisements.
  ///
  /// Returns ads that are within their start/end date range
  /// and have [isActive] set to `true`.
  Future<Result<List<Ad>>> getActiveAds();

  /// Fetches advertisements for the current shop owner.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Ad>>> getShopAds({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new advertisement for the shop.
  ///
  /// - [title]: Ad title.
  /// - [titleAr]: Arabic ad title (optional).
  /// - [description]: Ad description (optional).
  /// - [imageUrl]: Ad image URL (optional).
  /// - [startDate]: When the ad should start showing.
  /// - [endDate]: When the ad should stop showing.
  Future<Result<Ad>> createAd({
    required String title,
    String? titleAr,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetches a single advertisement by ID.
  Future<Result<Ad>> getAdById(String adId);
}