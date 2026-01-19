/// Business rules for order validation and processing.
/// 
/// All order-related business rules are defined here.
/// This is pure Dart with no external dependencies.
/// 
/// Architecture note: Order rules define validation logic
/// for creating and processing orders.
library;
import '../entities/order_item.dart';

/// Business rules for order operations.
class OrderRules {
  OrderRules._();

  /// Minimum items required per order.
  static const int minimumItemsPerOrder = 1;

  /// Maximum items allowed per order.
  static const int maximumItemsPerOrder = 50;

  /// Default delivery fee in EGP.
  static const double defaultDeliveryFee = 10.0;

  /// Minimum delivery fee.
  static const double minimumDeliveryFee = 0.0;

  /// Maximum delivery fee.
  static const double maximumDeliveryFee = 100.0;

  /// Validate order items.
  static OrderValidationResult validateItems(List<OrderItemInput> items) {
    if (items.isEmpty) {
      return OrderValidationResult.invalid('Order must have at least one item');
    }

    if (items.length > maximumItemsPerOrder) {
      return OrderValidationResult.invalid(
        'Order cannot have more than $maximumItemsPerOrder items',
      );
    }

    // Validate each item
    for (final item in items) {
      if (item.quantity <= 0) {
        return OrderValidationResult.invalid(
          'Item "${item.productName}" has invalid quantity',
        );
      }
      if (item.price < 0) {
        return OrderValidationResult.invalid(
          'Item "${item.productName}" has invalid price',
        );
      }
    }

    // Calculate subtotal
    final subtotal = calculateSubtotal(items);

    return OrderValidationResult.valid(subtotal: subtotal);
  }

  /// Validate minimum order amount.
  static bool meetsMinimumOrder(double subtotal, double? minimumOrder) {
    if (minimumOrder == null || minimumOrder <= 0) return true;
    return subtotal >= minimumOrder;
  }

  /// Calculate order subtotal from items.
  static double calculateSubtotal(List<OrderItemInput> items) {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  /// Calculate total item count.
  static int calculateItemCount(List<OrderItemInput> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Calculate order total.
  static double calculateTotal({
    required double subtotal,
    required double deliveryFee,
    required double pointsDiscount,
  }) {
    final total = subtotal + deliveryFee - pointsDiscount;
    return total < 0 ? 0 : total;
  }

  /// Validate delivery address.
  static OrderValidationResult validateDeliveryAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return OrderValidationResult.invalid('Delivery address is required');
    }

    if (address.trim().length < 10) {
      return OrderValidationResult.invalid(
        'Please provide a more detailed address',
      );
    }

    return OrderValidationResult.valid();
  }

  /// Full order validation.
  static OrderValidationResult validateOrder({
    required List<OrderItemInput> items,
    required String? deliveryAddress,
    double? minimumOrder,
  }) {
    // Validate items
    final itemsResult = validateItems(items);
    if (!itemsResult.isValid) return itemsResult;

    // Validate minimum order
    if (!meetsMinimumOrder(itemsResult.subtotal!, minimumOrder)) {
      return OrderValidationResult.invalid(
        'Minimum order amount is ${minimumOrder!.toStringAsFixed(0)} EGP',
      );
    }

    // Validate address
    final addressResult = validateDeliveryAddress(deliveryAddress);
    if (!addressResult.isValid) return addressResult;

    return OrderValidationResult.valid(subtotal: itemsResult.subtotal);
  }
}

/// Result of order validation.
class OrderValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? subtotal;

  const OrderValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.subtotal,
  });

  factory OrderValidationResult.valid({double? subtotal}) {
    return OrderValidationResult._(
      isValid: true,
      subtotal: subtotal,
    );
  }

  factory OrderValidationResult.invalid(String message) {
    return OrderValidationResult._(
      isValid: false,
      errorMessage: message,
    );
  }
}