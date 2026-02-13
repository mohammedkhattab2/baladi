// Data - Product model with JSON serialization.
//
// Maps between the API JSON representation and the domain Product entity.

import '../../domain/entities/product.dart';

/// Data model for [Product] with JSON serialization support.
class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.shopId,
    required super.name,
    super.nameAr,
    super.description,
    required super.price,
    super.imageUrl,
    super.isAvailable,
    super.sortOrder,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [ProductModel] from a JSON map.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      shopId: json['shop_id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Creates a [ProductModel] from a domain [Product] entity.
  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      shopId: product.shopId,
      name: product.name,
      nameAr: product.nameAr,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      isAvailable: product.isAvailable,
      sortOrder: product.sortOrder,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_id': shopId,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'price': price,
      'image_url': imageUrl,
      'is_available': isAvailable,
      'sort_order': sortOrder,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}