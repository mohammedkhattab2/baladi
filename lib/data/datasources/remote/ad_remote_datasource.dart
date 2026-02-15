// Data - Ad remote datasource.
//
// Abstract interface and implementation for advertisement API calls.
// Handles fetching active ads, shop ads, and creating new ads.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/ad_model.dart';

/// Remote datasource contract for advertisement operations.
abstract class AdRemoteDatasource {
  /// Fetches all currently active advertisements.
  Future<List<AdModel>> getActiveAds();

  /// Fetches advertisements for the current shop owner.
  Future<List<AdModel>> getShopAds({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new advertisement for the shop.
  Future<AdModel> createAd({
    required String title,
    String? titleAr,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Fetches a single advertisement by ID.
  Future<AdModel> getAdById(String adId);
}

/// Implementation of [AdRemoteDatasource] using [ApiClient].
@LazySingleton(as: AdRemoteDatasource)
class AdRemoteDatasourceImpl implements AdRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates an [AdRemoteDatasourceImpl].
  AdRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<AdModel>> getActiveAds() async {
    final response = await _apiClient.getList<AdModel>(
      ApiEndpoints.activeAds,
      fromJson: AdModel.fromJson,
    );
    return response.data ?? [];
  }

  @override
  Future<List<AdModel>> getShopAds({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.getList<AdModel>(
      ApiEndpoints.shopAds,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: AdModel.fromJson,
    );
    return response.data ?? [];
  }

  @override
  Future<AdModel> createAd({
    required String title,
    String? titleAr,
    String? description,
    String? imageUrl,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.shopAds,
      body: {
        'title': title,
        if (titleAr != null) 'title_ar': titleAr,
        if (description != null) 'description': description,
        if (imageUrl != null) 'image_url': imageUrl,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate.toIso8601String(),
      },
      fromJson: (json) => AdModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<AdModel> getAdById(String adId) async {
    final response = await _apiClient.get(
      '${ApiEndpoints.activeAds}/$adId',
      fromJson: (json) => AdModel.fromJson(json),
    );
    return response.data!;
  }

}