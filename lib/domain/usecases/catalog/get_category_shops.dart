// Domain - Use case for fetching shops in a category.
//
// Retrieves shops belonging to a specific category by slug.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/shop.dart';
import '../../repositories/category_repository.dart';

/// Parameters for fetching shops in a category.
class GetCategoryShopsParams extends Equatable {
  /// The URL-friendly slug of the category.
  final String categorySlug;

  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetCategoryShopsParams].
  const GetCategoryShopsParams({
    required this.categorySlug,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [categorySlug, page, perPage];
}

/// Fetches shops belonging to a specific category.
///
/// Returns a paginated list of shops filtered by the category slug.
@lazySingleton
class GetCategoryShops extends UseCase<List<Shop>, GetCategoryShopsParams> {
  final CategoryRepository _repository;

  /// Creates a [GetCategoryShops] use case.
  GetCategoryShops(this._repository);

  @override
  Future<Result<List<Shop>>> call(GetCategoryShopsParams params) {
    return _repository.getCategoryShops(
      categorySlug: params.categorySlug,
      page: params.page,
      perPage: params.perPage,
    );
  }
}