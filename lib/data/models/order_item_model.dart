// Data - Order item model with JSON serialization.
//
// Maps between the API JSON representation and the domain OrderItem entity.

import '../../domain/entities/order_item.dart';

/// Data model for [OrderItem] with JSON serialization support.
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    super.productId,
    required super.productName,
    required super.price,
    required super.quantity,
    required super.subtotal,
    super.notes,
  });

  /// Creates an [OrderItemModel] from a JSON map.
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String?,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  /// Creates an [OrderItemModel] from a domain [OrderItem] entity.
  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      id: item.id,
      orderId: item.orderId,
      productId: item.productId,
      productName: item.productName,
      price: item.price,
      quantity: item.quantity,
      subtotal: item.subtotal,
      notes: item.notes,
    );
  }

  /// Converts this model to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'subtotal': subtotal,
      'notes': notes,
    };
  }
}