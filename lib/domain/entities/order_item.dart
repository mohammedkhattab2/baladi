// Domain - Order item entity.
//
// Represents a single line item within an order.

import 'package:equatable/equatable.dart';

/// A single product line item within an [Order].
///
/// Stores a snapshot of the product name and price at the time
/// the order was placed, so it remains accurate even if the
/// product is later modified or deleted.
class OrderItem extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The order this item belongs to.
  final String orderId;

  /// Reference to the original product (may be null if deleted).
  final String? productId;

  /// Product name snapshot at time of order.
  final String productName;

  /// Unit price snapshot at time of order (in EGP).
  final double price;

  /// Quantity ordered.
  final int quantity;

  /// Line total: [price] × [quantity].
  final double subtotal;

  /// Optional notes for this item (e.g. "بدون بصل").
  final String? notes;

  const OrderItem({
    required this.id,
    required this.orderId,
    this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        price,
        quantity,
        subtotal,
        notes,
      ];
}