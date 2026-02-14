// Domain - Use case for rider accepting a delivery.
//
// Marks an order as picked up by the rider, transitioning
// from preparing → picked_up status.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

/// Parameters for accepting a delivery.
class AcceptDeliveryParams extends Equatable {
  /// The order ID to accept for delivery.
  final String orderId;

  /// Creates [AcceptDeliveryParams].
  const AcceptDeliveryParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Rider accepts a delivery by marking the order as picked up.
///
/// Transitions: preparing → picked_up.
@lazySingleton
class AcceptDelivery extends UseCase<Order, AcceptDeliveryParams> {
  final OrderRepository _repository;

  /// Creates an [AcceptDelivery] use case.
  AcceptDelivery(this._repository);

  @override
  Future<Result<Order>> call(AcceptDeliveryParams params) {
    return _repository.markPickedUp(params.orderId);
  }
}