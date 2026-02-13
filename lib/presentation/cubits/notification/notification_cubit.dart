// Presentation - Notification cubit.
//
// Manages notification state including fetching, pagination,
// marking as read, and unread count tracking.

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/entities/app_notification.dart';
import '../../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';

/// Cubit that manages all notification-related operations.
///
/// Handles loading notifications with pagination, marking individual
/// or all notifications as read, and tracking unread count.
@injectable
class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationRepository;

  /// Creates a [NotificationCubit].
  NotificationCubit({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(const NotificationInitial());

  // ---------------------------------------------------------------------------
  // Load Notifications
  // ---------------------------------------------------------------------------

  /// Loads notifications and unread count.
  Future<void> loadNotifications({
    int perPage = AppConstants.defaultPageSize,
  }) async {
    emit(const NotificationLoading());

    final notificationsResult = await _notificationRepository.getNotifications(
      page: 1,
      perPage: perPage,
    );
    final unreadResult = await _notificationRepository.getUnreadCount();

    if (notificationsResult.isSuccess && unreadResult.isSuccess) {
      final List<AppNotification> notifications = notificationsResult.data!;
      final int unreadCount = unreadResult.data!;

      emit(NotificationLoaded(
        notifications: notifications,
        unreadCount: unreadCount,
        currentPage: 1,
        hasMore: notifications.length >= perPage,
      ));
    } else {
      final failure = notificationsResult.isFailure
          ? notificationsResult.failure
          : unreadResult.failure;
      emit(NotificationError(message: failure!.message));
    }
  }

  /// Loads more notifications (next page).
  Future<void> loadMore({int perPage = AppConstants.defaultPageSize}) async {
    final currentState = state;
    if (currentState is! NotificationLoaded || !currentState.hasMore) {
      return;
    }

    final nextPage = currentState.currentPage + 1;
    emit(NotificationLoadingMore(
      notifications: currentState.notifications,
      unreadCount: currentState.unreadCount,
    ));

    final result = await _notificationRepository.getNotifications(
      page: nextPage,
      perPage: perPage,
    );

    result.fold(
      onSuccess: (newNotifications) {
        emit(NotificationLoaded(
          notifications: [...currentState.notifications, ...newNotifications],
          unreadCount: currentState.unreadCount,
          currentPage: nextPage,
          hasMore: newNotifications.length >= perPage,
        ));
      },
      onFailure: (failure) {
        // Restore previous state on error
        emit(NotificationLoaded(
          notifications: currentState.notifications,
          unreadCount: currentState.unreadCount,
          currentPage: currentState.currentPage,
          hasMore: currentState.hasMore,
        ));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Mark as Read
  // ---------------------------------------------------------------------------

  /// Marks a specific notification as read.
  Future<void> markAsRead(String notificationId) async {
    final result = await _notificationRepository.markAsRead(notificationId);

    result.fold(
      onSuccess: (_) {
        final currentState = state;
        if (currentState is NotificationLoaded) {
          final List<AppNotification> updatedNotifications =
              currentState.notifications.map((n) {
            if (n.id == notificationId) {
              return _copyNotificationAsRead(n);
            }
            return n;
          }).toList();

          final newUnreadCount = (currentState.unreadCount - 1).clamp(0, currentState.unreadCount);

          emit(NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: newUnreadCount,
            currentPage: currentState.currentPage,
            hasMore: currentState.hasMore,
          ));
        }
      },
      onFailure: (_) {
        // Silently fail — notification list remains unchanged
      },
    );
  }

  /// Marks all notifications as read.
  Future<void> markAllAsRead() async {
    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      onSuccess: (_) {
        final currentState = state;
        if (currentState is NotificationLoaded) {
          final List<AppNotification> updatedNotifications =
              currentState.notifications
                  .map(_copyNotificationAsRead)
                  .toList();

          emit(NotificationLoaded(
            notifications: updatedNotifications,
            unreadCount: 0,
            currentPage: currentState.currentPage,
            hasMore: currentState.hasMore,
          ));
        }
      },
      onFailure: (failure) {
        emit(NotificationError(message: failure.message));
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Refresh Unread Count
  // ---------------------------------------------------------------------------

  /// Refreshes only the unread count without reloading notifications.
  Future<void> refreshUnreadCount() async {
    final result = await _notificationRepository.getUnreadCount();

    result.fold(
      onSuccess: (count) {
        final currentState = state;
        if (currentState is NotificationLoaded) {
          emit(NotificationLoaded(
            notifications: currentState.notifications,
            unreadCount: count,
            currentPage: currentState.currentPage,
            hasMore: currentState.hasMore,
          ));
        }
      },
      onFailure: (_) {
        // Silently fail — keep existing state
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Creates a copy of the notification with [isRead] set to `true`.
  ///
  /// Since [AppNotification] is immutable (final fields), we construct
  /// a new instance manually.
  AppNotification _copyNotificationAsRead(AppNotification n) {
    return AppNotification(
      id: n.id,
      userId: n.userId,
      title: n.title,
      body: n.body,
      type: n.type,
      data: n.data,
      isRead: true,
      createdAt: n.createdAt,
    );
  }
}