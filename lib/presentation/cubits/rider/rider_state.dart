// Presentation - Rider cubit states.
//
// Defines all possible states for the rider feature including
// dashboard, availability, orders, and settlements.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/entities/rider.dart';
import '../../../domain/entities/rider_settlement.dart';
import '../../../domain/repositories/rider_repository.dart';

/// Base state for the rider cubit.
abstract class RiderState extends Equatable {
  const RiderState();

  @override
  List<Object?> get props => [];
}

/// Initial state — rider data not yet loaded.
class RiderInitial extends RiderState {
  const RiderInitial();
}

/// Rider data is being fetched.
class RiderLoading extends RiderState {
  const RiderLoading();
}

/// Rider dashboard loaded successfully.
class RiderDashboardLoaded extends RiderState {
  /// The rider's profile.
  final Rider rider;

  /// Dashboard statistics.
  final RiderDashboard dashboard;

  const RiderDashboardLoaded({
    required this.rider,
    required this.dashboard,
  });

  @override
  List<Object?> get props => [rider, dashboard];
}

/// Rider availability is being toggled.
class RiderTogglingAvailability extends RiderState {
  /// Current rider profile.
  final Rider rider;

  const RiderTogglingAvailability({required this.rider});

  @override
  List<Object?> get props => [rider];
}

/// Available orders loaded for the rider.
class RiderAvailableOrdersLoaded extends RiderState {
  /// Orders available for pickup.
  final List<Order> availableOrders;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const RiderAvailableOrdersLoaded({
    required this.availableOrders,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [availableOrders, currentPage, hasMore];
}

/// Rider's assigned/completed orders loaded.
class RiderOrdersLoaded extends RiderState {
  /// The rider's orders.
  final List<Order> orders;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const RiderOrdersLoaded({
    required this.orders,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [orders, currentPage, hasMore];
}

/// Rider settlements loaded.
class RiderSettlementsLoaded extends RiderState {
  /// Settlement history.
  final List<RiderSettlement> settlements;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const RiderSettlementsLoaded({
    required this.settlements,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [settlements, currentPage, hasMore];
}

/// An error occurred during a rider operation.
class RiderError extends RiderState {
  /// The error message to display.
  final String message;

  const RiderError({required this.message});

  @override
  List<Object?> get props => [message];
}