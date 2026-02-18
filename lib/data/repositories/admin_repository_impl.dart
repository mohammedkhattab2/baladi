// Data - Admin repository implementation.
//
// Implements the AdminRepository contract using remote datasource.
// Handles admin dashboard, user management, period closing,
// and points adjustments.

import 'package:injectable/injectable.dart' hide Order;

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/rider.dart';
import '../../domain/entities/shop.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/weekly_period.dart';
import '../../domain/repositories/admin_repository.dart';
import '../datasources/remote/admin_remote_datasource.dart';
import '../models/weekly_period_model.dart';

/// Implementation of [AdminRepository].
@LazySingleton(as: AdminRepository)
class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  /// Creates an [AdminRepositoryImpl].
  AdminRepositoryImpl({
    required AdminRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<AdminDashboard>> getAdminDashboard() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final json = await _remoteDatasource.getAdminDashboard();

      // Backend "data" payload shape:
      // {
      //   "overview": { ... },
      //   "orders": { ... },
      //   "current_period": { ... },
      //   "revenue": { ... }
      // }
      final overview =
          (json['overview'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final orders =
          (json['orders'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final revenue =
          (json['revenue'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      final byStatus =
          (orders['by_status'] as Map<String, dynamic>?) ?? <String, dynamic>{};

      WeeklyPeriod? currentPeriod;
      if (json['current_period'] != null &&
          json['current_period'] is Map<String, dynamic>) {
        try {
          currentPeriod = WeeklyPeriodModel.fromJson(
            json['current_period'] as Map<String, dynamic>,
          );
        } catch (_) {
          currentPeriod = null;
        }
      }

      final totalPointsRedeemed =
          revenue['total_points_redeemed'] as int? ?? 0;

      final dashboard = AdminDashboard(
        totalUsers: overview['total_users'] as int? ?? 0,
        totalCustomers: overview['total_customers'] as int? ?? 0,
        totalShops: overview['total_shops'] as int? ?? 0,
        totalRiders: overview['total_riders'] as int? ?? 0,
        // Use period_orders as the main orders count for the current period
        totalOrders: revenue['period_orders'] as int? ?? 0,
        // Pull completed / cancelled from orders.by_status when available
        completedOrders: byStatus['completed'] as int? ?? 0,
        cancelledOrders: byStatus['cancelled'] as int? ?? 0,
        // Platform revenue = admin_net_commission from the revenue block
        totalRevenue:
            (revenue['admin_net_commission'] as num?)?.toDouble() ?? 0,
        // Backend currently only exposes redeemed points; use them for both
        // issued and redeemed so that active points don't go negative.
        totalPointsIssued: totalPointsRedeemed,
        totalPointsRedeemed: totalPointsRedeemed,
        currentPeriod: currentPeriod,
      );

      // Debug log to verify mapping in development
      // ignore: avoid_print
      print(
        'AdminDashboard mapped: users=${dashboard.totalUsers}, '
        'customers=${dashboard.totalCustomers}, shops=${dashboard.totalShops}, '
        'riders=${dashboard.totalRiders}, orders=${dashboard.totalOrders}, '
        'revenue=${dashboard.totalRevenue}',
      );

      return dashboard;
    });
  }

  @override
  Future<Result<List<User>>> getUsers({
    String? role,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getUsers(
        role: role,
        page: page,
        perPage: perPage,
      ),
    );
  }

  @override
  Future<Result<List<Shop>>> getShops({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getShops(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<List<Rider>>> getRiders({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getRiders(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<List<Order>>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getOrders(
        status: status,
        page: page,
        perPage: perPage,
      ),
    );
  }

  @override
  Future<Result<List<WeeklyPeriod>>> getPeriods({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getPeriods(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<WeeklyPeriod>> closeCurrentPeriod() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.closeCurrentPeriod());
  }

  @override
  Future<Result<void>> adjustPoints({
    required String customerId,
    required int points,
    required String reason,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.adjustPoints(
          customerId: customerId,
          points: points,
          reason: reason,
        ));
  }

  @override
  Future<Result<User>> toggleUserStatus({
    required String userId,
    required bool isActive,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.toggleUserStatus(
        userId: userId,
        isActive: isActive,
      ),
    );
  }
}