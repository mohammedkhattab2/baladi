// Domain - Shop entity.
//
// Represents a shop/store that sells products and receives orders.

import 'package:equatable/equatable.dart';

/// Shop entity linked to a [User] with role `shop`.
///
/// Holds shop profile, category, commission rate, and operational status.
class Shop extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// Associated user account ID.
  final String userId;

  /// Shop name in English.
  final String name;

  /// Shop name in Arabic.
  final String? nameAr;

  /// Category ID this shop belongs to.
  final String categoryId;

  /// Shop description.
  final String? description;

  /// Contact phone number.
  final String? phone;

  /// Shop address text.
  final String? address;

  /// Commission rate charged by the platform (e.g. 0.10 = 10%).
  final double commissionRate;

  /// Minimum order amount to place an order (0 = no minimum).
  final double minOrderAmount;

  /// Whether the shop is currently open for orders.
  final bool isOpen;

  /// Whether the shop account is active (admin-controlled).
  final bool isActive;

  /// Account creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const Shop({
    required this.id,
    required this.userId,
    required this.name,
    this.nameAr,
    required this.categoryId,
    this.description,
    this.phone,
    this.address,
    this.commissionRate = 0.10,
    this.minOrderAmount = 0,
    this.isOpen = true,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the display name — Arabic if available, otherwise English.
  String get displayName => nameAr ?? name;

  /// Returns `true` if the shop can receive new orders.
  bool get canReceiveOrders => isOpen && isActive;

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        nameAr,
        categoryId,
        description,
        phone,
        address,
        commissionRate,
        minOrderAmount,
        isOpen,
        isActive,
        createdAt,
        updatedAt,
      ];
}