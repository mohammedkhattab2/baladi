// Domain - Use case for customer registration.
//
// Registers a new customer with phone, PIN, full name,
// and optional referral code.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/auth_repository.dart';

/// Parameters for customer registration.
class RegisterCustomerParams extends Equatable {
  /// Egyptian phone number (11 digits starting with 01).
  final String phone;

  /// 4-digit PIN code.
  final String pin;

  /// Customer's full name.
  final String fullName;

  /// Optional referral code from another customer.
  final String? referralCode;

  final String securityQuestion;
  final String securityAnswer;

  /// Creates [RegisterCustomerParams].
  const RegisterCustomerParams({
    required this.phone,
    required this.pin,
    required this.fullName,
    this.referralCode,
    required this.securityQuestion,
    required this.securityAnswer,
  });

  @override
  List<Object?> get props => [
    phone,
    pin,
    fullName,
    referralCode,
    securityQuestion,
    securityAnswer,
  ];
}

/// Registers a new customer account.
///
/// Validates input, sends registration request to backend,
/// and returns auth tokens + user profile on success.
@lazySingleton
class RegisterCustomer extends UseCase<AuthResult, RegisterCustomerParams> {
  final AuthRepository _repository;

  /// Creates a [RegisterCustomer] use case.
  RegisterCustomer(this._repository);

  @override
  Future<Result<AuthResult>> call(RegisterCustomerParams params) {
    return _repository.registerCustomer(
      phone: params.phone,
      pin: params.pin,
      fullName: params.fullName,
      referralCode: params.referralCode,
      securityQuestion: params.securityQuestion,
      securityAnswer: params.securityAnswer,
    );
  }
}
