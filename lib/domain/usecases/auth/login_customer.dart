// Domain - Use case for customer login.
//
// Authenticates a customer using phone number and PIN code.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Parameters for customer login.
class LoginCustomerParams extends Equatable {
  /// Egyptian phone number (11 digits starting with 01).
  final String phone;

  /// 4-digit PIN code.
  final String pin;

  /// Creates [LoginCustomerParams].
  const LoginCustomerParams({
    required this.phone,
    required this.pin,
  });

  @override
  List<Object?> get props => [phone, pin];
}

/// Authenticates a customer with phone and PIN.
///
/// Returns auth tokens and user/customer profile on success.
@lazySingleton
class LoginCustomer extends UseCase<AuthResult, LoginCustomerParams> {
  final AuthRepository _repository;

  /// Creates a [LoginCustomer] use case.
  LoginCustomer(this._repository);

  @override
  Future<Result<AuthResult>> call(LoginCustomerParams params) {
    return _repository.loginCustomer(
      phone: params.phone,
      pin: params.pin,
    );
  }
}