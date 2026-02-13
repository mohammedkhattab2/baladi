// Domain - Use case for fetching orders.
//
// Retrieves a paginated list of orders for the current user,
// optionally filtered by status.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../enums/order_status.dart';
import '../../repositories/order_repository.dart';

/// Parameters for fetching orders.
class GetOrdersParams extends Equatable {
  /// Optional status filter.
  final OrderStatus? status;

  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetOrdersParams].
  const GetOrdersParams({
    this.status,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [status, page, perPage];
}

/// Fetches orders for the current user.
///
/// Returns a paginated list filtered by role on the backend.
/// Optionally filtered by [OrderStatus].
@lazySingleton
class GetOrders extends UseCase<List<Order>, GetOrdersParams> {
  final OrderRepository _repository;

  /// Creates a [GetOrders] use case.
  GetOrders(this._repository);

  @override
  Future<Result<List<Order>>> call(GetOrdersParams params) {
    return _repository.getOrders(
      status: params.status,
      page: params.page,
      perPage: params.perPage,
    );
  }
}