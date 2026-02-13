// Presentation - Categories cubit states.
//
// Defines all possible states for the categories listing feature
// including loading, loaded with shops, and error states.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/category.dart';
import '../../../domain/entities/shop.dart';

/// Base state for the categories cubit.
abstract class CategoriesState extends Equatable {
  const CategoriesState();

  @override
  List<Object?> get props => [];
}

/// Initial state — categories not yet loaded.
class CategoriesInitial extends CategoriesState {
  const CategoriesInitial();
}

/// Categories are being fetched.
class CategoriesLoading extends CategoriesState {
  const CategoriesLoading();
}

/// Categories loaded successfully.
class CategoriesLoaded extends CategoriesState {
  /// All available categories.
  final List<Category> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object?> get props => [categories];
}

/// An error occurred while loading categories.
class CategoriesError extends CategoriesState {
  /// The error message to display.
  final String message;

  const CategoriesError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Shops for a selected category are being fetched.
class CategoryShopsLoading extends CategoriesState {
  /// The currently loaded categories.
  final List<Category> categories;

  /// The selected category slug.
  final String categorySlug;

  const CategoryShopsLoading({
    required this.categories,
    required this.categorySlug,
  });

  @override
  List<Object?> get props => [categories, categorySlug];
}

/// Shops for a selected category loaded successfully.
class CategoryShopsLoaded extends CategoriesState {
  /// The currently loaded categories.
  final List<Category> categories;

  /// The selected category slug.
  final String categorySlug;

  /// Shops belonging to the selected category.
  final List<Shop> shops;

  const CategoryShopsLoaded({
    required this.categories,
    required this.categorySlug,
    required this.shops,
  });

  @override
  List<Object?> get props => [categories, categorySlug, shops];
}

/// An error occurred while loading category shops.
class CategoryShopsError extends CategoriesState {
  /// The currently loaded categories.
  final List<Category> categories;

  /// The error message to display.
  final String message;

  const CategoryShopsError({
    required this.categories,
    required this.message,
  });

  @override
  List<Object?> get props => [categories, message];
}