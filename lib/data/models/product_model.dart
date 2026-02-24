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
    // Support both `id` and `_id` for product identifier.
    final String id = (json['id'] ?? json['_id'])?.toString() ?? '';

    // shop_id may be null or non-string; always coerce safely.
    final String shopId = json['shop_id']?.toString() ?? '';

    final String name = json['name'] as String? ?? '';

    // Optional localized fields.
    final String? nameAr = json['name_ar'] as String?;
    final String? description = json['description'] as String?;

    // Price may be int or double, ensure non-null numeric.
    final double price = (json['price'] as num?)?.toDouble() ?? 0;

    final String? imageUrl = json['image_url'] as String?;

    final bool isAvailable = json['is_available'] as bool? ?? true;
    final int sortOrder = json['sort_order'] as int? ?? 0;

    // createdAt / updatedAt may be `created_at`/`updated_at` or camelCase, and may be absent.
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

    return ProductModel(
      id: id,
      shopId: shopId,
      name: name,
      nameAr: nameAr,
      description: description,
      price: price,
      imageUrl: imageUrl,
      isAvailable: isAvailable,
      sortOrder: sortOrder,
      createdAt: createdAt,
      updatedAt: updatedAt,
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