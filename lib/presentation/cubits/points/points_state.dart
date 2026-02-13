// Presentation - Points cubit states.
//
// Defines all possible states for the loyalty points feature
// including balance, history, and loading states.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/points_transaction.dart';

/// Base state for the points cubit.
abstract class PointsState extends Equatable {
  const PointsState();

  @override
  List<Object?> get props => [];
}

/// Initial state — points not yet loaded.
class PointsInitial extends PointsState {
  const PointsInitial();
}

/// Points data is being fetched.
class PointsLoading extends PointsState {
  const PointsLoading();
}

/// Points data loaded successfully.
class PointsLoaded extends PointsState {
  /// Current points balance.
  final int balance;

  /// Points transaction history.
  final List<PointsTransaction> history;

  /// Current page number.
  final int currentPage;

  /// Whether more history pages are available.
  final bool hasMore;

  const PointsLoaded({
    required this.balance,
    this.history = const [],
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [balance, history, currentPage, hasMore];
}

/// Loading more points history (pagination).
class PointsLoadingMore extends PointsState {
  /// Current balance.
  final int balance;

  /// Existing history already loaded.
  final List<PointsTransaction> history;

  const PointsLoadingMore({
    required this.balance,
    required this.history,
  });

  @override
  List<Object?> get props => [balance, history];
}

/// An error occurred while loading points data.
class PointsError extends PointsState {
  /// The error message to display.
  final String message;

  /// Previously loaded balance (for retry UI).
  final int? balance;

  const PointsError({
    required this.message,
    this.balance,
  });

  @override
  List<Object?> get props => [message, balance];
}