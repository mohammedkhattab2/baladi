// Domain - Business rules for order validation.
//
// Pure Dart — no external dependencies. Defines validation
// constraints and rules for creating and managing orders.

import '../enums/order_status.dart';

/// Business rules governing order creation and lifecycle management.
///
/// Key rules:
/// - Minimum 1 item per order
/// - Orders must meet shop minimum order amount
/// - Default delivery fee is 10 EGP
/// - Cancellation only allowed from pending/accepted status
/// - Auto-reject timeout is 10 minutes
class OrderRules {
  OrderRules._();

  /// Minimum number of items per order.
  static const int minimumItemsPerOrder = 1;

  /// Maximum number of items per order.
  static const int maximumItemsPerOrder = 50;

  /// Default delivery fee in EGP.
  static const double defaultDeliveryFee = 10.0;

  /// Maximum length for customer notes.
  static const int maxNotesLength = 500;

  /// Maximum length for delivery address.
  static const int maxAddressLength = 255;

  /// Duration after which an unaccepted order auto-rejects.
  static const Duration autoRejectTimeout = Duration(minutes: 10);

  /// Statuses from which cancellation is allowed.
  static const List<OrderStatus> cancellableStatuses = [
    OrderStatus.pending,
    OrderStatus.accepted,
  ];

  /// Validates that the order has a valid number of items.
  ///
  /// Returns `null` if valid, or an error message if invalid.
  static String? validateItemCount(int itemCount) {
    if (itemCount < minimumItemsPerOrder) {
      return 'يجب إضافة منتج واحد على الأقل';
    }
    if (itemCount > maximumItemsPerOrder) {
      return 'الحد الأقصى $maximumItemsPerOrder منتج في الطلب الواحد';
    }
    return null;
  }

  /// Validates that the subtotal meets the shop's minimum order amount.
  ///
  /// Returns `null` if valid, or an error message if invalid.
  static String? validateMinimumOrder(double subtotal, double minimumOrder) {
    if (minimumOrder > 0 && subtotal < minimumOrder) {
      return 'الحد الأدنى للطلب ${minimumOrder.toStringAsFixed(0)} جنيه';
    }
    return null;
  }

  /// Validates that an order can transition to the given [newStatus].
  ///
  /// Returns `null` if the transition is valid, or an error message if not.
  static String? validateStatusTransition(
    OrderStatus currentStatus,
    OrderStatus newStatus,
  ) {
    // Cancellation check
    if (newStatus == OrderStatus.cancelled) {
      if (!cancellableStatuses.contains(currentStatus)) {
        return 'لا يمكن إلغاء الطلب في حالة "${currentStatus.labelAr}"';
      }
      return null;
    }

    // Normal forward transition
    final expectedNext = currentStatus.nextStatus;
    if (expectedNext == null) {
      return 'الطلب في حالته النهائية "${currentStatus.labelAr}"';
    }
    if (newStatus != expectedNext) {
      return 'لا يمكن الانتقال من "${currentStatus.labelAr}" إلى "${newStatus.labelAr}"';
    }
    return null;
  }

  /// Validates the delivery address.
  ///
  /// Returns `null` if valid, or an error message if invalid.
  static String? validateDeliveryAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return 'عنوان التوصيل مطلوب';
    }
    if (address.length > maxAddressLength) {
      return 'العنوان طويل جداً (الحد الأقصى $maxAddressLength حرف)';
    }
    return null;
  }

  /// Validates customer notes.
  ///
  /// Returns `null` if valid, or an error message if invalid.
  static String? validateNotes(String? notes) {
    if (notes != null && notes.length > maxNotesLength) {
      return 'الملاحظات طويلة جداً (الحد الأقصى $maxNotesLength حرف)';
    }
    return null;
  }

  /// Checks whether an order has exceeded the auto-reject timeout.
  static bool hasExceededTimeout(DateTime createdAt) {
    return DateTime.now().difference(createdAt) > autoRejectTimeout;
  }
}