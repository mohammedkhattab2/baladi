// Domain - Use case for fetching shop orders.
//
// Retrieves orders for the current shop owner, optionally
// filtered by status.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../enums/order_status.dart';
import '../../repositories/order_repository.dart';

/// Parameters for fetching shop orders.
class GetShopOrdersParams extends Equatable {
  /// Optional status filter.
  final OrderStatus? status;

  /// Page number for pagination (1-based).
  final int page;

  /// Number of items per page.
  final int perPage;

  /// Creates [GetShopOrdersParams].
  const GetShopOrdersParams({
    this.status,
    this.page = 1,
    this.perPage = 20,
  });

  @override
  List<Object?> get props => [status, page, perPage];
}

/// Fetches orders for the current shop owner.
///
/// Returns a paginated list optionally filtered by [OrderStatus].
@lazySingleton
class GetShopOrders extends UseCase<List<Order>, GetShopOrdersParams> {
  final OrderRepository _repository;

  /// Creates a [GetShopOrders] use case.
  GetShopOrders(this._repository);

  @override
  Future<Result<List<Order>>> call(GetShopOrdersParams params) {
    return _repository.getShopOrders(
      status: params.status,
      page: params.page,
      perPage: params.perPage,
    );
  }
}