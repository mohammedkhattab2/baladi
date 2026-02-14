// Domain - Use case for toggling shop open/closed status.
//
// Allows a shop owner to toggle their shop between open and closed states.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/shop.dart';
import '../../repositories/shop_repository.dart';

/// Parameters for toggling shop status.
class ToggleShopStatusParams extends Equatable {
  /// Whether the shop should be open.
  final bool isOpen;

  /// Creates [ToggleShopStatusParams].
  const ToggleShopStatusParams({required this.isOpen});

  @override
  List<Object?> get props => [isOpen];
}

/// Toggles the shop's open/closed status.
///
/// Used by shop owners to indicate whether they are accepting orders.
@lazySingleton
class ToggleShopStatus extends UseCase<Shop, ToggleShopStatusParams> {
  final ShopRepository _repository;

  /// Creates a [ToggleShopStatus] use case.
  ToggleShopStatus(this._repository);

  @override
  Future<Result<Shop>> call(ToggleShopStatusParams params) {
    return _repository.updateShopStatus(isOpen: params.isOpen);
  }
}