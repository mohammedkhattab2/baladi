// Domain - Use case for fetching rider earnings.
//
// Retrieves the rider's total earnings from completed deliveries.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/rider_repository.dart';

/// Fetches the rider's total earnings.
///
/// Returns the total earnings amount as a double.
@lazySingleton
class GetRiderEarnings extends UseCase<double, NoParams> {
  final RiderRepository _repository;

  /// Creates a [GetRiderEarnings] use case.
  GetRiderEarnings(this._repository);

  @override
  Future<Result<double>> call(NoParams params) {
    return _repository.getTotalEarnings();
  }
}