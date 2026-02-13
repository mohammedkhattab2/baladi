// Domain - Use case for applying a referral code.
//
// Applies a referral code to the current customer, awarding
// bonus points to the referrer.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/customer_repository.dart';

/// Parameters for applying a referral code.
class ApplyReferralParams extends Equatable {
  /// The referral code to apply.
  final String referralCode;

  /// Creates [ApplyReferralParams].
  const ApplyReferralParams({required this.referralCode});

  @override
  List<Object?> get props => [referralCode];
}

/// Applies a referral code to the current customer.
///
/// Awards bonus points to the referrer upon successful application.
/// A customer can only apply a referral code once.
@lazySingleton
class ApplyReferral extends UseCase<void, ApplyReferralParams> {
  final CustomerRepository _repository;

  /// Creates an [ApplyReferral] use case.
  ApplyReferral(this._repository);

  @override
  Future<Result<void>> call(ApplyReferralParams params) {
    return _repository.applyReferralCode(params.referralCode);
  }
}