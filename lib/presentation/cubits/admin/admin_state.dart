// Presentation - Admin cubit states.
//
// Defines all possible states for the admin feature including
// dashboard, user management, periods, and points adjustments.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/order.dart';
import '../../../domain/entities/rider.dart';
import '../../../domain/entities/shop.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/entities/weekly_period.dart';
import '../../../domain/repositories/admin_repository.dart';

/// Base state for the admin cubit.
abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

/// Initial state — admin data not yet loaded.
class AdminInitial extends AdminState {
  const AdminInitial();
}

/// Admin data is being fetched.
class AdminLoading extends AdminState {
  const AdminLoading();
}

/// Admin dashboard loaded successfully.
class AdminDashboardLoaded extends AdminState {
  /// Dashboard statistics.
  final AdminDashboard dashboard;

  const AdminDashboardLoaded({required this.dashboard});

  @override
  List<Object?> get props => [dashboard];
}

/// Users list loaded.
class AdminUsersLoaded extends AdminState {
  /// The list of users.
  final List<User> users;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const AdminUsersLoaded({
    required this.users,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [users, currentPage, hasMore];
}

/// Shops list loaded.
class AdminShopsLoaded extends AdminState {
  /// The list of shops.
  final List<Shop> shops;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const AdminShopsLoaded({
    required this.shops,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [shops, currentPage, hasMore];
}

/// Riders list loaded.
class AdminRidersLoaded extends AdminState {
  /// The list of riders.
  final List<Rider> riders;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const AdminRidersLoaded({
    required this.riders,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [riders, currentPage, hasMore];
}

/// Orders list loaded (admin view).
class AdminOrdersLoaded extends AdminState {
  /// The list of orders.
  final List<Order> orders;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const AdminOrdersLoaded({
    required this.orders,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [orders, currentPage, hasMore];
}

/// Weekly periods loaded.
class AdminPeriodsLoaded extends AdminState {
  /// The list of weekly periods.
  final List<WeeklyPeriod> periods;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const AdminPeriodsLoaded({
    required this.periods,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [periods, currentPage, hasMore];
}

/// An admin action (close week, adjust points, toggle user, reset password) is in progress.
class AdminActionLoading extends AdminState {
  const AdminActionLoading();
}

/// Week was closed successfully.
class AdminWeekClosed extends AdminState {
  /// The closed period.
  final WeeklyPeriod closedPeriod;

  const AdminWeekClosed({required this.closedPeriod});

  @override
  List<Object?> get props => [closedPeriod];
}

/// Points adjustment completed successfully.
class AdminPointsAdjusted extends AdminState {
  const AdminPointsAdjusted();
}

/// Staff user password was reset successfully.
///
/// Used when the admin triggers a password reset for a shop / rider / admin
/// account from the Manage Users screen.
class AdminUserPasswordReset extends AdminState {
  /// Optional success message from backend (if provided).
  final String? message;

  const AdminUserPasswordReset({this.message});

  @override
  List<Object?> get props => [message];
}

/// An error occurred during an admin operation.
class AdminError extends AdminState {
  /// The error message to display.
  final String message;

  const AdminError({required this.message});

  @override
  List<Object?> get props => [message];
}