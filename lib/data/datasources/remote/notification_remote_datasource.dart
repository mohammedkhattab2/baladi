// Data - Notification remote datasource.
//
// Abstract interface and implementation for notification API calls.
// Handles fetching notifications, marking as read, and unread count.

import 'package:injectable/injectable.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../../models/notification_model.dart';

/// Remote datasource contract for notification operations.
abstract class NotificationRemoteDatasource {
  /// Fetches notifications for the current user.
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 20,
  });

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId);

  /// Marks all notifications as read for the current user.
  Future<void> markAllAsRead();

  /// Returns the count of unread notifications.
  Future<int> getUnreadCount();
}

/// Implementation of [NotificationRemoteDatasource] using [ApiClient].
@LazySingleton(as: NotificationRemoteDatasource)
class NotificationRemoteDatasourceImpl implements NotificationRemoteDatasource {
  final ApiClient _apiClient;

  /// Creates a [NotificationRemoteDatasourceImpl].
  NotificationRemoteDatasourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    final response = await _apiClient.get<List<NotificationModel>>(
      ApiEndpoints.notifications,
      queryParameters: {
        'page': page.toString(),
        'per_page': perPage.toString(),
      },
      fromJson: (json) => _parseList(json, NotificationModel.fromJson),
    );
    return response.data ?? [];
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _apiClient.put(ApiEndpoints.notificationRead(notificationId));
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.put(ApiEndpoints.notificationsReadAll);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get(
      ApiEndpoints.notifications,
      queryParameters: {'unread_count': 'true'},
      fromJson: (json) => json['unread_count'] as int,
    );
    return response.data ?? 0;
  }

  /// Parses a list of items from the standard API list response format.
  static List<T> _parseList<T>(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    final items = json['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
  }
}