// Domain - Use case for updating customer delivery address.
//
// Updates the current customer's delivery address, landmark, and area.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Parameters for updating customer address.
class UpdateAddressParams extends Equatable {
  /// Full delivery address text.
  final String addressText;

  /// Optional landmark near the address.
  final String? landmark;

  /// Optional area/district name.
  final String? area;

  /// Creates [UpdateAddressParams].
  const UpdateAddressParams({
    required this.addressText,
    this.landmark,
    this.area,
  });

  @override
  List<Object?> get props => [addressText, landmark, area];
}

/// Updates the current customer's delivery address.
///
/// Returns the updated customer entity on success.
@lazySingleton
class UpdateAddress extends UseCase<Customer, UpdateAddressParams> {
  final CustomerRepository _repository;

  /// Creates an [UpdateAddress] use case.
  UpdateAddress(this._repository);

  @override
  Future<Result<Customer>> call(UpdateAddressParams params) {
    return _repository.updateAddress(
      addressText: params.addressText,
      landmark: params.landmark,
      area: params.area,
    );
  }
}