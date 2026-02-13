// Presentation - Rider cubit.
//
// Manages rider state including dashboard, availability toggling,
// available orders, rider orders, settlements, and order status updates.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../../domain/enums/order_status.dart';
import '../../../domain/repositories/rider_repository.dart';
import '../../../domain/usecases/order/update_order_status.dart';
import '../../../domain/usecases/rider/get_available_orders.dart';
import '../../../domain/usecases/rider/get_rider_dashboard.dart';
import '../../../domain/usecases/rider/get_rider_orders.dart';
import '../../../domain/usecases/rider/toggle_availability.dart';
import 'rider_state.dart';

/// Cubit that manages all rider-related operations.
///
/// Handles dashboard loading, availability toggling, available orders,
/// rider orders, settlements, and order status transitions (pickup, deliver,
/// confirm cash).
@injectable
class RiderCubit extends Cubit<RiderState> {
  final GetRiderDashboard _getRiderDashboard;
  final ToggleAvailability _toggleAvailability;
  final GetAvailableOrders _getAvailableOrders;
  final GetRiderOrders _getRiderOrders;
  final UpdateOrderStatus _updateOrderStatus;
  final RiderRepository _riderRepository;

  /// Creates a [RiderCubit].
  RiderCubit({
    required GetRiderDashboard getRiderDashboard,
    required ToggleAvailability toggleAvailability,
    required GetAvailableOrders getAvailableOrders,
    required GetRiderOrders getRiderOrders,
    required UpdateOrderStatus updateOrderStatus,
    required RiderRepository riderRepository,
  })  : _getRiderDashboard = getRiderDashboard,
        _toggleAvailability = toggleAvailability,
        _getAvailableOrders = getAvailableOrders,
        _getRiderOrders = getRiderOrders,
        _updateOrderStatus = updateOrderStatus,
        _riderRepository = riderRepository,
        super(const RiderInitial());

  // ---------------------------------------------------------------------------
  // Dashboard
  // ---------------------------------------------------------------------------

  /// Loads the rider profile and dashboard statistics.
  Future<void> loadDashboard() async {
    emit(const RiderLoading());

    final results = await Future.wait([
      _riderRepository.getRiderProfile(),
      _getRiderDashboard(const NoParams()),
    ]);

    final profileResult = results[0] as Result;
    final dashboardResult = results[1] as Result;

    if (profileResult.isSuccess && dashboardResult.isSuccess) {
      emit(RiderDashboardLoaded(
        rider: profileResult.data,
        dashboard: dashboardResult.data,
      ));
    } else {
      final failure = profileResult.isFailure
          ? profileResult.failure
          : dashboardResult.failure;
      emit(RiderError(message: failure!.message));
    }
  }

  // ---------------------------------------------------------------------------
  // Availability
  // ---------------------------------------------------------------------------

  /// Toggles the rider's availability status.
  ///
  /// - [isAvailable]: The desired availability state.
  Future<void> toggleAvailability({required bool isAvailable}) async {
    final currentState = state;
    if (currentState is RiderDashboardLoaded) {
      emit(RiderTogglingAvailability(rider: currentState.rider));
    }

    final result = await _toggleAvailability(
      ToggleAvailabilityParams(isAvailable: isAvailable),
    );

    result.fold(
      onSuccess: (rider) async {
        // Reload dashboard to reflect new availability
        await loadDashboard();
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Available Orders
  // ---------------------------------------------------------------------------

  /// Loads orders available for pickup.
  Future<void> loadAvailableOrders({int perPage = AppConstants.defaultPageSize}) async {
    emit(const RiderLoading());

    final result = await _getAvailableOrders(
      GetAvailableOrdersParams(page: 1, perPage: perPage),
    );

    result.fold(
      onSuccess: (orders) {
        emit(RiderAvailableOrdersLoaded(
          availableOrders: orders,
          currentPage: 1,
          hasMore: orders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  /// Loads more available orders (next page).
  Future<void> loadMoreAvailableOrders({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! RiderAvailableOrdersLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _getAvailableOrders(
      GetAvailableOrdersParams(page: nextPage, perPage: perPage),
    );

    result.fold(
      onSuccess: (newOrders) {
        emit(RiderAvailableOrdersLoaded(
          availableOrders: [...currentState.availableOrders, ...newOrders],
          currentPage: nextPage,
          hasMore: newOrders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Rider Orders
  // ---------------------------------------------------------------------------

  /// Loads the rider's assigned/completed orders.
  Future<void> loadRiderOrders({int perPage = AppConstants.defaultPageSize}) async {
    emit(const RiderLoading());

    final result = await _getRiderOrders(
      GetRiderOrdersParams(page: 1, perPage: perPage),
    );

    result.fold(
      onSuccess: (orders) {
        emit(RiderOrdersLoaded(
          orders: orders,
          currentPage: 1,
          hasMore: orders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  /// Loads more rider orders (next page).
  Future<void> loadMoreRiderOrders({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! RiderOrdersLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _getRiderOrders(
      GetRiderOrdersParams(page: nextPage, perPage: perPage),
    );

    result.fold(
      onSuccess: (newOrders) {
        emit(RiderOrdersLoaded(
          orders: [...currentState.orders, ...newOrders],
          currentPage: nextPage,
          hasMore: newOrders.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Settlements
  // ---------------------------------------------------------------------------

  /// Loads the rider's settlement history.
  Future<void> loadSettlements({int perPage = AppConstants.defaultPageSize}) async {
    emit(const RiderLoading());

    final result = await _riderRepository.getSettlements(
      page: 1,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (settlements) {
        emit(RiderSettlementsLoaded(
          settlements: settlements,
          currentPage: 1,
          hasMore: settlements.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  /// Loads more settlements (next page).
  Future<void> loadMoreSettlements({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    final currentState = state;
    if (currentState is! RiderSettlementsLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;

    final result = await _riderRepository.getSettlements(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newSettlements) {
        emit(RiderSettlementsLoaded(
          settlements: [...currentState.settlements, ...newSettlements],
          currentPage: nextPage,
          hasMore: newSettlements.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Order Actions (pickup, deliver, confirm cash)
  // ---------------------------------------------------------------------------

  /// Picks up an order (transitions to [OrderStatus.pickedUp]).
  Future<void> pickupOrder(String orderId) async {
    final result = await _updateOrderStatus(
      UpdateOrderStatusParams(
        orderId: orderId,
        newStatus: OrderStatus.pickedUp,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        // Refresh available orders after pickup
        await loadAvailableOrders();
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  /// Marks an order as delivered (transitions to [OrderStatus.shopPaid]).
  Future<void> deliverOrder(String orderId) async {
    final result = await _updateOrderStatus(
      UpdateOrderStatusParams(
        orderId: orderId,
        newStatus: OrderStatus.shopPaid,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        await loadRiderOrders();
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }

  /// Confirms cash received for an order (transitions to [OrderStatus.completed]).
  Future<void> confirmCash(String orderId) async {
    final result = await _updateOrderStatus(
      UpdateOrderStatusParams(
        orderId: orderId,
        newStatus: OrderStatus.completed,
      ),
    );

    result.fold(
      onSuccess: (_) async {
        await loadRiderOrders();
      },
      onFailure: (failure) {
        emit(RiderError(message: failure.message));
      },
    );
  }
}