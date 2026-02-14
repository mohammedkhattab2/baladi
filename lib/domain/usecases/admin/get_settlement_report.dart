// Domain - Use case for fetching a full settlement report for a period.
//
// Aggregates shop settlements, rider settlements, and admin summary
// for a given weekly period. Used by the admin settlement screen.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/rider_settlement.dart';
import '../../entities/shop_settlement.dart';
import '../../entities/weekly_period.dart';
import '../../repositories/settlement_repository.dart';

/// Parameters for fetching a settlement report.
class GetSettlementReportParams extends Equatable {
  /// The weekly period ID to generate the report for.
  final String periodId;

  /// Creates [GetSettlementReportParams].
  const GetSettlementReportParams({required this.periodId});

  @override
  List<Object?> get props => [periodId];
}

/// Aggregated settlement report for a weekly period.
class SettlementReport extends Equatable {
  /// The weekly period this report covers.
  final WeeklyPeriod period;

  /// All shop settlements in this period.
  final List<ShopSettlement> shopSettlements;

  /// All rider settlements in this period.
  final List<RiderSettlement> riderSettlements;

  /// Total gross sales across all shops.
  final double totalGrossSales;

  /// Total commissions collected.
  final double totalCommissions;

  /// Total delivery fees collected.
  final double totalDeliveryFees;

  /// Total points discount absorbed by the platform.
  final double totalPointsDiscounts;

  /// Total free delivery costs absorbed by the platform.
  final double totalFreeDeliveryCosts;

  /// Total ads revenue.
  final double totalAdsRevenue;

  /// Admin net revenue after all deductions.
  final double adminNetRevenue;

  /// Creates a [SettlementReport].
  const SettlementReport({
    required this.period,
    required this.shopSettlements,
    required this.riderSettlements,
    required this.totalGrossSales,
    required this.totalCommissions,
    required this.totalDeliveryFees,
    required this.totalPointsDiscounts,
    required this.totalFreeDeliveryCosts,
    required this.totalAdsRevenue,
    required this.adminNetRevenue,
  });

  @override
  List<Object?> get props => [
        period,
        shopSettlements,
        riderSettlements,
        totalGrossSales,
        totalCommissions,
        totalDeliveryFees,
        totalPointsDiscounts,
        totalFreeDeliveryCosts,
        totalAdsRevenue,
        adminNetRevenue,
      ];
}

/// Fetches a full settlement report for a weekly period.
///
/// Aggregates shop and rider settlements along with summary totals
/// for admin review and approval.
@lazySingleton
class GetSettlementReport
    extends UseCase<SettlementReport, GetSettlementReportParams> {
  final SettlementRepository _repository;

  /// Creates a [GetSettlementReport] use case.
  GetSettlementReport(this._repository);

  @override
  Future<Result<SettlementReport>> call(
    GetSettlementReportParams params,
  ) async {
    // Fetch shop settlements for the period
    final shopResult = await _repository.getShopSettlements(
      periodId: params.periodId,
      perPage: 100, // Get all in one page for report
    );

    if (shopResult.isFailure) {
      return ResultFailure(shopResult.failure!);
    }

    // Fetch rider settlements for the period
    final riderResult = await _repository.getRiderSettlements(
      periodId: params.periodId,
      perPage: 100,
    );

    if (riderResult.isFailure) {
      return ResultFailure(riderResult.failure!);
    }

    // Fetch the period details
    final periodsResult = await _repository.getWeeklyPeriods(perPage: 100);
    if (periodsResult.isFailure) {
      return ResultFailure(periodsResult.failure!);
    }

    final period = periodsResult.data!.firstWhere(
      (p) => p.id == params.periodId,
      orElse: () => periodsResult.data!.first,
    );

    final shops = shopResult.data!;
    final riders = riderResult.data!;

    // Calculate aggregated totals
    final totalGrossSales =
        shops.fold<double>(0, (sum, s) => sum + s.grossSales);
    final totalCommissions =
        shops.fold<double>(0, (sum, s) => sum + s.totalCommission);
    final totalPointsDiscounts =
        shops.fold<double>(0, (sum, s) => sum + s.pointsDiscounts);
    final totalFreeDeliveryCosts =
        shops.fold<double>(0, (sum, s) => sum + s.freeDeliveryCost);
    final totalAdsRevenue =
        shops.fold<double>(0, (sum, s) => sum + s.adsCost);
    final totalDeliveryFees =
        riders.fold<double>(0, (sum, r) => sum + r.totalEarnings);
    final adminNetRevenue =
        totalCommissions - totalPointsDiscounts - totalFreeDeliveryCosts;

    return Success(SettlementReport(
      period: period,
      shopSettlements: shops,
      riderSettlements: riders,
      totalGrossSales: totalGrossSales,
      totalCommissions: totalCommissions,
      totalDeliveryFees: totalDeliveryFees,
      totalPointsDiscounts: totalPointsDiscounts,
      totalFreeDeliveryCosts: totalFreeDeliveryCosts,
      totalAdsRevenue: totalAdsRevenue,
      adminNetRevenue: adminNetRevenue,
    ));
  }
}