// Domain - Rider entity.
//
// Represents a delivery rider who picks up and delivers orders.

import 'package:equatable/equatable.dart';

/// Rider entity linked to a [User] with role `rider`.
///
/// Holds rider profile, availability status, and delivery statistics.
class Rider extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// Associated user account ID.
  final String userId;

  /// Rider's full name.
  final String fullName;

  /// Rider's contact phone number.
  final String phone;

  /// Delivery fee earned per order.
  final double deliveryFee;

  /// Whether the rider is currently available for deliveries.
  final bool isAvailable;

  /// Whether the rider account is active (admin-controlled).
  final bool isActive;

  /// Total number of completed deliveries.
  final int totalDeliveries;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const Rider({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phone,
    this.deliveryFee = 10.0,
    this.isAvailable = false,
    this.isActive = true,
    this.totalDeliveries = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns `true` if the rider can accept new deliveries.
  bool get canAcceptDeliveries => isAvailable && isActive;

  @override
  List<Object?> get props => [
        id,
        userId,
        fullName,
        phone,
        deliveryFee,
        isAvailable,
        isActive,
        totalDeliveries,
        createdAt,
        updatedAt,
      ];
}