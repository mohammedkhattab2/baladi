/// Product Data Transfer Object for API/database serialization.
///
/// Maps between JSON data and the Product domain entity.
library;

import '../../domain/entities/product.dart';

/// DTO for Product entity serialization.
class ProductDto {
  final String id;
  final String storeId;
  final String name;
  final String? nameAr;
  final String? description;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  final String? category;
  final bool isAvailable;
  final int sortOrder;
  final String createdAt;
  final String? updatedAt;

  const ProductDto({
    required this.id,
    required this.storeId,
    required this.name,
    this.nameAr,
    this.description,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    this.category,
    this.isAvailable = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a ProductDto from JSON map.
  factory ProductDto.fromJson(Map<String, dynamic> json) {
    return ProductDto(
      id: json['id'] as String,
      storeId: json['store_id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num).toDouble(),
      discountPrice: (json['discount_price'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      sortOrder: json['sort_order'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Converts this DTO to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'store_id': storeId,
      'name': name,
      'name_ar': nameAr,
      'description': description,
      'price': price,
      'discount_price': discountPrice,
      'image_url': imageUrl,
      'category': category,
      'is_available': isAvailable,
      'sort_order': sortOrder,
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
  Product toEntity() {
    return Product(
      id: id,
      storeId: storeId,
      name: name,
      nameAr: nameAr,
      description: description,
      price: price,
      discountPrice: discountPrice,
      imageUrl: imageUrl,
      category: category,
      isAvailable: isAvailable,
      sortOrder: sortOrder,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
    );
  }

  /// Create DTO from domain entity.
  factory ProductDto.fromEntity(Product entity) {
    return ProductDto(
      id: entity.id,
      storeId: entity.storeId,
      name: entity.name,
      nameAr: entity.nameAr,
      description: entity.description,
      price: entity.price,
      discountPrice: entity.discountPrice,
      imageUrl: entity.imageUrl,
      category: entity.category,
      isAvailable: entity.isAvailable,
      sortOrder: entity.sortOrder,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt?.toIso8601String(),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductDto && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ProductDto(id: $id, name: $name, price: $price)';
}