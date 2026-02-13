// Baladi - Entry point for the application.
//
// Initializes all core services (Firebase, Hive, DI container,
// environment config) before launching the root widget.

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/config/environment.dart';
import 'core/di/injection.dart';

/// Application entry point.
///
/// Initialization order:
/// 1. Flutter bindings
/// 2. System UI orientation lock (portrait only)
/// 3. Hive local database
/// 4. Firebase services
/// 5. Environment configuration (dev for now)
/// 6. GetIt dependency injection
/// 7. Launch [BaladiApp]
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait orientation for consistent village-friendly UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  // Initialize Hive for local caching
  await Hive.initFlutter();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Set environment (default to dev for MVP)
  EnvironmentConfig.initialize(Environment.dev);

  // Register all dependencies via Injectable + GetIt
  await configureDependencies();

  runApp(const BaladiApp());
}
