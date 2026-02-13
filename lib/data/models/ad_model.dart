// Data - Ad model with JSON serialization.
//
// Maps between the API JSON representation and the domain Ad entity.

import '../../domain/entities/ad.dart';

/// Data model for [Ad] with JSON serialization support.
class AdModel extends Ad {
  const AdModel({
    required super.id,
    required super.shopId,
    required super.title,
    super.titleAr,
    super.description,
    super.imageUrl,
    super.dailyCost,
    required super.startDate,
    required super.endDate,
    super.isActive,
    super.totalCost,
    required super.createdAt,
  });

  /// Creates an [AdModel] from a JSON map.
  factory AdModel.fromJson(Map<String, dynamic> json) {
    return AdModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      title: json['title'] as String,
      titleAr: json['title_ar'] as String?,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      dailyCost: (json['daily_cost'] as num?)?.toDouble() ?? 10.0,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      totalCost: (json['total_cost'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Creates an [AdModel] from a domain [Ad] entity.
  factory AdModel.fromEntity(Ad ad) {
    return AdModel(
      id: ad.id,
      shopId: ad.shopId,
      title: ad.title,
      titleAr: ad.titleAr,
      description: ad.description,
      imageUrl: ad.imageUrl,
      dailyCost: ad.dailyCost,
      startDate: ad.startDate,
      endDate: ad.endDate,
      isActive: ad.isActive,
      totalCost: ad.totalCost,
      createdAt: ad.createdAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'title': title,
      'title_ar': titleAr,
      'description': description,
      'image_url': imageUrl,
      'daily_cost': dailyCost,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'is_active': isActive,
      'total_cost': totalCost,
      'created_at': createdAt.toIso8601String(),
    };
  }
}