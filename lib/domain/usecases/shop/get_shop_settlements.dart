// Domain - Use case for fetching shop settlements.
//
// Retrieves settlement history for the current shop owner.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/shop_settlement.dart';
import '../../repositories/shop_repository.dart';

/// Parameters for fetching shop settlements.
class GetShopSettlementsParams extends Equatable {
  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetShopSettlementsParams].
  const GetShopSettlementsParams({
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Fetches settlement history for the current shop owner.
///
/// Returns a paginated list of weekly settlement records
/// including commission breakdown and payment status.
@lazySingleton
class GetShopSettlements
    extends UseCase<List<ShopSettlement>, GetShopSettlementsParams> {
  final ShopRepository _repository;

  /// Creates a [GetShopSettlements] use case.
  GetShopSettlements(this._repository);

  @override
  Future<Result<List<ShopSettlement>>> call(GetShopSettlementsParams params) {
    return _repository.getSettlements(
      page: params.page,
      perPage: params.perPage,
    );
  }
}