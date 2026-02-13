// Data - Product remote datasource.
//
// Abstract interface and implementation for product-related API calls.
// Handles fetching products by shop and by ID.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/product_model.dart';

/// Remote datasource contract for product operations.
abstract class ProductRemoteDatasource {
  /// Fetches products for a specific shop.
  Future<List<ProductModel>> getProductsByShop({
    required String shopId,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches a single product by its ID.
  Future<ProductModel> getProductById(String productId);
}

/// Implementation of [ProductRemoteDatasource] using [ApiClient].
@LazySingleton(as: ProductRemoteDatasource)
class ProductRemoteDatasourceImpl implements ProductRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [ProductRemoteDatasourceImpl].
  ProductRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<ProductModel>> getProductsByShop({
    required String shopId,
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<ProductModel>>(
      ApiEndpoints.shopProducts(shopId),
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, ProductModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<ProductModel> getProductById(String productId) async {
    final response = await _apiClient.get(
      ApiEndpoints.shopProductById(productId),
      fromJson: (json) => ProductModel.fromJson(json),
    );
    return response.data!;
  }

  /// Parses a list of items from the standard API list response format.
  static List<T> _parseList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}