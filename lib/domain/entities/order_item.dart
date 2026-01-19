/// Order item entity in the Baladi application.
/// 
/// This is a pure domain entity representing a single item
/// within an order.
/// 
/// Architecture note: OrderItem is a value object that belongs
/// to an Order aggregate root.
library;
/// Represents a single item in an order.
class OrderItem {
  /// Unique identifier for the order item.
  final String id;

  /// Order ID this item belongs to.
  final String orderId;

  /// Product ID (reference to the product).
  final String productId;

  /// Product name (snapshot at time of order).
  final String productName;

  /// Price per unit (snapshot at time of order).
  final double price;

  /// Quantity ordered.
  final int quantity;

  /// Subtotal for this item (price * quantity).
  final double subtotal;

  /// Special notes for this item.
  final String? notes;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.notes,
  });

  /// Creates a copy of this order item with the given fields replaced.
  OrderItem copyWith({
    String? id,
    String? orderId,
    String? productId,
    String? productName,
    double? price,
    int? quantity,
    double? subtotal,
    String? notes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      subtotal: subtotal ?? this.subtotal,
      notes: notes ?? this.notes,
    );
  }

  /// Creates an OrderItem with calculated subtotal.
  factory OrderItem.create({
    required String id,
    required String orderId,
    required String productId,
    required String productName,
    required double price,
    required int quantity,
    String? notes,
  }) {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
      subtotal: price * quantity,
      notes: notes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'OrderItem(id: $id, productName: $productName, qty: $quantity)';
}

/// Input for creating an order item (before order is created).
class OrderItemInput {
  /// Product ID.
  final String productId;

  /// Product name.
  final String productName;

  /// Price per unit.
  final double price;

  /// Quantity.
  final int quantity;

  /// Special notes.
  final String? notes;

  const OrderItemInput({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.notes,
  });

  /// Calculates the subtotal for this item.
  double get subtotal => price * quantity;

  @override
  String toString() => 'OrderItemInput(productId: $productId, qty: $quantity)';
}