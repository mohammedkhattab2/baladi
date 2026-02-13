// Data - Product repository implementation.
//
// Implements the ProductRepository contract using remote and local datasources.
// Fetches products from the API with local caching for offline access.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/local/product_local_datasource.dart';
import '../datasources/remote/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementation of [ProductRepository].
@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource _remoteDatasource;
  final ProductLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [ProductRepositoryImpl].
  ProductRepositoryImpl({
    required ProductRemoteDatasource remoteDatasource,
    required ProductLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<List<Product>>> getProductsByShop({
    required String shopId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      // Return cached products as fallback when offline.
      final cached = await _localDatasource.getCachedProducts(shopId);
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final products = await _remoteDatasource.getProductsByShop(
        shopId: shopId,
        page: page,
        perPage: perPage,
      );
      // Cache first page results for offline access.
      if (page == 1) {
        await _localDatasource.cacheProducts(shopId, products);
      }
      return products;
    });
  }

  @override
  Future<Result<Product>> getProductById(String productId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getProductById(productId));
  }

  @override
  Future<List<Product>> getCachedProducts(String shopId) async {
    return _localDatasource.getCachedProducts(shopId);
  }

  @override
  Future<void> cacheProducts(String shopId, List<Product> products) async {
    final models = products
        .map((p) => p is ProductModel ? p : ProductModel.fromEntity(p))
        .toList();
    await _localDatasource.cacheProducts(shopId, models);
  }

  @override
  Future<void> clearCache() async {
    await _localDatasource.clearCache();
  }

  @override
  Future<void> clearShopCache(String shopId) async {
    await _localDatasource.clearShopCache(shopId);
  }
}