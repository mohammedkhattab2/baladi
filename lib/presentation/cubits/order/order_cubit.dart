// Presentation - Order cubit.
//
// Manages order state including listing, details, placing,
// status updates, and cancellation.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart' hide Order;

import '../../../core/error/failures.dart';
import '../../../domain/entities/order.dart';
import '../../../domain/enums/order_status.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/usecases/order/cancel_order.dart';
import '../../../domain/usecases/order/get_order_details.dart';
import '../../../domain/usecases/order/get_orders.dart';
import '../../../domain/usecases/order/place_order.dart';
import '../../../domain/usecases/order/update_order_status.dart';
import 'order_state.dart';

/// Cubit that manages the order lifecycle.
///
/// Handles order listing with pagination, order details,
/// placing new orders, status transitions, and cancellation.
@injectable
class OrderCubit extends Cubit<OrderState> {
  final GetOrders _getOrders;
  final GetOrderDetails _getOrderDetails;
  final PlaceOrder _placeOrder;
  final UpdateOrderStatus _updateOrderStatus;
  final CancelOrder _cancelOrder;

  /// Creates an [OrderCubit].
  OrderCubit({
    required GetOrders getOrders,
    required GetOrderDetails getOrderDetails,
    required PlaceOrder placeOrder,
    required UpdateOrderStatus updateOrderStatus,
    required CancelOrder cancelOrder,
  })  : _getOrders = getOrders,
        _getOrderDetails = getOrderDetails,
        _placeOrder = placeOrder,
        _updateOrderStatus = updateOrderStatus,
        _cancelOrder = cancelOrder,
        super(const OrderInitial());

  /// Fetches the first page of orders, optionally filtered by status.
  Future<void> loadOrders({
    OrderStatus? status,
    int perPage = 20,
  }) async {
    emit(const OrdersLoading());
    final result = await _getOrders(GetOrdersParams(
      status: status,
      page: 1,
      perPage: perPage,
    ));
    result.fold(
      onSuccess: (orders) {
        emit(OrdersLoaded(
          orders: orders,
          currentPage: 1,
          hasMore: orders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(OrderError(message: failure.message));
      },
    );
  }

  /// Loads the next page of orders for pagination.
  Future<void> loadMoreOrders({
    OrderStatus? status,
    int perPage = 20,
  }) async {
    final currentOrders = _currentOrders;
    final currentPage = _currentPage;
    emit(OrdersLoadingMore(orders: currentOrders));
    final result = await _getOrders(GetOrdersParams(
      status: status,
      page: currentPage + 1,
      perPage: perPage,
    ));
    result.fold(
      onSuccess: (newOrders) {
        final allOrders = [...currentOrders, ...newOrders];
        emit(OrdersLoaded(
          orders: allOrders,
          currentPage: currentPage + 1,
          hasMore: newOrders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(OrderError(
          message: failure.message,
          orders: currentOrders,
        ));
      },
    );
  }

  /// Fetches details of a specific order.
  Future<void> loadOrderDetails(String orderId) async {
    emit(const OrderActionLoading());
    final result = await _getOrderDetails(
      GetOrderDetailsParams(orderId: orderId),
    );
    result.fold(
      onSuccess: (order) {
        emit(OrderDetailLoaded(order: order));
      },
      onFailure: (failure) {
        emit(OrderError(message: failure.message));
      },
    );
  }

  /// Places a new order.
  Future<void> placeOrder(PlaceOrderParams params) async {
    emit(const OrderPlacing());
    final result = await _placeOrder(params);
    result.fold(
      onSuccess: (order) {
        emit(OrderPlaced(order: order));
      },
      onFailure: (failure) {
        emit(OrderError(
          message: failure.message,
          fieldErrors:
              failure is ValidationFailure ? failure.fieldErrors : null,
        ));
      },
    );
  }

  /// Updates an order's status (accept, prepare, pickup, deliver, confirm).
  Future<void> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
  }) async {
    final currentOrder = _currentOrder;
    emit(OrderActionLoading(order: currentOrder));
    final result = await _updateOrderStatus(UpdateOrderStatusParams(
      orderId: orderId,
      newStatus: newStatus,
    ));
    result.fold(
      onSuccess: (order) {
        emit(OrderDetailLoaded(order: order));
      },
      onFailure: (failure) {
        emit(OrderError(message: failure.message));
      },
    );
  }

  /// Cancels an order.
  Future<void> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    final currentOrder = _currentOrder;
    emit(OrderActionLoading(order: currentOrder));
    final result = await _cancelOrder(CancelOrderParams(
      orderId: orderId,
      reason: reason,
    ));
    result.fold(
      onSuccess: (order) {
        emit(OrderDetailLoaded(order: order));
      },
      onFailure: (failure) {
        emit(OrderError(message: failure.message));
      },
    );
  }

  /// Extracts current orders list from state if available.
  List<Order> get _currentOrders {
    final s = state;
    if (s is OrdersLoaded) return s.orders;
    if (s is OrdersLoadingMore) return s.orders;
    if (s is OrderError) return s.orders;
    return [];
  }

  /// Extracts current page from state if available.
  int get _currentPage {
    final s = state;
    if (s is OrdersLoaded) return s.currentPage;
    return 1;
  }

  /// Extracts current single order from state if available.
  Order? get _currentOrder {
    final s = state;
    if (s is OrderDetailLoaded) return s.order;
    if (s is OrderActionLoading) return s.order;
    return null;
  }
}