// Domain - Use case for fetching product categories.
//
// Retrieves all active categories sorted by sort order.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/category.dart';
import '../../repositories/category_repository.dart';

/// Fetches all active product categories.
///
/// Returns categories sorted by [Category.sortOrder].
/// Results may come from cache if available and fresh.
@lazySingleton
class GetCategories extends UseCase<List<Category>, NoParams> {
  final CategoryRepository _repository;

  /// Creates a [GetCategories] use case.
  GetCategories(this._repository);

  @override
  Future<Result<List<Category>>> call(NoParams params) {
    return _repository.getCategories();
  }
}