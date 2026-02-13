// Domain - Use case for updating customer profile.
//
// Updates the current customer's profile information.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Parameters for updating customer profile.
class UpdateProfileParams extends Equatable {
  /// Updated full name (optional).
  final String? fullName;

  /// Creates [UpdateProfileParams].
  const UpdateProfileParams({this.fullName});

  @override
  List<Object?> get props => [fullName];
}

/// Updates the current customer's profile.
///
/// Returns the updated customer entity on success.
@lazySingleton
class UpdateProfile extends UseCase<Customer, UpdateProfileParams> {
  final CustomerRepository _repository;

  /// Creates an [UpdateProfile] use case.
  UpdateProfile(this._repository);

  @override
  Future<Result<Customer>> call(UpdateProfileParams params) {
    return _repository.updateProfile(fullName: params.fullName);
  }
}