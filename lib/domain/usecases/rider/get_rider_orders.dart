// Domain - Use case for fetching rider's orders.
//
// Retrieves the rider's assigned and completed orders.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/rider_repository.dart';

/// Parameters for fetching rider orders.
class GetRiderOrdersParams extends Equatable {
  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetRiderOrdersParams].
  const GetRiderOrdersParams({
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Fetches the rider's assigned and completed orders.
///
/// Returns a paginated list of orders the rider has picked up
/// or delivered.
@lazySingleton
class GetRiderOrders extends UseCase<List<Order>, GetRiderOrdersParams> {
  final RiderRepository _repository;

  /// Creates a [GetRiderOrders] use case.
  GetRiderOrders(this._repository);

  @override
  Future<Result<List<Order>>> call(GetRiderOrdersParams params) {
    return _repository.getRiderOrders(
      page: params.page,
      perPage: params.perPage,
    );
  }
}