// Domain - Use case for fetching available orders for riders.
//
// Retrieves orders that are ready for pickup (preparing status).

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/rider_repository.dart';

/// Parameters for fetching available orders.
class GetAvailableOrdersParams extends Equatable {
  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetAvailableOrdersParams].
  const GetAvailableOrdersParams({
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [page, perPage];
}

/// Fetches orders available for rider pickup.
///
/// Returns orders in the "preparing" status that have not
/// yet been assigned to a rider.
@lazySingleton
class GetAvailableOrders
    extends UseCase<List<Order>, GetAvailableOrdersParams> {
  final RiderRepository _repository;

  /// Creates a [GetAvailableOrders] use case.
  GetAvailableOrders(this._repository);

  @override
  Future<Result<List<Order>>> call(GetAvailableOrdersParams params) {
    return _repository.getAvailableOrders(
      page: params.page,
      perPage: params.perPage,
    );
  }
}