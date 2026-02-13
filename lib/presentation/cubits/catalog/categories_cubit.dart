// Presentation - Categories cubit.
//
// Manages categories state including fetching all categories
// and loading shops for a selected category.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/category.dart';
import '../../../domain/usecases/catalog/get_categories.dart';
import '../../../domain/usecases/catalog/get_category_shops.dart';
import 'categories_state.dart';

/// Cubit that manages the categories and category shops lifecycle.
///
/// Handles loading all categories and fetching shops
/// for a selected category with pagination.
@injectable
class CategoriesCubit extends Cubit<CategoriesState> {
  final GetCategories _getCategories;
  final GetCategoryShops _getCategoryShops;

  /// Creates a [CategoriesCubit].
  CategoriesCubit({
    required GetCategories getCategories,
    required GetCategoryShops getCategoryShops,
  })  : _getCategories = getCategories,
        _getCategoryShops = getCategoryShops,
        super(const CategoriesInitial());

  /// Fetches all active categories.
  Future<void> loadCategories() async {
    emit(const CategoriesLoading());
    final result = await _getCategories(const NoParams());
    result.fold(
      onSuccess: (categories) {
        emit(CategoriesLoaded(categories: categories));
      },
      onFailure: (failure) {
        emit(CategoriesError(message: failure.message));
      },
    );
  }

  /// Fetches shops belonging to a specific category.
  Future<void> loadCategoryShops({
    required String categorySlug,
    int page = 1,
    int perPage = 20,
  }) async {
    final categories = _currentCategories;
    emit(CategoryShopsLoading(
      categories: categories,
      categorySlug: categorySlug,
    ));
    final result = await _getCategoryShops(GetCategoryShopsParams(
      categorySlug: categorySlug,
      page: page,
      perPage: perPage,
    ));
    result.fold(
      onSuccess: (shops) {
        emit(CategoryShopsLoaded(
          categories: categories,
          categorySlug: categorySlug,
          shops: shops,
        ));
      },
      onFailure: (failure) {
        emit(CategoryShopsError(
          categories: categories,
          message: failure.message,
        ));
      },
    );
  }

  /// Extracts current categories from state if available.
  List<Category> get _currentCategories {
    final s = state;
    if (s is CategoriesLoaded) return s.categories;
    if (s is CategoryShopsLoading) return s.categories;
    if (s is CategoryShopsLoaded) return s.categories;
    if (s is CategoryShopsError) return s.categories;
    return [];
  }
}