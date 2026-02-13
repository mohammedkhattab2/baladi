// Presentation - Admin cubit.
//
// Manages admin state including dashboard, user/shop/rider management,
// orders, weekly periods, points adjustments, and user status toggling.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/repositories/admin_repository.dart';
import '../../../domain/usecases/admin/adjust_points.dart';
import '../../../domain/usecases/admin/close_week.dart';
import '../../../domain/usecases/admin/get_admin_dashboard.dart';
import 'admin_state.dart';

/// Cubit that manages all admin-related operations.
///
/// Handles dashboard loading, user/shop/rider listing, order viewing,
/// weekly period management, points adjustments, and user status toggling.
@injectable
class AdminCubit extends Cubit<AdminState> {
  final GetAdminDashboard _getAdminDashboard;
  final CloseWeek _closeWeek;
  final AdjustPoints _adjustPoints;
  final AdminRepository _adminRepository;

  /// Creates an [AdminCubit].
  AdminCubit({
    required GetAdminDashboard getAdminDashboard,
    required CloseWeek closeWeek,
    required AdjustPoints adjustPoints,
    required AdminRepository adminRepository,
  })  : _getAdminDashboard = getAdminDashboard,
        _closeWeek = closeWeek,
        _adjustPoints = adjustPoints,
        _adminRepository = adminRepository,
        super(const AdminInitial());

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  /// Loads the admin dashboard statistics.
  Future<void> loadDashboard() async {
    emit(const AdminLoading());

    final result = await _getAdminDashboard(const NoParams());

    result.fold(
      onSuccess: (dashboard) {
        emit(AdminDashboardLoaded(dashboard: dashboard));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Users
  // ---------------------------------------------------------------------------

  /// Loads users, optionally filtered by role.
  Future<void> loadUsers({
    String? role,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminLoading());

    final result = await _adminRepository.getUsers(
      role: role,
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (users) {
        emit(AdminUsersLoaded(
          users: users,
          currentPage: 1,
          hasMore: users.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Loads more users (next page).
  Future<void> loadMoreUsers({
    String? role,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! AdminUsersLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _adminRepository.getUsers(
      role: role,
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newUsers) {
        emit(AdminUsersLoaded(
          users: [...currentState.users, ...newUsers],
          currentPage: nextPage,
          hasMore: newUsers.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Toggles a user's active status.
  Future<void> toggleUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    emit(const AdminActionLoading());

    final result = await _adminRepository.toggleUserStatus(
      userId: userId,
      isActive: isActive,
    );

    result.fold(
      onSuccess: (_) async {
        await loadUsers();
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Shops
  // ---------------------------------------------------------------------------

  /// Loads all registered shops.
  Future<void> loadShops({int perPage = AppConstants.defaultPageSize}) async {
    emit(const AdminLoading());

    final result = await _adminRepository.getShops(
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (shops) {
        emit(AdminShopsLoaded(
          shops: shops,
          currentPage: 1,
          hasMore: shops.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Loads more shops (next page).
  Future<void> loadMoreShops({int perPage = AppConstants.defaultPageSize}) async {
    final currentState = state;
    if (currentState is! AdminShopsLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _adminRepository.getShops(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newShops) {
        emit(AdminShopsLoaded(
          shops: [...currentState.shops, ...newShops],
          currentPage: nextPage,
          hasMore: newShops.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Riders
  // ---------------------------------------------------------------------------

  /// Loads all registered riders.
  Future<void> loadRiders({int perPage = AppConstants.defaultPageSize}) async {
    emit(const AdminLoading());

    final result = await _adminRepository.getRiders(
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (riders) {
        emit(AdminRidersLoaded(
          riders: riders,
          currentPage: 1,
          hasMore: riders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Loads more riders (next page).
  Future<void> loadMoreRiders({int perPage = AppConstants.defaultPageSize}) async {
    final currentState = state;
    if (currentState is! AdminRidersLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _adminRepository.getRiders(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newRiders) {
        emit(AdminRidersLoaded(
          riders: [...currentState.riders, ...newRiders],
          currentPage: nextPage,
          hasMore: newRiders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Orders
  // ---------------------------------------------------------------------------

  /// Loads all orders (admin view), optionally filtered by status.
  Future<void> loadOrders({
    String? status,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminLoading());

    final result = await _adminRepository.getOrders(
      status: status,
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (orders) {
        emit(AdminOrdersLoaded(
          orders: orders,
          currentPage: 1,
          hasMore: orders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Loads more orders (next page).
  Future<void> loadMoreOrders({
    String? status,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! AdminOrdersLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _adminRepository.getOrders(
      status: status,
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newOrders) {
        emit(AdminOrdersLoaded(
          orders: [...currentState.orders, ...newOrders],
          currentPage: nextPage,
          hasMore: newOrders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Weekly Periods
  // ---------------------------------------------------------------------------

  /// Loads weekly periods.
  Future<void> loadPeriods({int perPage = AppConstants.defaultPageSize}) async {
    emit(const AdminLoading());

    final result = await _adminRepository.getPeriods(
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (periods) {
        emit(AdminPeriodsLoaded(
          periods: periods,
          currentPage: 1,
          hasMore: periods.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Loads more periods (next page).
  Future<void> loadMorePeriods({int perPage = AppConstants.defaultPageSize}) async {
    final currentState = state;
    if (currentState is! AdminPeriodsLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _adminRepository.getPeriods(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newPeriods) {
        emit(AdminPeriodsLoaded(
          periods: [...currentState.periods, ...newPeriods],
          currentPage: nextPage,
          hasMore: newPeriods.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Closes the current active weekly period.
  Future<void> closeCurrentWeek() async {
    emit(const AdminActionLoading());

    final result = await _closeWeek(const NoParams());

    result.fold(
      onSuccess: (closedPeriod) {
        emit(AdminWeekClosed(closedPeriod: closedPeriod));
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Points Adjustment
  // ---------------------------------------------------------------------------

  /// Adjusts a customer's points balance.
  ///
  /// - [customerId]: The customer's unique identifier.
  /// - [points]: Points to add (positive) or subtract (negative).
  /// - [reason]: Reason for the adjustment.
  Future<void> adjustPoints({
    required String customerId,
    required int points,
    required String reason,
  }) async {
    emit(const AdminActionLoading());

    final result = await _adjustPoints(AdjustPointsParams(
      customerId: customerId,
      points: points,
      reason: reason,
    ));

    result.fold(
      onSuccess: (_) {
        emit(const AdminPointsAdjusted());
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }
}