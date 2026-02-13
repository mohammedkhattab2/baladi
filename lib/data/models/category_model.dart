// Data - Category model with JSON serialization.
//
// Maps between the API JSON representation and the domain Category entity.

import '../../domain/entities/category.dart';

/// Data model for [Category] with JSON serialization support.
class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.nameAr,
    required super.slug,
    super.icon,
    super.color,
    super.sortOrder,
    super.isActive,
  });

  /// Creates a [CategoryModel] from a JSON map.
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      nameAr: json['name_ar'] as String,
      slug: json['slug'] as String,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      sortOrder: json['sort_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  /// Creates a [CategoryModel] from a domain [Category] entity.
  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      nameAr: category.nameAr,
      slug: category.slug,
      icon: category.icon,
      color: category.color,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_ar': nameAr,
      'slug': slug,
      'icon': icon,
      'color': color,
      'sort_order': sortOrder,
      'is_active': isActive,
    };
  }
}