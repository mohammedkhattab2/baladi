/// UpdateOrderStatus use case.
/// 
/// Handles order status transitions with validation.
/// Enforces the order state machine rules.
/// 
/// Architecture note: Use cases orchestrate domain services and
/// repositories. Status transitions are validated by domain services.
library;
import '../../core/result/result.dart' as result;
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../enums/order_status.dart';
import '../enums/user_role.dart';
import '../repositories/order_repository.dart';
import '../repositories/points_repository.dart';
import '../services/order_processor.dart';

/// Parameters for updating order status.
class UpdateOrderStatusParams {
  final String orderId;
  final OrderStatus newStatus;
  final String updatedBy;
  final UserRole updaterRole;
  final String? note;
  final String? cancellationReason;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.newStatus,
    required this.updatedBy,
    required this.updaterRole,
    this.note,
    this.cancellationReason,
  });
}

/// Result of updating order status.
class UpdateOrderStatusResult {
  final Order order;
  final OrderStatus previousStatus;
  final bool pointsAwarded;

  const UpdateOrderStatusResult({
    required this.order,
    required this.previousStatus,
    this.pointsAwarded = false,
  });
}

/// Use case for updating order status.
class UpdateOrderStatus implements UseCase<UpdateOrderStatusResult, UpdateOrderStatusParams> {
  final OrderRepository _orderRepository;
  final PointsRepository _pointsRepository;
  final OrderProcessor _orderProcessor;

  UpdateOrderStatus({
    required OrderRepository orderRepository,
    required PointsRepository pointsRepository,
    OrderProcessor? orderProcessor,
  })  : _orderRepository = orderRepository,
        _pointsRepository = pointsRepository,
        _orderProcessor = orderProcessor ?? OrderProcessor();

  @override
  Future<result.Result<UpdateOrderStatusResult>> call(UpdateOrderStatusParams params) async {
    // Step 1: Get current order
    final orderResult = await _orderRepository.getOrderById(params.orderId);

    return orderResult.fold(
      onSuccess: (order) async {
        final previousStatus = order.status;

        // Step 2: Validate status transition
        final transitionResult = _orderProcessor.validateStatusTransition(
          previousStatus,
          params.newStatus,
        );

        if (!transitionResult.canTransition) {
          return result.Failure(
            BusinessRuleFailure(
              message: transitionResult.reason ?? 
                'Invalid status transition from ${previousStatus.displayName} to ${params.newStatus.displayName}',
            ),
          );
        }

        // Step 3: Validate role permissions
        final permissionResult = _validateRolePermission(
          params.updaterRole,
          params.newStatus,
        );

        if (!permissionResult.isAllowed) {
          return result.Failure(
            UnauthorizedFailure(
              message: permissionResult.reason ?? 'You do not have permission to perform this action',
            ),
          );
        }

        // Step 4: Handle cancellation
        if (params.newStatus == OrderStatus.cancelled) {
          if (params.cancellationReason == null || params.cancellationReason!.isEmpty) {
            return result.Failure(
              ValidationFailure(message: 'Cancellation reason is required'),
            );
          }

          final cancelResult = await _orderRepository.cancelOrder(
            orderId: params.orderId,
            cancelledBy: params.updatedBy,
            cancellerRole: params.updaterRole,
            reason: params.cancellationReason!,
          );

          return cancelResult.fold(
            onSuccess: (cancelledOrder) {
              // Reverse points if they were used
              if (order.pointsUsed > 0) {
                _pointsRepository.reverseRedemption(
                  customerId: order.customerId,
                  orderId: order.id,
                  points: order.pointsUsed,
                );
              }

              return result.Success(UpdateOrderStatusResult(
                order: cancelledOrder,
                previousStatus: previousStatus,
              ));
            },
            onFailure: (failure) => result.Failure(failure),
          );
        }

        // Step 5: Update order status
        final updateResult = await _orderRepository.updateOrderStatus(
          orderId: params.orderId,
          newStatus: params.newStatus,
          updatedBy: params.updatedBy,
          updaterRole: params.updaterRole,
          note: params.note,
        );

        return updateResult.fold(
          onSuccess: (updatedOrder) async {
            bool pointsAwarded = false;

            // Step 6: Award points on completion
            if (params.newStatus == OrderStatus.completed && order.pointsEarned > 0) {
              await _pointsRepository.addPointsForOrder(
                customerId: order.customerId,
                orderId: order.id,
                points: order.pointsEarned,
              );
              pointsAwarded = true;
            }

            return result.Success(UpdateOrderStatusResult(
              order: updatedOrder,
              previousStatus: previousStatus,
              pointsAwarded: pointsAwarded,
            ));
          },
          onFailure: (failure) => result.Failure(failure),
        );
      },
      onFailure: (failure) => result.Failure(failure),
    );
  }

  /// Validate if the user role can perform the status transition.
  RolePermissionResult _validateRolePermission(UserRole role, OrderStatus newStatus) {
    // Define which roles can transition to which statuses
    final allowedTransitions = <UserRole, Set<OrderStatus>>{
      UserRole.customer: {OrderStatus.cancelled},
      UserRole.store: {
        OrderStatus.accepted,
        OrderStatus.preparing,
        OrderStatus.cancelled,
      },
      UserRole.delivery: {
        OrderStatus.pickedUp,
        OrderStatus.shopPaid,
      },
      UserRole.admin: OrderStatus.values.toSet(),
    };

    final allowed = allowedTransitions[role] ?? <OrderStatus>{};

    if (allowed.contains(newStatus)) {
      return const RolePermissionResult(isAllowed: true);
    }

    return RolePermissionResult(
      isAllowed: false,
      reason: '${role.displayName} cannot transition order to ${newStatus.displayName}',
    );
  }
}

/// Result of role permission check.
class RolePermissionResult {
  final bool isAllowed;
  final String? reason;

  const RolePermissionResult({
    required this.isAllowed,
    this.reason,
  });
}