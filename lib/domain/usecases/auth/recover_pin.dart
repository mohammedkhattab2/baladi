// Domain - Use case for customer PIN recovery.
//
// Initiates PIN recovery for a customer using their phone number.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Parameters for PIN recovery.
class RecoverPinParams extends Equatable {
  /// Egyptian phone number (11 digits starting with 01).
  final String phone;

  /// Creates [RecoverPinParams].
  const RecoverPinParams({required this.phone});

  @override
  List<Object?> get props => [phone];
}

/// Initiates PIN recovery for a customer.
///
/// Sends a recovery request to the backend which handles
/// the actual PIN reset process.
@lazySingleton
class RecoverPin extends UseCase<void, RecoverPinParams> {
  final AuthRepository _repository;

  /// Creates a [RecoverPin] use case.
  RecoverPin(this._repository);

  @override
  Future<Result<void>> call(RecoverPinParams params) {
    return _repository.recoverCustomerPin(phone: params.phone);
  }
}