// Domain - Use case for shop confirming cash received from rider.
//
// Transitions order from shop_paid → completed after the shop
// confirms the rider has handed over cash collected from the customer.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

/// Parameters for confirming cash received.
class ConfirmCashReceivedParams extends Equatable {
  /// The order ID for which cash was received.
  final String orderId;

  /// Creates [ConfirmCashReceivedParams].
  const ConfirmCashReceivedParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Shop confirms cash received from rider.
///
/// Transitions: shop_paid → completed.
@lazySingleton
class ConfirmCashReceived extends UseCase<Order, ConfirmCashReceivedParams> {
  final OrderRepository _repository;

  /// Creates a [ConfirmCashReceived] use case.
  ConfirmCashReceived(this._repository);

  @override
  Future<Result<Order>> call(ConfirmCashReceivedParams params) {
    return _repository.confirmCashReceived(params.orderId);
  }
}