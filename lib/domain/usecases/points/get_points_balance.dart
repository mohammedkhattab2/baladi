// Domain - Use case for fetching customer points balance.
//
// Retrieves the current customer's total loyalty points balance.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/points_repository.dart';

/// Fetches the current customer's points balance.
///
/// Returns the total points balance as an integer.
@lazySingleton
class GetPointsBalance extends UseCase<int, NoParams> {
  final PointsRepository _repository;

  /// Creates a [GetPointsBalance] use case.
  GetPointsBalance(this._repository);

  @override
  Future<Result<int>> call(NoParams params) {
    return _repository.getPointsBalance();
  }
}