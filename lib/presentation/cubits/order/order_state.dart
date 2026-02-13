// Presentation - Order cubit states.
//
// Defines all possible states for the order feature including
// listing, details, placing, status updates, and cancellation.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';

/// Base state for the order cubit.
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state — orders not yet loaded.
class OrderInitial extends OrderState {
  const OrderInitial();
}

/// Orders are being fetched.
class OrdersLoading extends OrderState {
  const OrdersLoading();
}

/// Orders loaded successfully.
class OrdersLoaded extends OrderState {
  /// The list of orders.
  final List<Order> orders;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const OrdersLoaded({
    required this.orders,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [orders, currentPage, hasMore];
}

/// Loading more orders (pagination).
class OrdersLoadingMore extends OrderState {
  /// The existing orders already loaded.
  final List<Order> orders;

  const OrdersLoadingMore({required this.orders});

  @override
  List<Object?> get props => [orders];
}

/// A single order is being fetched or an action is in progress.
class OrderActionLoading extends OrderState {
  /// The current order (if available before action completes).
  final Order? order;

  const OrderActionLoading({this.order});

  @override
  List<Object?> get props => [order];
}

/// Single order details loaded or action completed successfully.
class OrderDetailLoaded extends OrderState {
  /// The order details.
  final Order order;

  const OrderDetailLoaded({required this.order});

  @override
  List<Object?> get props => [order];
}

/// Order placed successfully.
class OrderPlaced extends OrderState {
  /// The newly placed order.
  final Order order;

  const OrderPlaced({required this.order});

  @override
  List<Object?> get props => [order];
}

/// Order placing is in progress.
class OrderPlacing extends OrderState {
  const OrderPlacing();
}

/// An error occurred during an order operation.
class OrderError extends OrderState {
  /// The error message to display.
  final String message;

  /// Previously loaded orders (for retry UI).
  final List<Order> orders;

  /// Field-level validation errors.
  final Map<String, String>? fieldErrors;

  const OrderError({
    required this.message,
    this.orders = const [],
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, orders, fieldErrors];
}