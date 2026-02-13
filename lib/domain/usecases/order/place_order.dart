// Domain - Use case for placing a new order.
//
// Creates a new order with items, delivery address, and optional
// points redemption and free delivery.

import 'package:injectable/injectable.dart' hide Order;

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order.dart';
import '../../repositories/order_repository.dart';

/// Places a new order.
///
/// Validates items, calculates totals and commissions,
/// applies discounts, and submits the order to the backend.
@lazySingleton
class PlaceOrder extends UseCase<Order, PlaceOrderParams> {
  final OrderRepository _repository;

  /// Creates a [PlaceOrder] use case.
  PlaceOrder(this._repository);

  @override
  Future<Result<Order>> call(PlaceOrderParams params) {
    return _repository.placeOrder(params);
  }
}