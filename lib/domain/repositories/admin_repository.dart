// Domain - Admin repository interface.
//
// Defines the contract for admin-specific operations including
// dashboard, user management, period closing, and points adjustments.

import '../../core/result/result.dart';
import '../entities/order.dart';
import '../entities/rider.dart';
import '../entities/shop.dart';
import '../entities/user.dart';
import '../entities/weekly_period.dart';

/// Dashboard statistics for the admin panel.
class AdminDashboard {
  /// Total registered users across all roles.
  final int totalUsers;

  /// Total registered customers.
  final int totalCustomers;

  /// Total registered shops.
  final int totalShops;

  /// Total registered riders.
  final int totalRiders;

  /// Total orders placed.
  final int totalOrders;

  /// Total completed orders.
  final int completedOrders;

  /// Total cancelled orders.
  final int cancelledOrders;

  /// Total platform revenue (admin commissions).
  final double totalRevenue;

  /// Total points issued.
  final int totalPointsIssued;

  /// Total points redeemed.
  final int totalPointsRedeemed;

  /// Current active period info.
  final WeeklyPeriod? currentPeriod;

  /// Creates an [AdminDashboard].
  const AdminDashboard({
    required this.totalUsers,
    required this.totalCustomers,
    required this.totalShops,
    required this.totalRiders,
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.totalRevenue,
    required this.totalPointsIssued,
    required this.totalPointsRedeemed,
    this.currentPeriod,
  });
}

/// Repository contract for admin-specific operations.
///
/// Handles the admin dashboard, user/shop/rider management,
/// weekly period closing, settlement oversight, and points adjustments.
abstract class AdminRepository {
  /// Fetches the admin dashboard with aggregated statistics.
  Future<Result<AdminDashboard>> getAdminDashboard();

  /// Fetches all users with optional role filter.
  ///
  /// - [role]: Optional role filter (e.g. 'customer', 'shop').
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<User>>> getUsers({
    String? role,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches all registered shops.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Shop>>> getShops({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new shop (with associated owner user) from the admin panel.
  ///
  /// Backend:
  ///   POST /api/admin/shops
  ///   Body contains both shop profile and owner user data.
  ///
  /// [payload] is a raw map so that the presentation layer can mirror the
  /// backend validation schema without coupling the domain to admin DTOs.
  Future<Result<Shop>> createShopAsAdmin({
    required Map<String, dynamic> payload,
  });

  /// Updates an existing shop (and optionally its owner user) from admin.
  ///
  /// Backend:
  ///   PUT /api/admin/shops/:shopId
  Future<Result<Shop>> updateShopAsAdmin({
    required String shopId,
    required Map<String, dynamic> payload,
  });

  /// Fetches all registered riders.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Rider>>> getRiders({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new rider (with associated user) from the admin panel.
  ///
  /// Backend:
  ///   POST /api/admin/riders
  ///   Body contains both rider profile and user account data.
  ///
  /// [payload] is a raw map mirroring the backend Joi schema to avoid coupling
  /// the domain layer to admin-specific DTOs.
  Future<Result<Rider>> createRiderAsAdmin({
    required Map<String, dynamic> payload,
  });

  /// Updates an existing rider (and optionally its user account) from admin.
  ///
  /// Backend:
  ///   PUT /api/admin/riders/:riderId
  Future<Result<Rider>> updateRiderAsAdmin({
    required String riderId,
    required Map<String, dynamic> payload,
  });

  /// Fetches all orders (admin view, all roles).
  ///
  /// - [status]: Optional status filter.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Order>>> getOrders({
    String? status,
    int page = 1,
    int perPage = 20,
  });

  /// Fetches weekly periods.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<WeeklyPeriod>>> getPeriods({
    int page = 1,
    int perPage = 20,
  });

  /// Closes the current active weekly period.
  ///
  /// Generates settlement records for all shops and riders,
  /// calculates commissions, and transitions the period status.
  Future<Result<WeeklyPeriod>> closeCurrentPeriod();

  /// Adjusts a customer's points balance (add or subtract).
  ///
  /// - [customerId]: The customer's unique identifier.
  /// - [points]: Points to add (positive) or subtract (negative).
  /// - [reason]: Reason for the adjustment.
  Future<Result<void>> adjustPoints({
    required String customerId,
    required int points,
    required String reason,
  });

  /// Toggles a user's active status (enable/disable).
  ///
  /// - [userId]: The user's unique identifier.
  /// - [isActive]: Whether the user should be active.
  Future<Result<User>> toggleUserStatus({
    required String userId,
    required bool isActive,
  });

  /// Resets a staff user's password (shop / rider / admin).
  ///
  /// - [userId]: The user's unique identifier.
  /// - [newPassword]: The new password that satisfies backend policy
  ///   (min 8 chars, 1 upper, 1 lower, 1 digit).
  ///
  /// Backend:
  ///   POST /api/admin/users/:userId/reset-password
  ///   Body: { "new_password": "..." }
  Future<Result<void>> resetUserPassword({
    required String userId,
    required String newPassword,
  });
}