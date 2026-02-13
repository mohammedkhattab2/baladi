// Domain - Use case for fetching products of a shop.
//
// Retrieves a paginated list of products for a specific shop.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/product.dart';
import '../../repositories/product_repository.dart';

/// Parameters for fetching shop products.
class GetShopProductsParams extends Equatable {
  /// The shop's unique identifier.
  final String shopId;

  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetShopProductsParams].
  const GetShopProductsParams({
    required this.shopId,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [shopId, page, perPage];
}

/// Fetches products for a specific shop.
///
/// Returns a paginated list of available products.
/// Results may come from cache if available and fresh.
@lazySingleton
class GetShopProducts extends UseCase<List<Product>, GetShopProductsParams> {
  final ProductRepository _repository;

  /// Creates a [GetShopProducts] use case.
  GetShopProducts(this._repository);

  @override
  Future<Result<List<Product>>> call(GetShopProductsParams params) {
    return _repository.getProductsByShop(
      shopId: params.shopId,
      page: params.page,
      perPage: params.perPage,
    );
  }
}