// Core - Injectable + GetIt dependency injection setup.
//
// Entry point for the DI container. Uses @InjectableInit to
// auto-generate registration code in injection.config.dart.

import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import '../services/cache_service.dart';
import 'injection.config.dart';

/// Global service locator instance.
final getIt = GetIt.instance;

/// Initializes all dependencies via Injectable code generation.
///
/// Must be called once at app startup, after [EnvironmentConfig.initialize]
/// and [Firebase.initializeApp] have completed.
@InjectableInit()
Future<void> configureDependencies() async {
  getIt.init();

  // Post-registration async initialization: open Hive boxes
  await getIt<CacheService>().initialize();
}

/// Resets the service locator. Useful for testing.
Future<void> resetDependencies() async {
  await getIt.reset();
}