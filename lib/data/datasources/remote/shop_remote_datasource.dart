// Data - Shop remote datasource.
//
// Abstract interface and implementation for shop-related API calls.
// Handles customer-facing shop details, shop owner management,
// product CRUD, dashboard, and settlements.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/product_model.dart';
import '../../models/shop_model.dart';
import '../../models/shop_settlement_model.dart';

/// Remote datasource contract for shop operations.
abstract class ShopRemoteDatasource {
  // ── Customer-facing ──

  /// Fetches details of a specific shop.
  Future<ShopModel> getShopDetails(String shopId);

  /// Fetches products for a specific shop.
  Future<List<ProductModel>> getShopProducts({
    required String shopId,
    int page = 1,
    int perPage = 20,
  });

  // ── Shop owner management ──

  /// Fetches the current shop owner's profile.
  Future<ShopModel> getShopProfile();

  /// Updates the shop's open/closed status.
  Future<ShopModel> updateShopStatus({required bool isOpen});

  /// Fetches the shop owner's dashboard statistics.
  Future<Map<String, dynamic>> getShopDashboard();

  /// Fetches the shop's products (owner view).
  Future<List<ProductModel>> getOwnProducts({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new product in the shop.
  Future<ProductModel> createProduct({
    required String name,
    String? nameAr,
    String? description,
    required double price,
    String? imageUrl,
  });

  /// Updates an existing product.
  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  });

  /// Deletes a product from the shop.
  Future<void> deleteProduct(String productId);

  /// Fetches the shop's settlement history.
  Future<List<ShopSettlementModel>> getSettlements({
    int page = 1,
    int perPage = 20,
  });
}

/// Implementation of [ShopRemoteDatasource] using [ApiClient].
@LazySingleton(as: ShopRemoteDatasource)
class ShopRemoteDatasourceImpl implements ShopRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [ShopRemoteDatasourceImpl].
  ShopRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  // ── Customer-facing ──

  @override
  Future<ShopModel> getShopDetails(String shopId) async {
    final response = await _apiClient.get(
      ApiEndpoints.shopDetails(shopId),
      fromJson: (json) => ShopModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<List<ProductModel>> getShopProducts({
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

  // ── Shop owner management ──

  @override
  Future<ShopModel> getShopProfile() async {
    final response = await _apiClient.get(
      ApiEndpoints.shopProfile,
      fromJson: (json) => ShopModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<ShopModel> updateShopStatus({required bool isOpen}) async {
    final response = await _apiClient.put(
      ApiEndpoints.shopStatus,
      body: {'is_open': isOpen},
      fromJson: (json) => ShopModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<Map<String, dynamic>> getShopDashboard() async {
    final response = await _apiClient.get(
      ApiEndpoints.shopDashboard,
      fromJson: (json) => json,
    );
    return response.data!;
  }

  @override
  Future<List<ProductModel>> getOwnProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<ProductModel>>(
      ApiEndpoints.shopProductsManage,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, ProductModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<ProductModel> createProduct({
    required String name,
    String? nameAr,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.shopProductsManage,
      body: {
        'name': name,
        if (nameAr != null) 'name_ar': nameAr,
        if (description != null) 'description': description,
        'price': price,
        if (imageUrl != null) 'image_url': imageUrl,
      },
      fromJson: (json) => ProductModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<ProductModel> updateProduct({
    required String productId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    final response = await _apiClient.put(
      ApiEndpoints.shopProductById(productId),
      body: {
        if (name != null) 'name': name,
        if (nameAr != null) 'name_ar': nameAr,
        if (description != null) 'description': description,
        if (price != null) 'price': price,
        if (imageUrl != null) 'image_url': imageUrl,
        if (isAvailable != null) 'is_available': isAvailable,
      },
      fromJson: (json) => ProductModel.fromJson(json),
    );
    return response.data!;
  }

  @override
  Future<void> deleteProduct(String productId) async {
    await _apiClient.delete(ApiEndpoints.shopProductById(productId));
  }

  @override
  Future<List<ShopSettlementModel>> getSettlements({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<ShopSettlementModel>>(
      ApiEndpoints.shopSettlements,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, ShopSettlementModel.fromJson),
    );
    return response.data ?? [];
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