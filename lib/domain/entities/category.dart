// Domain - Category entity.
//
// Represents a shop category (e.g. Restaurants, Bakeries, Pharmacies).

import 'package:equatable/equatable.dart';

/// A category that groups shops by type.
///
/// Categories are predefined in the backend and displayed on the
/// customer home screen as navigable tiles.
class Category extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// English name.
  final String name;

  /// Arabic name for display.
  final String nameAr;

  /// URL-friendly slug used for routing (e.g. `restaurants`).
  final String slug;

  /// Icon identifier (mapped to Flutter icons in the UI layer).
  final String? icon;

  /// Hex color code for the category tile (e.g. `#FF6B35`).
  final String? color;

  /// Display order (lower = shown first).
  final int sortOrder;

  /// Whether this category is visible to customers.
  final bool isActive;

  const Category({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.slug,
    this.icon,
    this.color,
    this.sortOrder = 0,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        nameAr,
        slug,
        icon,
        color,
        sortOrder,
        isActive,
      ];
}