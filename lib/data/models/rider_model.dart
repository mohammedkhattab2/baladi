// Data - Rider model with JSON serialization.
//
// Maps between the API JSON representation and the domain Rider entity.

import '../../domain/entities/rider.dart';

/// Data model for [Rider] with JSON serialization support.
class RiderModel extends Rider {
  const RiderModel({
    required super.id,
    required super.userId,
    required super.fullName,
    required super.phone,
    super.deliveryFee,
    super.isAvailable,
    super.isActive,
    super.totalDeliveries,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [RiderModel] from a JSON map.
  factory RiderModel.fromJson(Map<String, dynamic> json) {
    return RiderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      phone: json['phone'] as String,
      deliveryFee: (json['delivery_fee'] as num?)?.toDouble() ?? 10.0,
      isAvailable: json['is_available'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      totalDeliveries: json['total_deliveries'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Creates a [RiderModel] from a domain [Rider] entity.
  factory RiderModel.fromEntity(Rider rider) {
    return RiderModel(
      id: rider.id,
      userId: rider.userId,
      fullName: rider.fullName,
      phone: rider.phone,
      deliveryFee: rider.deliveryFee,
      isAvailable: rider.isAvailable,
      isActive: rider.isActive,
      totalDeliveries: rider.totalDeliveries,
      createdAt: rider.createdAt,
      updatedAt: rider.updatedAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'phone': phone,
      'delivery_fee': deliveryFee,
      'is_available': isAvailable,
      'is_active': isActive,
      'total_deliveries': totalDeliveries,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}