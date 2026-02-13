// Domain - Use case for fetching rider dashboard.
//
// Retrieves dashboard statistics for the current rider.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/rider_repository.dart';

/// Fetches the rider's dashboard statistics.
///
/// Returns aggregated data including total deliveries, earnings,
/// cash handled, and available orders count.
@lazySingleton
class GetRiderDashboard extends UseCase<RiderDashboard, NoParams> {
  final RiderRepository _repository;

  /// Creates a [GetRiderDashboard] use case.
  GetRiderDashboard(this._repository);

  @override
  Future<Result<RiderDashboard>> call(NoParams params) {
    return _repository.getRiderDashboard();
  }
}