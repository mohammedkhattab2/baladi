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

      WeeklyPeriod? currentPeriod;
      if (json['current_period'] != null) {
        currentPeriod = WeeklyPeriodModel.fromJson(
          json['current_period'] as Map<String, dynamic>,
        );
      }

      return AdminDashboard(
        totalUsers: json['total_users'] as int? ?? 0,
        totalCustomers: json['total_customers'] as int? ?? 0,
        totalShops: json['total_shops'] as int? ?? 0,
        totalRiders: json['total_riders'] as int? ?? 0,
        totalOrders: json['total_orders'] as int? ?? 0,
        completedOrders: json['completed_orders'] as int? ?? 0,
        cancelledOrders: json['cancelled_orders'] as int? ?? 0,
        totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
        totalPointsIssued: json['total_points_issued'] as int? ?? 0,
        totalPointsRedeemed: json['total_points_redeemed'] as int? ?? 0,
        currentPeriod: currentPeriod,
      );
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