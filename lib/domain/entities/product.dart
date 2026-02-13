// Domain - Product entity.
//
// Represents a product sold by a shop.

import 'package:equatable/equatable.dart';

/// A product available for ordering from a shop.
///
/// Products belong to a single [Shop] and can be toggled
/// available/unavailable by the shop owner.
class Product extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The shop this product belongs to.
  final String shopId;

  /// Product name in English.
  final String name;

  /// Product name in Arabic.
  final String? nameAr;

  /// Product description.
  final String? description;

  /// Price in EGP.
  final double price;

  /// URL to the product image.
  final String? imageUrl;

  /// Whether this product is currently available for ordering.
  final bool isAvailable;

  /// Display order within the shop (lower = shown first).
  final int sortOrder;

  /// Creation timestamp.
  final DateTime createdAt;

  /// Last update timestamp.
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.shopId,
    required this.name,
    this.nameAr,
    this.description,
    required this.price,
    this.imageUrl,
    this.isAvailable = true,
    this.sortOrder = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the display name — Arabic if available, otherwise English.
  String get displayName => nameAr ?? name;

  /// Returns `true` if this product has an image.
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
        id,
        shopId,
        name,
        nameAr,
        description,
        price,
        imageUrl,
        isAvailable,
        sortOrder,
        createdAt,
        updatedAt,
      ];
}