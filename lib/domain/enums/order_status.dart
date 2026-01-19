/// Order status in the Baladi application.
/// 
/// Represents the complete lifecycle of an order from creation to completion.
/// Status transitions are strictly enforced by the domain layer.
/// 
/// Architecture note: This enum defines the order state machine.
/// Allowed transitions are enforced here to maintain business rule integrity.
library;
/// Order status representing the lifecycle of an order.
enum OrderStatus {
  /// Order created, waiting for store to accept.
  pending,
  
  /// Store has accepted the order.
  accepted,
  
  /// Store is preparing the order.
  preparing,
  
  /// Rider has picked up the order from store.
  pickedUp,
  
  /// Rider has delivered and handed cash to shop.
  shopPaid,
  
  /// Order is fully completed.
  completed,
  
  /// Order was cancelled.
  cancelled;

  /// Returns the allowed next statuses from current status.
  /// 
  /// This enforces the order state machine rules.
  /// No status can transition to a state not in this list.
  List<OrderStatus> get allowedTransitions {
    return switch (this) {
      OrderStatus.pending => [OrderStatus.accepted, OrderStatus.cancelled],
      OrderStatus.accepted => [OrderStatus.preparing, OrderStatus.cancelled],
      OrderStatus.preparing => [OrderStatus.pickedUp, OrderStatus.cancelled],
      OrderStatus.pickedUp => [OrderStatus.shopPaid],
      OrderStatus.shopPaid => [OrderStatus.completed],
      OrderStatus.completed => [],
      OrderStatus.cancelled => [],
    };
  }

  /// Returns true if this is a final/terminal status.
  bool get isFinal => this == completed || this == cancelled;

  /// Returns true if order can be cancelled from this status.
  bool get canBeCancelled => allowedTransitions.contains(OrderStatus.cancelled);

  /// Returns true if order is active (not final).
  bool get isActive => !isFinal;

  /// Returns true if order requires rider assignment.
  bool get requiresRider {
    return switch (this) {
      OrderStatus.pending => false,
      OrderStatus.accepted => true,
      OrderStatus.preparing => true,
      OrderStatus.pickedUp => true,
      OrderStatus.shopPaid => true,
      OrderStatus.completed => false,
      OrderStatus.cancelled => false,
    };
  }

  /// Checks if transition to new status is valid.
  bool canTransitionTo(OrderStatus newStatus) {
    return allowedTransitions.contains(newStatus);
  }

  /// Returns display name for the status.
  String get displayName {
    return switch (this) {
      OrderStatus.pending => 'Pending',
      OrderStatus.accepted => 'Accepted',
      OrderStatus.preparing => 'Preparing',
      OrderStatus.pickedUp => 'Picked Up',
      OrderStatus.shopPaid => 'Cash Received',
      OrderStatus.completed => 'Completed',
      OrderStatus.cancelled => 'Cancelled',
    };
  }

  /// Returns Arabic display name for the status.
  String get displayNameAr {
    return switch (this) {
      OrderStatus.pending => 'قيد الانتظار',
      OrderStatus.accepted => 'مقبول',
      OrderStatus.preparing => 'جاري التحضير',
      OrderStatus.pickedUp => 'تم الاستلام',
      OrderStatus.shopPaid => 'تم استلام النقود',
      OrderStatus.completed => 'مكتمل',
      OrderStatus.cancelled => 'ملغي',
    };
  }

  /// Returns a short description of what this status means.
  String get description {
    return switch (this) {
      OrderStatus.pending => 'Waiting for store to accept the order',
      OrderStatus.accepted => 'Store has accepted and will prepare',
      OrderStatus.preparing => 'Store is preparing your order',
      OrderStatus.pickedUp => 'Rider is on the way to deliver',
      OrderStatus.shopPaid => 'Delivery complete, cash transferred',
      OrderStatus.completed => 'Order completed successfully',
      OrderStatus.cancelled => 'Order was cancelled',
    };
  }

  /// Returns the sort order for status (useful for ordering).
  int get sortOrder {
    return switch (this) {
      OrderStatus.pending => 1,
      OrderStatus.accepted => 2,
      OrderStatus.preparing => 3,
      OrderStatus.pickedUp => 4,
      OrderStatus.shopPaid => 5,
      OrderStatus.completed => 6,
      OrderStatus.cancelled => 7,
    };
  }

  /// Parses a string to OrderStatus.
  static OrderStatus? fromString(String? value) {
    if (value == null) return null;
    return OrderStatus.values.where((s) => s.name == value).firstOrNull;
  }
}