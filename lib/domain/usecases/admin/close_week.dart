// Domain - Use case for closing the current weekly period.
//
// Closes the active weekly period, generating settlement
// records for all shops and riders.

import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/weekly_period.dart';
import '../../repositories/admin_repository.dart';

/// Closes the current active weekly period.
///
/// Generates settlement records for all shops and riders,
/// calculates commissions and earnings, and transitions the
/// period status from active to closed.
@lazySingleton
class CloseWeek extends UseCase<WeeklyPeriod, NoParams> {
  final AdminRepository _repository;

  /// Creates a [CloseWeek] use case.
  CloseWeek(this._repository);

  @override
  Future<Result<WeeklyPeriod>> call(NoParams params) {
    return _repository.closeCurrentPeriod();
  }
}