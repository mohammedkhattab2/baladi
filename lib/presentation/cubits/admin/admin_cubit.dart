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
import '../../../domain/usecases/admin/manage_users.dart';
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
  final ResetUserPassword _resetUserPassword;
  final CreateShopAsAdmin _createShopAsAdmin;
  final UpdateShopAsAdmin _updateShopAsAdmin;
  final CreateRiderAsAdmin _createRiderAsAdmin;
  final UpdateRiderAsAdmin _updateRiderAsAdmin;

  /// Creates an [AdminCubit].
  AdminCubit({
    required GetAdminDashboard getAdminDashboard,
    required CloseWeek closeWeek,
    required AdjustPoints adjustPoints,
    required AdminRepository adminRepository,
    required ResetUserPassword resetUserPassword,
    required CreateShopAsAdmin createShopAsAdmin,
    required UpdateShopAsAdmin updateShopAsAdmin,
    required CreateRiderAsAdmin createRiderAsAdmin,
    required UpdateRiderAsAdmin updateRiderAsAdmin,
  })  : _getAdminDashboard = getAdminDashboard,
        _closeWeek = closeWeek,
        _adjustPoints = adjustPoints,
        _adminRepository = adminRepository,
        _resetUserPassword = resetUserPassword,
        _createShopAsAdmin = createShopAsAdmin,
        _updateShopAsAdmin = updateShopAsAdmin,
        _createRiderAsAdmin = createRiderAsAdmin,
        _updateRiderAsAdmin = updateRiderAsAdmin,
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
  ///
  /// [role] is the optional role filter currently applied in the UI so that
  /// after toggling we reload the list with the same filter instead of
  /// resetting to "all users". This keeps the UX consistent with the
  /// Manage Users flow described in the architecture docs.
  Future<void> toggleUserStatus({
    required String userId,
    required bool isActive,
    String? role,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminActionLoading());

    final result = await _adminRepository.toggleUserStatus(
      userId: userId,
      isActive: isActive,
    );

    result.fold(
      onSuccess: (_) async {
        await loadUsers(
          role: role,
          perPage: perPage,
        );
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // User password management
  // ---------------------------------------------------------------------------

  /// Resets a staff user's password (shop / rider / admin).
  ///
  /// This should only be used for non-customer accounts. The backend enforces:
  /// - 8+ chars
  /// - at least one uppercase, one lowercase, and one digit
  Future<void> resetUserPassword({
    required String userId,
    required String newPassword,
  }) async {
    emit(const AdminActionLoading());

    final result = await _resetUserPassword(
      ResetUserPasswordParams(
        userId: userId,
        newPassword: newPassword,
      ),
    );

    result.fold(
      onSuccess: (_) {
        emit(const AdminUserPasswordReset());
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

  /// Creates a new shop (with owner user) from the admin panel.
  ///
  /// [payload] should follow the backend Joi schema for:
  ///   POST /api/admin/shops
  Future<void> createShopAsAdmin({
    required Map<String, dynamic> payload,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminActionLoading());

    final result = await _createShopAsAdmin(
      CreateShopAsAdminParams(payload: payload),
    );

    result.fold(
      onSuccess: (_) async {
        // Reload shops list so UI reflects the newly created shop.
        await loadShops(perPage: perPage);
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Updates an existing shop from the admin panel.
  ///
  /// [shopId] is the ID of the shop to update.
  /// [payload] is sent as-is to:
  ///   PUT /api/admin/shops/:shopId
  Future<void> updateShopAsAdmin({
    required String shopId,
    required Map<String, dynamic> payload,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminActionLoading());

    final result = await _updateShopAsAdmin(
      UpdateShopAsAdminParams(
        shopId: shopId,
        payload: payload,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        await loadShops(perPage: perPage);
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

  /// Creates a new rider (with user account) from the admin panel.
  ///
  /// [payload] should follow the backend Joi schema for:
  ///   POST /api/admin/riders
  Future<void> createRiderAsAdmin({
    required Map<String, dynamic> payload,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminActionLoading());

    final result = await _createRiderAsAdmin(
      CreateRiderAsAdminParams(payload: payload),
    );

    result.fold(
      onSuccess: (_) async {
        // Reload riders list so UI reflects the newly created rider.
        await loadRiders(perPage: perPage);
      },
      onFailure: (failure) {
        emit(AdminError(message: failure.message));
      },
    );
  }

  /// Updates an existing rider from the admin panel.
  ///
  /// [riderId] is the ID of the rider to update.
  /// [payload] is sent as-is to:
  ///   PUT /api/admin/riders/:riderId
  Future<void> updateRiderAsAdmin({
    required String riderId,
    required Map<String, dynamic> payload,
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const AdminActionLoading());

    final result = await _updateRiderAsAdmin(
      UpdateRiderAsAdminParams(
        riderId: riderId,
        payload: payload,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        await loadRiders(perPage: perPage);
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