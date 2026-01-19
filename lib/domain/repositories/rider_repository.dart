/// Repository interface for rider operations.
/// 
/// This defines the contract for rider-related data access.
/// Includes rider management, assignments, and earnings tracking.
/// 
/// Architecture note: Repository interfaces are part of the domain layer
/// and have no knowledge of data sources (API, database, etc.).
library;
import '../../core/result/result.dart';
import '../entities/user.dart';
import '../enums/order_status.dart';

/// Rider repository interface.
abstract class RiderRepository {
  /// Get rider by ID.
  Future<Result<User>> getRiderById(String riderId);

  /// Get all active riders.
  Future<Result<List<User>>> getActiveRiders({
    bool availableOnly = false,
    int page = 1,
    int pageSize = 20,
  });

  /// Get available riders for order assignment.
  Future<Result<List<User>>> getAvailableRiders();

  /// Update rider availability status.
  Future<Result<User>> updateRiderAvailability({
    required String riderId,
    required bool isAvailable,
  });

  /// Update rider location (for future map integration).
  Future<Result<void>> updateRiderLocation({
    required String riderId,
    required double latitude,
    required double longitude,
  });

  /// Get rider statistics.
  Future<Result<RiderStatistics>> getRiderStatistics({
    required String riderId,
    DateTime? fromDate,
    DateTime? toDate,
  });

  /// Get rider earnings for period.
  Future<Result<RiderEarnings>> getRiderEarnings({
    required String riderId,
    required DateTime fromDate,
    required DateTime toDate,
  });

  /// Get rider's current active order.
  Future<Result<String?>> getRiderActiveOrderId(String riderId);

  /// Get rider delivery history.
  Future<Result<List<RiderDeliveryRecord>>> getRiderDeliveries({
    required String riderId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  });

  /// Watch rider status updates.
  Stream<User> watchRider(String riderId);

  /// Watch available riders.
  Stream<List<User>> watchAvailableRiders();
}

/// Rider statistics.
class RiderStatistics {
  final String riderId;
  final int totalDeliveries;
  final int completedDeliveries;
  final int cancelledDeliveries;
  final double totalEarnings;
  final double averageDeliveryTime;
  final double averageRating;
  final int totalRatings;
  final DateTime periodStart;
  final DateTime periodEnd;

  const RiderStatistics({
    required this.riderId,
    required this.totalDeliveries,
    required this.completedDeliveries,
    required this.cancelledDeliveries,
    required this.totalEarnings,
    required this.averageDeliveryTime,
    required this.averageRating,
    required this.totalRatings,
    required this.periodStart,
    required this.periodEnd,
  });

  /// Completion rate.
  double get completionRate {
    if (totalDeliveries == 0) return 0;
    return completedDeliveries / totalDeliveries;
  }
}

/// Rider earnings summary.
class RiderEarnings {
  final String riderId;
  final int deliveryCount;
  final double totalDeliveryFees;
  final double tips;
  final double bonuses;
  final double deductions;
  final double netEarnings;
  final DateTime periodStart;
  final DateTime periodEnd;

  const RiderEarnings({
    required this.riderId,
    required this.deliveryCount,
    required this.totalDeliveryFees,
    required this.tips,
    required this.bonuses,
    required this.deductions,
    required this.netEarnings,
    required this.periodStart,
    required this.periodEnd,
  });
}

/// Rider delivery record.
class RiderDeliveryRecord {
  final String orderId;
  final String orderNumber;
  final String storeName;
  final String customerName;
  final String deliveryAddress;
  final OrderStatus status;
  final double deliveryFee;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;
  final int? deliveryTimeMinutes;

  const RiderDeliveryRecord({
    required this.orderId,
    required this.orderNumber,
    required this.storeName,
    required this.customerName,
    required this.deliveryAddress,
    required this.status,
    required this.deliveryFee,
    this.pickedUpAt,
    this.deliveredAt,
    this.deliveryTimeMinutes,
  });
}