// Domain - Use case for fetching customer profile.
//
// Retrieves the current customer's profile information.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/customer.dart';
import '../../repositories/customer_repository.dart';

/// Fetches the current customer's profile.
///
/// Returns the customer entity with all profile fields
/// including name, address, points balance, and referral code.
@lazySingleton
class GetProfile extends UseCase<Customer, NoParams> {
  final CustomerRepository _repository;

  /// Creates a [GetProfile] use case.
  GetProfile(this._repository);

  @override
  Future<Result<Customer>> call(NoParams params) {
    return _repository.getProfile();
  }
}