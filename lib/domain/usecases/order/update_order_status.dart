// Domain - Use case for updating order status.
//
// Handles all order status transitions: accept, prepare,
// pickup, deliver, and confirm cash.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/error/failures.dart';
import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../enums/order_status.dart';
import '../../repositories/order_repository.dart';

/// Parameters for updating order status.
class UpdateOrderStatusParams extends Equatable {
  /// The order's unique identifier.
  final String orderId;

  /// The new status to transition to.
  final OrderStatus newStatus;

  /// Creates [UpdateOrderStatusParams].
  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
  });

  @override
  List<Object?> get props => [orderId, newStatus];
}

/// Updates an order's status through the lifecycle.
///
/// Delegates to the appropriate repository method based on
/// the target status:
/// - [OrderStatus.accepted] → acceptOrder
/// - [OrderStatus.preparing] → markPreparing
/// - [OrderStatus.pickedUp] → markPickedUp
/// - [OrderStatus.shopPaid] → markDelivered
/// - [OrderStatus.completed] → confirmCashReceived
@lazySingleton
class UpdateOrderStatus extends UseCase<Order, UpdateOrderStatusParams> {
  final OrderRepository _repository;

  /// Creates an [UpdateOrderStatus] use case.
  UpdateOrderStatus(this._repository);

  @override
  Future<Result<Order>> call(UpdateOrderStatusParams params) {
    switch (params.newStatus) {
      case OrderStatus.accepted:
        return _repository.acceptOrder(params.orderId);
      case OrderStatus.preparing:
        return _repository.markPreparing(params.orderId);
      case OrderStatus.pickedUp:
        return _repository.markPickedUp(params.orderId);
      case OrderStatus.shopPaid:
        return _repository.markDelivered(params.orderId);
      case OrderStatus.completed:
        return _repository.confirmCashReceived(params.orderId);
      case OrderStatus.pending:
      case OrderStatus.cancelled:
        return Future.value(
          ResultFailure<Order>(
            const ValidationFailure(
              message: 'لا يمكن الانتقال إلى هذه الحالة مباشرة',
              fieldErrors: {'status': 'حالة غير صالحة'},
            ),
          ),
        );
    }
  }
}