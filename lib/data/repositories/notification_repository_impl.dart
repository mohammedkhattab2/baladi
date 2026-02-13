// Data - Notification repository implementation.
//
// Implements the NotificationRepository contract using remote datasource
// and CacheService for local notification caching.

import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../core/constants/storage_keys.dart';
import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../core/services/cache_service.dart';
import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/remote/notification_remote_datasource.dart';
import '../models/notification_model.dart';

/// Implementation of [NotificationRepository].
@LazySingleton(as: NotificationRepository)
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;
  final CacheService _cacheService;
  final NetworkInfo _networkInfo;

  /// Creates a [NotificationRepositoryImpl].
  NotificationRepositoryImpl({
    required NotificationRemoteDatasource remoteDatasource,
    required CacheService cacheService,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _cacheService = cacheService,
        _networkInfo = networkInfo;

  /// Cache key for the notifications list.
  static const String _cacheKey = 'notifications_list';

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      // Return cached notifications as fallback when offline.
      final cached = await getCachedNotifications();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final notifications = await _remoteDatasource.getNotifications(
        page: page,
        perPage: perPage,
      );
      // Cache first page results for offline access.
      if (page == 1) {
        await _cacheNotificationModels(notifications);
      }
      return notifications;
    });
  }

  @override
  Future<Result<void>> markAsRead(String notificationId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.markAsRead(notificationId));
  }

  @override
  Future<Result<void>> markAllAsRead() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.markAllAsRead());
  }

  @override
  Future<Result<int>> getUnreadCount() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getUnreadCount());
  }

  @override
  Future<List<AppNotification>> getCachedNotifications() async {
    final value = _cacheService.get(StorageKeys.notificationsBox, _cacheKey);
    if (value == null) return [];
    try {
      final list = jsonDecode(value as String) as List<dynamic>;
      return list
          .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  @override
  Future<void> cacheNotifications(
    List<AppNotification> notifications,
  ) async {
    final models = notifications
        .map((n) => n is NotificationModel
            ? n
            : NotificationModel.fromEntity(n))
        .toList();
    await _cacheNotificationModels(models);
  }

  @override
  Future<void> clearCache() async {
    await _cacheService.clearBox(StorageKeys.notificationsBox);
  }

  /// Internal helper to cache a list of [NotificationModel].
  Future<void> _cacheNotificationModels(
    List<NotificationModel> notifications,
  ) async {
    final jsonList = notifications.map((n) => n.toJson()).toList();
    final jsonString = jsonEncode(jsonList);
    await _cacheService.put(
      StorageKeys.notificationsBox,
      _cacheKey,
      jsonString,
    );
  }
}