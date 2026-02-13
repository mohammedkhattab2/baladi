// Presentation - Points cubit.
//
// Manages loyalty points state including balance retrieval
// and transaction history with pagination.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/entities/points_transaction.dart';
import '../../../domain/usecases/points/get_points_balance.dart';
import '../../../domain/usecases/points/get_points_history.dart';
import 'points_state.dart';

/// Cubit that manages the loyalty points lifecycle.
///
/// Handles balance retrieval and paginated transaction history.
@injectable
class PointsCubit extends Cubit<PointsState> {
  final GetPointsBalance _getPointsBalance;
  final GetPointsHistory _getPointsHistory;

  /// Creates a [PointsCubit].
  PointsCubit({
    required GetPointsBalance getPointsBalance,
    required GetPointsHistory getPointsHistory,
  })  : _getPointsBalance = getPointsBalance,
        _getPointsHistory = getPointsHistory,
        super(const PointsInitial());

  /// Loads the points balance and first page of history.
  Future<void> loadPoints({int perPage = 20}) async {
    emit(const PointsLoading());

    // Fetch balance and first page of history concurrently.
    final results = await Future.wait([
      _getPointsBalance(const NoParams()),
      _getPointsHistory(GetPointsHistoryParams(page: 1, perPage: perPage)),
    ]);

    final balanceResult = results[0] as dynamic;
    final historyResult = results[1] as dynamic;

    if (balanceResult.isFailure) {
      emit(PointsError(message: balanceResult.failure.message));
      return;
    }

    final balance = balanceResult.data as int;
    List<PointsTransaction> history = [];
    bool hasMore = false;

    if (historyResult.isSuccess) {
      history = historyResult.data as List<PointsTransaction>;
      hasMore = history.length >= perPage;
    }

    emit(PointsLoaded(
      balance: balance,
      history: history,
      currentPage: 1,
      hasMore: hasMore,
    ));
  }

  /// Refreshes only the points balance.
  Future<void> refreshBalance() async {
    final result = await _getPointsBalance(const NoParams());
    result.fold(
      onSuccess: (balance) {
        final s = state;
        if (s is PointsLoaded) {
          emit(PointsLoaded(
            balance: balance,
            history: s.history,
            currentPage: s.currentPage,
            hasMore: s.hasMore,
          ));
        } else {
          emit(PointsLoaded(balance: balance));
        }
      },
      onFailure: (failure) {
        emit(PointsError(
          message: failure.message,
          balance: _currentBalance,
        ));
      },
    );
  }

  /// Loads the next page of points history.
  Future<void> loadMoreHistory({int perPage = 20}) async {
    final currentBalance = _currentBalance ?? 0;
    final currentHistory = _currentHistory;
    final currentPage = _currentPage;

    emit(PointsLoadingMore(
      balance: currentBalance,
      history: currentHistory,
    ));

    final result = await _getPointsHistory(GetPointsHistoryParams(
      page: currentPage + 1,
      perPage: perPage,
    ));

    result.fold(
      onSuccess: (newHistory) {
        final allHistory = [...currentHistory, ...newHistory];
        emit(PointsLoaded(
          balance: currentBalance,
          history: allHistory,
          currentPage: currentPage + 1,
          hasMore: newHistory.length >= perPage,
        ));
      },
      onFailure: (failure) {
        emit(PointsError(
          message: failure.message,
          balance: currentBalance,
        ));
      },
    );
  }

  /// Extracts current balance from state if available.
  int? get _currentBalance {
    final s = state;
    if (s is PointsLoaded) return s.balance;
    if (s is PointsLoadingMore) return s.balance;
    if (s is PointsError) return s.balance;
    return null;
  }

  /// Extracts current history from state if available.
  List<PointsTransaction> get _currentHistory {
    final s = state;
    if (s is PointsLoaded) return s.history;
    if (s is PointsLoadingMore) return s.history;
    return [];
  }

  /// Extracts current page from state if available.
  int get _currentPage {
    final s = state;
    if (s is PointsLoaded) return s.currentPage;
    return 1;
  }
}