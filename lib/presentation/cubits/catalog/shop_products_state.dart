// Presentation - Shop products cubit states.
//
// Defines all possible states for the shop products listing feature.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/product.dart';
import '../../../domain/entities/shop.dart';

/// Base state for the shop products cubit.
abstract class ShopProductsState extends Equatable {
  const ShopProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state — products not yet loaded.
class ShopProductsInitial extends ShopProductsState {
  const ShopProductsInitial();
}

/// Products are being fetched.
class ShopProductsLoading extends ShopProductsState {
  const ShopProductsLoading();
}

/// Products loaded successfully.
class ShopProductsLoaded extends ShopProductsState {
  /// The shop these products belong to.
  final Shop? shop;

  /// The list of products.
  final List<Product> products;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const ShopProductsLoaded({
    this.shop,
    required this.products,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [shop, products, currentPage, hasMore];
}

/// Loading more products (pagination).
class ShopProductsLoadingMore extends ShopProductsState {
  /// The existing products already loaded.
  final List<Product> products;

  const ShopProductsLoadingMore({required this.products});

  @override
  List<Object?> get props => [products];
}

/// An error occurred while loading products.
class ShopProductsError extends ShopProductsState {
  /// The error message to display.
  final String message;

  /// Previously loaded products (for retry UI).
  final List<Product> products;

  const ShopProductsError({
    required this.message,
    this.products = const [],
  });

  @override
  List<Object?> get props => [message, products];
}