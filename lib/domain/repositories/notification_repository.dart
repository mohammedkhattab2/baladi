// Domain - Notification repository interface.
//
// Defines the contract for notification operations including
// fetching, marking as read, and local caching.

import '../../core/result/result.dart';
import '../entities/app_notification.dart';

/// Repository contract for notification operations.
///
/// Handles fetching notifications, marking them as read,
/// and local caching for offline access.
abstract class NotificationRepository {
  /// Fetches notifications for the current user.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<AppNotification>>> getNotifications({
    int page = 1,
    int perPage = 20,
  });

  /// Marks a specific notification as read.
  ///
  /// - [notificationId]: The notification's unique identifier.
  Future<Result<void>> markAsRead(String notificationId);

  /// Marks all notifications as read for the current user.
  Future<Result<void>> markAllAsRead();

  /// Returns the count of unread notifications.
  Future<Result<int>> getUnreadCount();

  /// Returns locally cached notifications, or empty list if none.
  Future<List<AppNotification>> getCachedNotifications();

  /// Caches notifications locally.
  Future<void> cacheNotifications(List<AppNotification> notifications);

  /// Clears cached notifications.
  Future<void> clearCache();
}