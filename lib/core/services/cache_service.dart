// Core - Hive-based cache service for offline data storage.
//
// Provides typed access to Hive boxes for caching orders, products,
// cart data, notifications, and user data locally on the device.

import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';

import '../constants/storage_keys.dart';

/// Abstraction for local cache operations using Hive boxes.
///
/// Used for offline-first data caching. Each entity type has its own
/// named Hive box for isolation and independent cache management.
abstract class CacheService {
  /// Initializes Hive and opens all required boxes.
  Future<void> initialize();

  /// Stores a value in the specified box.
  Future<void> put(String boxName, String key, dynamic value);

  /// Retrieves a value from the specified box.
  dynamic get(String boxName, String key);

  /// Retrieves all values from the specified box.
  List<dynamic> getAll(String boxName);

  /// Deletes a value from the specified box.
  Future<void> delete(String boxName, String key);

  /// Clears all values in the specified box.
  Future<void> clearBox(String boxName);

  /// Clears all boxes (full cache reset).
  Future<void> clearAll();

  /// Checks if a key exists in the specified box.
  bool containsKey(String boxName, String key);

  /// Returns the number of entries in the specified box.
  int count(String boxName);

  /// Closes all boxes and cleans up resources.
  Future<void> dispose();
}

/// Implementation of [CacheService] using Hive.
@LazySingleton(as: CacheService)
class CacheServiceImpl implements CacheService {
  final Map<String, Box<dynamic>> _boxes = {};

  /// All box names that should be opened on initialization.
  static const List<String> _boxNames = [
    StorageKeys.ordersBox,
    StorageKeys.productsBox,
    StorageKeys.cartBox,
    StorageKeys.notificationsBox,
    StorageKeys.userBox,
  ];

  @override
  Future<void> initialize() async {
    await Hive.initFlutter();
    for (final name in _boxNames) {
      _boxes[name] = await Hive.openBox<dynamic>(name);
    }
  }

  Box<dynamic> _getBox(String boxName) {
    final box = _boxes[boxName];
    if (box == null || !box.isOpen) {
      throw StateError(
        'Hive box "$boxName" is not open. '
        'Call CacheService.initialize() first.',
      );
    }
    return box;
  }

  @override
  Future<void> put(String boxName, String key, dynamic value) async {
    final box = _getBox(boxName);
    await box.put(key, value);
  }

  @override
  dynamic get(String boxName, String key) {
    final box = _getBox(boxName);
    return box.get(key);
  }

  @override
  List<dynamic> getAll(String boxName) {
    final box = _getBox(boxName);
    return box.values.toList();
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clearBox(String boxName) async {
    final box = _getBox(boxName);
    await box.clear();
  }

  @override
  Future<void> clearAll() async {
    for (final box in _boxes.values) {
      if (box.isOpen) {
        await box.clear();
      }
    }
  }

  @override
  bool containsKey(String boxName, String key) {
    final box = _getBox(boxName);
    return box.containsKey(key);
  }

  @override
  int count(String boxName) {
    final box = _getBox(boxName);
    return box.length;
  }

  @override
  Future<void> dispose() async {
    for (final box in _boxes.values) {
      if (box.isOpen) {
        await box.close();
      }
    }
    _boxes.clear();
  }
}