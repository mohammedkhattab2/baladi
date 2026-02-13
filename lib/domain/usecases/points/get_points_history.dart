// Domain - Use case for fetching points transaction history.
//
// Retrieves the customer's points transaction history with pagination.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/points_transaction.dart';
import '../../repositories/points_repository.dart';

/// Parameters for fetching points history.
class GetPointsHistoryParams extends Equatable {
  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetPointsHistoryParams].
  const GetPointsHistoryParams({
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Fetches the customer's points transaction history.
///
/// Returns a paginated list of points transactions including
/// earned, redeemed, referral, and adjustment entries.
@lazySingleton
class GetPointsHistory
    extends UseCase<List<PointsTransaction>, GetPointsHistoryParams> {
  final PointsRepository _repository;

  /// Creates a [GetPointsHistory] use case.
  GetPointsHistory(this._repository);

  @override
  Future<Result<List<PointsTransaction>>> call(
    GetPointsHistoryParams params,
  ) {
    return _repository.getPointsHistory(
      page: params.page,
      perPage: params.perPage,
    );
  }
}