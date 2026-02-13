// Domain - Use case for toggling rider availability.
//
// Toggles the rider's availability status for accepting deliveries.

import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

import '../../../core/result/result.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/rider.dart';
import '../../repositories/rider_repository.dart';

/// Parameters for toggling rider availability.
class ToggleAvailabilityParams extends Equatable {
  /// Whether the rider is available for deliveries.
  final bool isAvailable;

  /// Creates [ToggleAvailabilityParams].
  const ToggleAvailabilityParams({required this.isAvailable});

  @override
  List<Object?> get props => [isAvailable];
}

/// Toggles the rider's availability status.
///
/// When available, the rider can see and accept delivery orders.
/// Returns the updated rider entity.
@lazySingleton
class ToggleAvailability extends UseCase<Rider, ToggleAvailabilityParams> {
  final RiderRepository _repository;

  /// Creates a [ToggleAvailability] use case.
  ToggleAvailability(this._repository);

  @override
  Future<Result<Rider>> call(ToggleAvailabilityParams params) {
    return _repository.updateAvailability(isAvailable: params.isAvailable);
  }
}