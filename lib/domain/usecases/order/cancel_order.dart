// Domain - Use case for cancelling an order.
//
// Cancels an order that is in pending or accepted status.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

/// Parameters for cancelling an order.
class CancelOrderParams extends Equatable {
  /// The order's unique identifier.
  final String orderId;

  /// Optional cancellation reason.
  final String? reason;

  /// Creates [CancelOrderParams].
  const CancelOrderParams({
    required this.orderId,
    this.reason,
  });

  @override
  List<Object?> get props => [orderId, reason];
}

/// Cancels an order.
///
/// Only allowed from pending or accepted status.
/// Returns the updated order with cancelled status.
@lazySingleton
class CancelOrder extends UseCase<Order, CancelOrderParams> {
  final OrderRepository _repository;

  /// Creates a [CancelOrder] use case.
  CancelOrder(this._repository);

  @override
  Future<Result<Order>> call(CancelOrderParams params) {
    return _repository.cancelOrder(
      orderId: params.orderId,
      reason: params.reason,
    );
  }
}