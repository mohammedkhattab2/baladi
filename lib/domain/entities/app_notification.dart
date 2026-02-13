// Domain - Notification entity.
//
// Represents an in-app or push notification sent to a user.
// Named AppNotification to avoid conflict with Flutter's Notification class.

import 'package:equatable/equatable.dart';

import '../enums/notification_type.dart';

/// An in-app notification delivered to a user.
///
/// Notifications are created by the backend when significant events
/// occur (order status changes, points earned, settlements ready)
/// and are also pushed via Firebase Cloud Messaging.
class AppNotification extends Equatable {
  /// Unique identifier (UUID from backend).
  final String id;

  /// The user this notification is for.
  final String userId;

  /// Notification title text.
  final String title;

  /// Notification body text.
  final String body;

  /// Type of notification for routing and display.
  final NotificationType type;

  /// Additional data payload (e.g. orderId, amount).
  final Map<String, dynamic>? data;

  /// Whether the user has read/seen this notification.
  final bool isRead;

  /// When the notification was created.
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.type,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  /// Returns the related order ID if this is an order notification.
  String? get relatedOrderId {
    if (data == null) return null;
    return data!['orderId'] as String? ?? data!['order_id'] as String?;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        body,
        type,
        data,
        isRead,
        createdAt,
      ];
}