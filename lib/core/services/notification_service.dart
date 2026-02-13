// Core - Firebase Cloud Messaging service for push notifications.
//
// Handles FCM initialization, token management, foreground/background
// notification handling, and permission requests.

import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:injectable/injectable.dart';

/// Abstraction for push notification operations.
///
/// Manages FCM token lifecycle, notification permissions, and provides
/// streams for incoming messages in both foreground and background.
abstract class NotificationService {
  /// Initializes the notification service and requests permissions.
  Future<void> initialize();

  /// Returns the current FCM device token, or `null` if unavailable.
  Future<String?> getToken();

  /// Stream that emits a new token whenever FCM refreshes it.
  Stream<String> get onTokenRefresh;

  /// Stream of foreground messages (app is in the foreground).
  Stream<RemoteMessage> get onForegroundMessage;

  /// Returns the [RemoteMessage] that opened the app from a terminated state,
  /// or `null` if the app was not opened from a notification.
  Future<RemoteMessage?> getInitialMessage();

  /// Stream of messages that caused the app to open from background.
  Stream<RemoteMessage> get onMessageOpenedApp;

  /// Subscribes to a topic for targeted push notifications.
  Future<void> subscribeToTopic(String topic);

  /// Unsubscribes from a topic.
  Future<void> unsubscribeFromTopic(String topic);

  /// Disposes all stream subscriptions.
  void dispose();
}

/// Implementation of [NotificationService] using Firebase Cloud Messaging.
@LazySingleton(as: NotificationService)
class NotificationServiceImpl implements NotificationService {
  final FirebaseMessaging _messaging;

  final StreamController<RemoteMessage> _foregroundController =
      StreamController<RemoteMessage>.broadcast();

  StreamSubscription<RemoteMessage>? _foregroundSubscription;

  /// Creates a [NotificationServiceImpl].
  ///
  /// [messaging] is injected via the DI container.
  NotificationServiceImpl(this._messaging);

  @override
  Future<void> initialize() async {
    // Request notification permissions (iOS requires explicit request)
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    // Set foreground notification presentation options (iOS)
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // Listen for foreground messages
    _foregroundSubscription =
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _foregroundController.add(message);
    });
  }

  @override
  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  @override
  Stream<String> get onTokenRefresh => _messaging.onTokenRefresh;

  @override
  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundController.stream;

  @override
  Future<RemoteMessage?> getInitialMessage() {
    return _messaging.getInitialMessage();
  }

  @override
  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  @override
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  @override
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }

  @override
  void dispose() {
    _foregroundSubscription?.cancel();
    _foregroundController.close();
  }
}