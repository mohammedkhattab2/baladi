// Data - Category repository implementation.
//
// Implements the CategoryRepository contract using remote and local datasources.
// Supports offline-first category caching.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/shop.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/local/category_local_datasource.dart';
import '../datasources/remote/category_remote_datasource.dart';
import '../models/category_model.dart';

/// Implementation of [CategoryRepository].
@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryRemoteDatasource _remoteDatasource;
  final CategoryLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [CategoryRepositoryImpl].
  CategoryRepositoryImpl({
    required CategoryRemoteDatasource remoteDatasource,
    required CategoryLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<List<Category>>> getCategories() async {
    if (!await _networkInfo.isConnected) {
      final cached = await _localDatasource.getCachedCategories();
      if (cached.isNotEmpty) return Success(cached);
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final categories = await _remoteDatasource.getCategories();
      await _localDatasource.cacheCategories(categories);
      return categories;
    });
  }

  @override
  Future<Result<List<Shop>>> getCategoryShops({
    required String categorySlug,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      return _remoteDatasource.getCategoryShops(
        categorySlug: categorySlug,
        page: page,
        perPage: perPage,
      );
    });
  }

  @override
  Future<List<Category>?> getCachedCategories() async {
    final cached = await _localDatasource.getCachedCategories();
    return cached.isEmpty ? null : cached;
  }

  @override
  Future<void> cacheCategories(List<Category> categories) async {
    final models = categories
        .map((c) => CategoryModel.fromEntity(c))
        .toList();
    await _localDatasource.cacheCategories(models);
  }

  @override
  Future<void> clearCache() => _localDatasource.clearCache();
}