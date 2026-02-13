// Data - Customer model with JSON serialization.
//
// Maps between the API JSON representation and the domain Customer entity.

import '../../domain/entities/customer.dart';

/// Data model for [Customer] with JSON serialization support.
class CustomerModel extends Customer {
  const CustomerModel({
    required super.id,
    required super.userId,
    required super.fullName,
    super.addressText,
    super.landmark,
    super.area,
    super.totalPoints,
    required super.referralCode,
    super.referredById,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [CustomerModel] from a JSON map.
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String,
      addressText: json['address_text'] as String?,
      landmark: json['landmark'] as String?,
      area: json['area'] as String?,
      totalPoints: json['total_points'] as int? ?? 0,
      referralCode: json['referral_code'] as String,
      referredById: json['referred_by_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Creates a [CustomerModel] from a domain [Customer] entity.
  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      userId: customer.userId,
      fullName: customer.fullName,
      addressText: customer.addressText,
      landmark: customer.landmark,
      area: customer.area,
      totalPoints: customer.totalPoints,
      referralCode: customer.referralCode,
      referredById: customer.referredById,
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'address_text': addressText,
      'landmark': landmark,
      'area': area,
      'total_points': totalPoints,
      'referral_code': referralCode,
      'referred_by_id': referredById,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}