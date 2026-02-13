// Data - Category local datasource.
//
// Abstract interface and implementation for local category caching.
// Uses Hive via CacheService for offline category access.

import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../core/constants/storage_keys.dart';
import '../../../core/services/cache_service.dart';
import '../../models/category_model.dart';

/// Local datasource contract for category caching operations.
abstract class CategoryLocalDatasource {
  /// Retrieves all cached categories.
  Future<List<CategoryModel>> getCachedCategories();

  /// Caches a list of categories.
  Future<void> cacheCategories(List<CategoryModel> categories);

  /// Clears all cached categories.
  Future<void> clearCache();
}

/// Implementation of [CategoryLocalDatasource] using [CacheService].
@LazySingleton(as: CategoryLocalDatasource)
class CategoryLocalDatasourceImpl implements CategoryLocalDatasource {
  final CacheService _cacheService;

  /// Key used to store the categories list in the user box.
  static const String _categoriesKey = 'cached_categories';

  /// Creates a [CategoryLocalDatasourceImpl].
  CategoryLocalDatasourceImpl({required CacheService cacheService})
      : _cacheService = cacheService;

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    final value = _cacheService.get(StorageKeys.userBox, _categoriesKey);
    if (value == null) return [];
    try {
      final list = jsonDecode(value as String) as List<dynamic>;
      return list
          .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    final jsonList = categories.map((c) => c.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _cacheService.put(StorageKeys.userBox, _categoriesKey, jsonString);
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.delete(StorageKeys.userBox, _categoriesKey);
  }
}