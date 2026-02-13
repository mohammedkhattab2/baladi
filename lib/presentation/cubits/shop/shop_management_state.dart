// Presentation - Shop management cubit states.
//
// Defines all possible states for the shop management feature including
// dashboard, shop status, products, orders, and settlements.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/entities/product.dart';
import '../../../domain/entities/shop.dart';
import '../../../domain/entities/shop_settlement.dart';
import '../../../domain/repositories/shop_repository.dart';

/// Base state for the shop management cubit.
abstract class ShopManagementState extends Equatable {
  const ShopManagementState();

  @override
  List<Object?> get props => [];
}

/// Initial state — shop data not yet loaded.
class ShopManagementInitial extends ShopManagementState {
  const ShopManagementInitial();
}

/// Shop data is being fetched.
class ShopManagementLoading extends ShopManagementState {
  const ShopManagementLoading();
}

/// Shop dashboard loaded successfully.
class ShopDashboardLoaded extends ShopManagementState {
  /// The shop's profile.
  final Shop shop;

  /// Dashboard statistics.
  final ShopDashboard dashboard;

  const ShopDashboardLoaded({
    required this.shop,
    required this.dashboard,
  });

  @override
  List<Object?> get props => [shop, dashboard];
}

/// Shop status is being toggled (open/closed).
class ShopStatusToggling extends ShopManagementState {
  /// Current shop profile.
  final Shop shop;

  const ShopStatusToggling({required this.shop});

  @override
  List<Object?> get props => [shop];
}

/// Shop's own products loaded.
class ShopProductsLoaded extends ShopManagementState {
  /// The list of shop products.
  final List<Product> products;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const ShopProductsLoaded({
    required this.products,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [products, currentPage, hasMore];
}

/// A product action (create/update/delete) is in progress.
class ShopProductActionLoading extends ShopManagementState {
  /// Existing products list to preserve UI.
  final List<Product> products;

  const ShopProductActionLoading({required this.products});

  @override
  List<Object?> get props => [products];
}

/// Shop orders loaded.
class ShopOrdersLoaded extends ShopManagementState {
  /// The list of shop orders.
  final List<Order> orders;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const ShopOrdersLoaded({
    required this.orders,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [orders, currentPage, hasMore];
}

/// Shop settlements loaded.
class ShopSettlementsLoaded extends ShopManagementState {
  /// Settlement history.
  final List<ShopSettlement> settlements;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const ShopSettlementsLoaded({
    required this.settlements,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [settlements, currentPage, hasMore];
}

/// An error occurred during a shop management operation.
class ShopManagementError extends ShopManagementState {
  /// The error message to display.
  final String message;

  /// Optional field-level validation errors.
  final Map<String, String>? fieldErrors;

  const ShopManagementError({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}