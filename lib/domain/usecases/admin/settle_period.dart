// Domain - Use case for settling a specific settlement record.
//
// Allows the admin to fetch a single shop settlement by ID
// for review and approval.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/shop_settlement.dart';
import '../../repositories/settlement_repository.dart';

/// Parameters for fetching a shop settlement detail.
class GetShopSettlementDetailParams extends Equatable {
  /// The settlement record ID.
  final String settlementId;

  /// Creates [GetShopSettlementDetailParams].
  const GetShopSettlementDetailParams({required this.settlementId});

  @override
  List<Object?> get props => [settlementId];
}

/// Fetches a single shop settlement by ID for admin review.
@lazySingleton
class GetShopSettlementDetail
    extends UseCase<ShopSettlement, GetShopSettlementDetailParams> {
  final SettlementRepository _repository;

  /// Creates a [GetShopSettlementDetail] use case.
  GetShopSettlementDetail(this._repository);

  @override
  Future<Result<ShopSettlement>> call(GetShopSettlementDetailParams params) {
    return _repository.getShopSettlementById(params.settlementId);
  }
}