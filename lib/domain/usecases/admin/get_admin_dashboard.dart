// Domain - Use case for fetching admin dashboard.
//
// Retrieves aggregated statistics for the admin panel.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/admin_repository.dart';

/// Fetches the admin dashboard with aggregated statistics.
///
/// Returns data including total users, orders, revenue,
/// points issued/redeemed, and current period info.
@lazySingleton
class GetAdminDashboard extends UseCase<AdminDashboard, NoParams> {
  final AdminRepository _repository;

  /// Creates a [GetAdminDashboard] use case.
  GetAdminDashboard(this._repository);

  @override
  Future<Result<AdminDashboard>> call(NoParams params) {
    return _repository.getAdminDashboard();
  }
}