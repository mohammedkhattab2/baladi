// Domain - Use case for managing shop products.
//
// Handles creating, updating, and deleting products
// for the current shop owner.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/product.dart';
import '../../repositories/shop_repository.dart';

/// Parameters for creating a new product.
class CreateProductParams extends Equatable {
  /// Product name.
  final String name;

  /// Arabic product name (optional).
  final String? nameAr;

  /// Product description (optional).
  final String? description;

  /// Product price in EGP.
  final double price;

  /// Product image URL (optional).
  final String? imageUrl;

  /// Creates [CreateProductParams].
  const CreateProductParams({
    required this.name,
    this.nameAr,
    this.description,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [name, nameAr, description, price, imageUrl];
}

/// Parameters for updating an existing product.
class UpdateProductParams extends Equatable {
  /// The product's unique identifier.
  final String productId;

  /// Updated product name (optional).
  final String? name;

  /// Updated Arabic name (optional).
  final String? nameAr;

  /// Updated description (optional).
  final String? description;

  /// Updated price (optional).
  final double? price;

  /// Updated image URL (optional).
  final String? imageUrl;

  /// Updated availability (optional).
  final bool? isAvailable;

  /// Creates [UpdateProductParams].
  const UpdateProductParams({
    required this.productId,
    this.name,
    this.nameAr,
    this.description,
    this.price,
    this.imageUrl,
    this.isAvailable,
  });

  @override
  List<Object?> get props =>
      [productId, name, nameAr, description, price, imageUrl, isAvailable];
}

/// Parameters for deleting a product.
class DeleteProductParams extends Equatable {
  /// The product's unique identifier.
  final String productId;

  /// Creates [DeleteProductParams].
  const DeleteProductParams({required this.productId});

  @override
  List<Object?> get props => [productId];
}

/// Creates a new product in the shop.
///
/// Returns the created product entity on success.
@lazySingleton
class CreateProduct extends UseCase<Product, CreateProductParams> {
  final ShopRepository _repository;

  /// Creates a [CreateProduct] use case.
  CreateProduct(this._repository);

  @override
  Future<Result<Product>> call(CreateProductParams params) {
    return _repository.createProduct(
      name: params.name,
      nameAr: params.nameAr,
      description: params.description,
      price: params.price,
      imageUrl: params.imageUrl,
    );
  }
}

/// Updates an existing product in the shop.
///
/// Returns the updated product entity on success.
@lazySingleton
class UpdateProduct extends UseCase<Product, UpdateProductParams> {
  final ShopRepository _repository;

  /// Creates an [UpdateProduct] use case.
  UpdateProduct(this._repository);

  @override
  Future<Result<Product>> call(UpdateProductParams params) {
    return _repository.updateProduct(
      productId: params.productId,
      name: params.name,
      nameAr: params.nameAr,
      description: params.description,
      price: params.price,
      imageUrl: params.imageUrl,
      isAvailable: params.isAvailable,
    );
  }
}

/// Deletes a product from the shop.
@lazySingleton
class DeleteProduct extends UseCase<void, DeleteProductParams> {
  final ShopRepository _repository;

  /// Creates a [DeleteProduct] use case.
  DeleteProduct(this._repository);

  @override
  Future<Result<void>> call(DeleteProductParams params) {
    return _repository.deleteProduct(params.productId);
  }
}