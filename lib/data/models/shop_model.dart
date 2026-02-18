// Data - Shop model with JSON serialization.
//
// Maps between the API JSON representation and the domain Shop entity.

import '../../domain/entities/shop.dart';

/// Data model for [Shop] with JSON serialization support.
class ShopModel extends Shop {
  const ShopModel({
    required super.id,
    required super.userId,
    required super.name,
    super.nameAr,
    required super.categoryId,
    super.description,
    super.phone,
    super.address,
    super.commissionRate,
    super.minOrderAmount,
    super.isOpen,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [ShopModel] from a JSON map.
  factory ShopModel.fromJson(Map<String, dynamic> json) {
    // Support both flat and nested shapes used by the backend.
    //
    // ID: "id" or "_id"
    final String id = (json['id'] ?? json['_id'])?.toString() ?? '';

    // user_id: can be a String or an embedded user object.
    final dynamic rawUser = json['user_id'];
    String userId;
    if (rawUser is String) {
      userId = rawUser;
    } else if (rawUser is Map<String, dynamic>) {
      userId = (rawUser['id'] ?? rawUser['_id'])?.toString() ?? '';
    } else {
      userId = '';
    }

    // category_id: can be a String or an embedded category object.
    final dynamic rawCategory = json['category_id'];
    String categoryId;
    if (rawCategory is String) {
      categoryId = rawCategory;
    } else if (rawCategory is Map<String, dynamic>) {
      categoryId = (rawCategory['id'] ?? rawCategory['_id'])?.toString() ?? '';
    } else {
      categoryId = '';
    }

    // createdAt / updatedAt: support both snake_case and camelCase.
    final String? createdAtRaw =
        (json['created_at'] ?? json['createdAt']) as String?;
    final String? updatedAtRaw =
        (json['updated_at'] ?? json['updatedAt']) as String?;

    final DateTime createdAt = createdAtRaw != null
        ? DateTime.parse(createdAtRaw)
        : DateTime.now();
    final DateTime updatedAt = updatedAtRaw != null
        ? DateTime.parse(updatedAtRaw)
        : createdAt;

    return ShopModel(
      id: id,
      userId: userId,
      name: json['name'] as String? ?? '',
      nameAr: json['name_ar'] as String?,
      categoryId: categoryId,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0.10,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      isOpen: json['is_open'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [ShopModel] from a domain [Shop] entity.
  factory ShopModel.fromEntity(Shop shop) {
    return ShopModel(
      id: shop.id,
      userId: shop.userId,
      name: shop.name,
      nameAr: shop.nameAr,
      categoryId: shop.categoryId,
      description: shop.description,
      phone: shop.phone,
      address: shop.address,
      commissionRate: shop.commissionRate,
      minOrderAmount: shop.minOrderAmount,
      isOpen: shop.isOpen,
      isActive: shop.isActive,
      createdAt: shop.createdAt,
      updatedAt: shop.updatedAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'name_ar': nameAr,
      'category_id': categoryId,
      'description': description,
      'phone': phone,
      'address': address,
      'commission_rate': commissionRate,
      'min_order_amount': minOrderAmount,
      'is_open': isOpen,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}