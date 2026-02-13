// Domain - Use case for fetching shop dashboard.
//
// Retrieves dashboard statistics for the current shop owner.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/shop_repository.dart';

/// Fetches the shop owner's dashboard statistics.
///
/// Returns aggregated data including total orders, revenue,
/// commissions, and net earnings for the current period.
@lazySingleton
class GetShopDashboard extends UseCase<ShopDashboard, NoParams> {
  final ShopRepository _repository;

  /// Creates a [GetShopDashboard] use case.
  GetShopDashboard(this._repository);

  @override
  Future<Result<ShopDashboard>> call(NoParams params) {
    return _repository.getShopDashboard();
  }
}