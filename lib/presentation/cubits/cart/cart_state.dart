// Presentation - Cart cubit states.
//
// Defines all possible states for the shopping cart feature
// including item management, totals, and checkout readiness.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/order_item.dart';

/// Base state for the cart cubit.
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state — cart not yet loaded.
class CartInitial extends CartState {
  const CartInitial();
}

/// Cart is being loaded from local storage.
class CartLoading extends CartState {
  const CartLoading();
}

/// Cart loaded successfully.
class CartLoaded extends CartState {
  /// The shop ID associated with the current cart.
  final String? shopId;

  /// Items in the cart.
  final List<OrderItem> items;

  /// Total number of individual items (sum of quantities).
  final int totalItems;

  /// Subtotal before delivery fee and discounts.
  final double subtotal;

  const CartLoaded({
    this.shopId,
    required this.items,
    required this.totalItems,
    required this.subtotal,
  });

  /// Whether the cart is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the cart has items.
  bool get isNotEmpty => items.isNotEmpty;

  @override
  List<Object?> get props => [shopId, items, totalItems, subtotal];
}

/// An error occurred during a cart operation.
class CartError extends CartState {
  /// The error message to display.
  final String message;

  /// Current cart items (for retry UI).
  final List<OrderItem> items;

  const CartError({
    required this.message,
    this.items = const [],
  });

  @override
  List<Object?> get props => [message, items];
}