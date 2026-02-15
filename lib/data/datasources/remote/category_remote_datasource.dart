// Data - Category remote datasource.
//
// Abstract interface and implementation for category API calls.
// Handles fetching categories and shops within a category.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/category_model.dart';
import '../../models/shop_model.dart';

/// Remote datasource contract for category operations.
abstract class CategoryRemoteDatasource {
  /// Fetches all active categories.
  Future<List<CategoryModel>> getCategories();

  /// Fetches shops belonging to a specific category.
  Future<List<ShopModel>> getCategoryShops({
    required String categorySlug,
    int page = 1,
    int perPage = 20,
  });
}

/// Implementation of [CategoryRemoteDatasource] using [ApiClient].
@LazySingleton(as: CategoryRemoteDatasource)
class CategoryRemoteDatasourceImpl implements CategoryRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [CategoryRemoteDatasourceImpl].
  CategoryRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<CategoryModel>> getCategories() async {
    final response = await _apiClient.getList<CategoryModel>(
      ApiEndpoints.categories,
      fromJson: CategoryModel.fromJson,
    );
    return response.data ?? [];
  }

  @override
  Future<List<ShopModel>> getCategoryShops({
    required String categorySlug,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.getList<ShopModel>(
      ApiEndpoints.categoryShops(categorySlug),
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: ShopModel.fromJson,
    );
    return response.data ?? [];
  }
}