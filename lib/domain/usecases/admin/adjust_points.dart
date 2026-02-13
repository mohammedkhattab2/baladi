// Domain - Use case for adjusting customer points.
//
// Allows admin to add or subtract points from a customer's balance.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/admin_repository.dart';

/// Parameters for adjusting customer points.
class AdjustPointsParams extends Equatable {
  /// The customer's unique identifier.
  final String customerId;

  /// Points to add (positive) or subtract (negative).
  final int points;

  /// Reason for the adjustment.
  final String reason;

  /// Creates [AdjustPointsParams].
  const AdjustPointsParams({
    required this.customerId,
    required this.points,
    required this.reason,
  });

  @override
  List<Object?> get props => [customerId, points, reason];
}

/// Adjusts a customer's points balance.
///
/// Admin-only action. Positive values add points,
/// negative values subtract points. A reason must be provided
/// for audit trail purposes.
@lazySingleton
class AdjustPoints extends UseCase<void, AdjustPointsParams> {
  final AdminRepository _repository;

  /// Creates an [AdjustPoints] use case.
  AdjustPoints(this._repository);

  @override
  Future<Result<void>> call(AdjustPointsParams params) {
    return _repository.adjustPoints(
      customerId: params.customerId,
      points: params.points,
      reason: params.reason,
    );
  }
}