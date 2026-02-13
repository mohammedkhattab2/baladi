// Domain - Order status enumeration.
//
// Defines the lifecycle stages of an order from creation to completion.
// Maps directly to the backend `status` column in the orders table.

/// Represents the current stage of an order in its lifecycle.
///
/// Status flow:
/// ```
/// pending → accepted → preparing → picked_up → shop_paid → completed
///                                                            ↕
///                                                        cancelled
/// ```
/// Cancellation is allowed from [pending] and [accepted] only.
enum OrderStatus {
  /// Order created, waiting for shop to accept.
  pending('pending', 'قيد الانتظار'),

  /// Shop accepted the order and will prepare it.
  accepted('accepted', 'مقبول'),

  /// Shop is preparing the order items.
  preparing('preparing', 'جاري التحضير'),

  /// Rider picked up the order from the shop.
  pickedUp('picked_up', 'تم الاستلام'),

  /// Rider handed cash to the shop after delivery.
  shopPaid('shop_paid', 'تم الدفع للمتجر'),

  /// Order fully completed — cash confirmed by shop.
  completed('completed', 'مكتمل'),

  /// Order was cancelled.
  cancelled('cancelled', 'ملغي');

  /// The value stored in the backend database.
  final String value;

  /// Arabic display label.
  final String labelAr;

  const OrderStatus(this.value, this.labelAr);

  /// Creates an [OrderStatus] from its backend string [value].
  ///
  /// Throws [ArgumentError] if [value] doesn't match any status.
  static OrderStatus fromValue(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => throw ArgumentError('Unknown OrderStatus: $value'),
    );
  }

  /// Returns `true` if this order is still active (not completed or cancelled).
  bool get isActive =>
      this != OrderStatus.completed && this != OrderStatus.cancelled;

  /// Returns `true` if this order can be cancelled.
  bool get isCancellable =>
      this == OrderStatus.pending || this == OrderStatus.accepted;

  /// Returns `true` if this order requires shop action.
  bool get requiresShopAction =>
      this == OrderStatus.pending || this == OrderStatus.accepted;

  /// Returns `true` if this order requires rider action.
  bool get requiresRiderAction =>
      this == OrderStatus.preparing || this == OrderStatus.pickedUp;

  /// Returns the next status in the lifecycle, or `null` if terminal.
  OrderStatus? get nextStatus => switch (this) {
        OrderStatus.pending => OrderStatus.accepted,
        OrderStatus.accepted => OrderStatus.preparing,
        OrderStatus.preparing => OrderStatus.pickedUp,
        OrderStatus.pickedUp => OrderStatus.shopPaid,
        OrderStatus.shopPaid => OrderStatus.completed,
        OrderStatus.completed => null,
        OrderStatus.cancelled => null,
      };
}