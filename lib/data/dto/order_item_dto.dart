/// OrderItem Data Transfer Object.
///
/// Used for serialization/deserialization of OrderItem data
/// between API/database and domain entities.
library;

import '../../domain/entities/order_item.dart';

/// DTO for OrderItem entity.
class OrderItemDto {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final double subtotal;
  final String? notes;

  const OrderItemDto({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.subtotal,
    this.notes,
  });

  /// Create from JSON map.
  factory OrderItemDto.fromJson(Map<String, dynamic> json) {
    return OrderItemDto(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productId: json['product_id'] as String,
      productName: json['product_name'] as String,
      price: (json['price'] as num).toDouble(),
      quantity: json['quantity'] as int,
      subtotal: (json['subtotal'] as num).toDouble(),
      notes: json['notes'] as String?,
    );
  }

  /// Convert to JSON map.
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

  /// Convert to domain entity.
  OrderItem toEntity() {
    return OrderItem(
      id: id,
      orderId: orderId,
      productId: productId,
      productName: productName,
      price: price,
      quantity: quantity,
      subtotal: subtotal,
      notes: notes,
    );
  }

  /// Create from domain entity.
  factory OrderItemDto.fromEntity(OrderItem entity) {
    return OrderItemDto(
      id: entity.id,
      orderId: entity.orderId,
      productId: entity.productId,
      productName: entity.productName,
      price: entity.price,
      quantity: entity.quantity,
      subtotal: entity.subtotal,
      notes: entity.notes,
    );
  }
}