// Domain - Use case for fetching order details.
//
// Retrieves the full details of a specific order by ID.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

/// Parameters for fetching order details.
class GetOrderDetailsParams extends Equatable {
  /// The order's unique identifier.
  final String orderId;

  /// Creates [GetOrderDetailsParams].
  const GetOrderDetailsParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Fetches the full details of a specific order.
///
/// Returns the order entity with all items, financial breakdown,
/// status history, and timestamps.
@lazySingleton
class GetOrderDetails extends UseCase<Order, GetOrderDetailsParams> {
  final OrderRepository _repository;

  /// Creates a [GetOrderDetails] use case.
  GetOrderDetails(this._repository);

  @override
  Future<Result<Order>> call(GetOrderDetailsParams params) {
    return _repository.getOrderDetails(params.orderId);
  }
}