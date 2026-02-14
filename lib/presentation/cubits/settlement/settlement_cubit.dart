// Presentation - Settlement cubit.
//
// Manages settlement-related state including weekly period listing,
// settlement report loading, period closing, and detail viewing.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/usecase/usecase.dart';
import '../../../domain/repositories/settlement_repository.dart';
import '../../../domain/usecases/admin/close_week.dart';
import '../../../domain/usecases/admin/get_settlement_report.dart';
import '../../../domain/usecases/admin/settle_period.dart';
import 'settlement_state.dart';

/// Cubit that manages the settlement screens.
///
/// Used by admin for viewing weekly periods, generating settlement
/// reports, closing weeks, and viewing individual settlement details.
/// Also used by shop/rider views to see their own settlements.
@injectable
class SettlementCubit extends Cubit<SettlementState> {
  final SettlementRepository _settlementRepository;
  final GetSettlementReport _getSettlementReport;
  final GetShopSettlementDetail _getShopSettlementDetail;
  final CloseWeek _closeWeek;

  /// Creates a [SettlementCubit].
  SettlementCubit({
    required SettlementRepository settlementRepository,
    required GetSettlementReport getSettlementReport,
    required GetShopSettlementDetail getShopSettlementDetail,
    required CloseWeek closeWeek,
  })  : _settlementRepository = settlementRepository,
        _getSettlementReport = getSettlementReport,
        _getShopSettlementDetail = getShopSettlementDetail,
        _closeWeek = closeWeek,
        super(const SettlementInitial());

  /// Loads all weekly periods.
  Future<void> loadPeriods() async {
    emit(const SettlementLoading());

    final result = await _settlementRepository.getWeeklyPeriods();

    result.fold(
      onSuccess: (periods) {
        final currentPeriod = periods.where((p) => p.isActive).firstOrNull;
        emit(SettlementPeriodsLoaded(
          periods: periods,
          currentPeriod: currentPeriod,
        ));
      },
      onFailure: (failure) {
        emit(SettlementError(message: failure.message));
      },
    );
  }

  /// Loads a full settlement report for a specific period.
  Future<void> loadReport(String periodId) async {
    emit(const SettlementLoading());

    final result = await _getSettlementReport(
      GetSettlementReportParams(periodId: periodId),
    );

    result.fold(
      onSuccess: (report) {
        emit(SettlementReportLoaded(report: report));
      },
      onFailure: (failure) {
        emit(SettlementError(message: failure.message));
      },
    );
  }

  /// Loads a single shop settlement detail.
  Future<void> loadShopSettlementDetail(String settlementId) async {
    emit(const SettlementLoading());

    final result = await _getShopSettlementDetail(
      GetShopSettlementDetailParams(settlementId: settlementId),
    );

    result.fold(
      onSuccess: (settlement) {
        emit(ShopSettlementDetailLoaded(settlement: settlement));
      },
      onFailure: (failure) {
        emit(SettlementError(message: failure.message));
      },
    );
  }

  /// Loads a single rider settlement detail.
  Future<void> loadRiderSettlementDetail(String settlementId) async {
    emit(const SettlementLoading());

    final result =
        await _settlementRepository.getRiderSettlementById(settlementId);

    result.fold(
      onSuccess: (settlement) {
        emit(RiderSettlementDetailLoaded(settlement: settlement));
      },
      onFailure: (failure) {
        emit(SettlementError(message: failure.message));
      },
    );
  }

  /// Closes the current active weekly period (admin action).
  ///
  /// Generates settlement records for all shops and riders,
  /// then transitions the period to "closed" status.
  Future<void> closeCurrentWeek() async {
    emit(const SettlementLoading());

    final result = await _closeWeek(const NoParams());

    result.fold(
      onSuccess: (closedPeriod) {
        emit(SettlementWeekClosed(closedPeriod: closedPeriod));
      },
      onFailure: (failure) {
        emit(SettlementError(message: failure.message));
      },
    );
  }

  /// Resets to initial state.
  void reset() {
    emit(const SettlementInitial());
  }
}