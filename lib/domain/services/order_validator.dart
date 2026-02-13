// Domain - Service for order validation.
//
// Injectable service that wraps OrderRules for validating
// order creation parameters and status transitions.

import '../entities/order_item.dart';
import '../enums/order_status.dart';
import '../rules/order_rules.dart';

/// Validation result containing all field-level errors.
///
/// If [isValid] is `true`, the order can proceed.
/// Otherwise, [errors] contains Arabic error messages keyed by field name.
class OrderValidationResult {
  /// Map of field name → error message. Empty if valid.
  final Map<String, String> errors;

  /// Creates an [OrderValidationResult].
  const OrderValidationResult({required this.errors});

  /// Whether the order passed all validations.
  bool get isValid => errors.isEmpty;

  /// Whether the order has validation errors.
  bool get hasErrors => errors.isNotEmpty;

  /// Returns the error for a specific field, or `null` if none.
  String? errorFor(String field) => errors[field];
}

/// Domain service for order validation.
///
/// Wraps [OrderRules] to provide comprehensive validation of order
/// creation parameters including items, amounts, addresses, and notes.
/// Use cases delegate to this service for all order validation.
class OrderValidator {
  /// Creates an [OrderValidator] instance.
  const OrderValidator();

  /// Validates all parameters for creating a new order.
  ///
  /// - [items]: The list of order items.
  /// - [subtotal]: The calculated subtotal.
  /// - [minimumOrderAmount]: The shop's minimum order amount.
  /// - [deliveryAddress]: The customer's delivery address.
  /// - [notes]: Optional customer notes.
  ///
  /// Returns an [OrderValidationResult] with any errors found.
  OrderValidationResult validateNewOrder({
    required List<OrderItem> items,
    required double subtotal,
    required double minimumOrderAmount,
    required String? deliveryAddress,
    String? notes,
  }) {
    final errors = <String, String>{};

    // Validate item count
    final itemCountError = OrderRules.validateItemCount(items.length);
    if (itemCountError != null) {
      errors['items'] = itemCountError;
    }

    // Validate each item has positive quantity and price
    for (int i = 0; i < items.length; i++) {
      if (items[i].quantity <= 0) {
        errors['item_${i}_quantity'] = 'الكمية يجب أن تكون أكبر من صفر';
      }
      if (items[i].price < 0) {
        errors['item_${i}_price'] = 'السعر غير صالح';
      }
    }

    // Validate minimum order amount
    final minOrderError = OrderRules.validateMinimumOrder(
      subtotal,
      minimumOrderAmount,
    );
    if (minOrderError != null) {
      errors['subtotal'] = minOrderError;
    }

    // Validate delivery address
    final addressError = OrderRules.validateDeliveryAddress(deliveryAddress);
    if (addressError != null) {
      errors['address'] = addressError;
    }

    // Validate notes
    final notesError = OrderRules.validateNotes(notes);
    if (notesError != null) {
      errors['notes'] = notesError;
    }

    return OrderValidationResult(errors: errors);
  }

  /// Validates that an order status transition is allowed.
  ///
  /// Returns `null` if valid, or an Arabic error message if not.
  String? validateStatusTransition({
    required OrderStatus currentStatus,
    required OrderStatus newStatus,
  }) {
    return OrderRules.validateStatusTransition(currentStatus, newStatus);
  }

  /// Validates cancellation of an order.
  ///
  /// Returns `null` if cancellation is allowed, or an error message.
  String? validateCancellation(OrderStatus currentStatus) {
    return OrderRules.validateStatusTransition(
      currentStatus,
      OrderStatus.cancelled,
    );
  }

  /// Checks whether an order has exceeded the auto-reject timeout.
  bool hasExceededTimeout(DateTime createdAt) {
    return OrderRules.hasExceededTimeout(createdAt);
  }
}