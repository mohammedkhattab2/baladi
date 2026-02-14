// Presentation - Settlement cubit states.
//
// Immutable states for the settlement screen covering
// weekly period listing, settlement report loading, and errors.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/rider_settlement.dart';
import '../../../domain/entities/shop_settlement.dart';
import '../../../domain/entities/weekly_period.dart';
import '../../../domain/usecases/admin/get_settlement_report.dart';

/// Base state for the settlement cubit.
sealed class SettlementState extends Equatable {
  const SettlementState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded.
class SettlementInitial extends SettlementState {
  const SettlementInitial();
}

/// Loading state while fetching settlement data.
class SettlementLoading extends SettlementState {
  const SettlementLoading();
}

/// State when weekly periods have been loaded.
class SettlementPeriodsLoaded extends SettlementState {
  /// List of weekly periods.
  final List<WeeklyPeriod> periods;

  /// The currently active period (if any).
  final WeeklyPeriod? currentPeriod;

  const SettlementPeriodsLoaded({
    required this.periods,
    this.currentPeriod,
  });

  @override
  List<Object?> get props => [periods, currentPeriod];
}

/// State when a full settlement report for a period is loaded.
class SettlementReportLoaded extends SettlementState {
  /// The aggregated settlement report.
  final SettlementReport report;

  const SettlementReportLoaded({required this.report});

  @override
  List<Object?> get props => [report];
}

/// State when a single shop settlement detail is loaded.
class ShopSettlementDetailLoaded extends SettlementState {
  /// The shop settlement detail.
  final ShopSettlement settlement;

  const ShopSettlementDetailLoaded({required this.settlement});

  @override
  List<Object?> get props => [settlement];
}

/// State when a single rider settlement detail is loaded.
class RiderSettlementDetailLoaded extends SettlementState {
  /// The rider settlement detail.
  final RiderSettlement settlement;

  const RiderSettlementDetailLoaded({required this.settlement});

  @override
  List<Object?> get props => [settlement];
}

/// State when the current week has been successfully closed.
class SettlementWeekClosed extends SettlementState {
  /// The newly closed period.
  final WeeklyPeriod closedPeriod;

  const SettlementWeekClosed({required this.closedPeriod});

  @override
  List<Object?> get props => [closedPeriod];
}

/// Error state with a user-facing message.
class SettlementError extends SettlementState {
  /// The error message.
  final String message;

  const SettlementError({required this.message});

  @override
  List<Object?> get props => [message];
}