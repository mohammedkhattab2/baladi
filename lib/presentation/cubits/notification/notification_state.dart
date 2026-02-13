// Presentation - Notification cubit states.
//
// Defines all possible states for the notification feature including
// loading, loaded with unread count, and error states.

import 'package:equatable/equatable.dart';

import '../../../domain/entities/app_notification.dart';

/// Base state for the notification cubit.
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state — notifications not yet loaded.
class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

/// Notifications are being fetched.
class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

/// Notifications loaded successfully.
class NotificationLoaded extends NotificationState {
  /// The list of notifications.
  final List<AppNotification> notifications;

  /// Number of unread notifications.
  final int unreadCount;

  /// Current page number.
  final int currentPage;

  /// Whether more pages are available.
  final bool hasMore;

  const NotificationLoaded({
    required this.notifications,
    this.unreadCount = 0,
    this.currentPage = 1,
    this.hasMore = false,
  });

  @override
  List<Object?> get props => [notifications, unreadCount, currentPage, hasMore];
}

/// More notifications are being loaded (preserves existing list).
class NotificationLoadingMore extends NotificationState {
  /// Existing notifications to preserve UI.
  final List<AppNotification> notifications;

  /// Current unread count.
  final int unreadCount;

  const NotificationLoadingMore({
    required this.notifications,
    this.unreadCount = 0,
  });

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// An error occurred during a notification operation.
class NotificationError extends NotificationState {
  /// The error message to display.
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object?> get props => [message];
}