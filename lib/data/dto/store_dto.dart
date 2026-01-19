/// Store Data Transfer Object for API/database serialization.
///
/// Maps between JSON data and the Store domain entity.
library;

import '../../domain/entities/store.dart';

/// DTO for Store entity serialization.
class StoreDto {
  final String id;
  final String userId;
  final String name;
  final String? nameAr;
  final String categoryId;
  final String? description;
  final String? phone;
  final String? address;
  final String? logoUrl;
  final String? coverImageUrl;
  final double commissionRate;
  final double minOrderAmount;
  final bool isOpen;
  final bool isActive;
  final bool isApproved;
  final double rating;
  final int totalOrders;
  final String createdAt;
  final String? updatedAt;

  const StoreDto({
    required this.id,
    required this.userId,
    required this.name,
    this.nameAr,
    required this.categoryId,
    this.description,
    this.phone,
    this.address,
    this.logoUrl,
    this.coverImageUrl,
    this.commissionRate = 0.10,
    this.minOrderAmount = 0,
    this.isOpen = true,
    this.isActive = true,
    this.isApproved = false,
    this.rating = 0,
    this.totalOrders = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a StoreDto from JSON map.
  factory StoreDto.fromJson(Map<String, dynamic> json) {
    return StoreDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      categoryId: json['category_id'] as String,
      description: json['description'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      logoUrl: json['logo_url'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      commissionRate: (json['commission_rate'] as num?)?.toDouble() ?? 0.10,
      minOrderAmount: (json['min_order_amount'] as num?)?.toDouble() ?? 0,
      isOpen: json['is_open'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      isApproved: json['is_approved'] as bool? ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      totalOrders: json['total_orders'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Converts this DTO to a JSON map.
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
      'logo_url': logoUrl,
      'cover_image_url': coverImageUrl,
      'commission_rate': commissionRate,
      'min_order_amount': minOrderAmount,
      'is_open': isOpen,
      'is_active': isActive,
      'is_approved': isApproved,
      'rating': rating,
      'total_orders': totalOrders,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Converts this DTO to a JSON map for insert (without id).
  Map<String, dynamic> toInsertJson() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Convert to domain entity.
  Store toEntity() {
    return Store(
      id: id,
      userId: userId,
      name: name,
      nameAr: nameAr,
      categoryId: categoryId,
      description: description,
      phone: phone,
      address: address,
      logoUrl: logoUrl,
      coverImageUrl: coverImageUrl,
      commissionRate: commissionRate,
      minOrderAmount: minOrderAmount,
      isOpen: isOpen,
      isActive: isActive,
      isApproved: isApproved,
      rating: rating,
      totalOrders: totalOrders,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Create DTO from domain entity.
  factory StoreDto.fromEntity(Store entity) {
    return StoreDto(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      nameAr: entity.nameAr,
      categoryId: entity.categoryId,
      description: entity.description,
      phone: entity.phone,
      address: entity.address,
      logoUrl: entity.logoUrl,
      coverImageUrl: entity.coverImageUrl,
      commissionRate: entity.commissionRate,
      minOrderAmount: entity.minOrderAmount,
      isOpen: entity.isOpen,
      isActive: entity.isActive,
      isApproved: entity.isApproved,
      rating: entity.rating,
      totalOrders: entity.totalOrders,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'StoreDto(id: $id, name: $name)';
}