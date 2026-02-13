// Root widget for the Baladi application.
//
// Configures MaterialApp.router with GoRouter, Material 3 theme,
// RTL directionality, and Arabic locale support.

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/config/app_config.dart';
import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// The root widget of the Baladi application.
///
/// Sets up:
/// - [MaterialApp.router] with [GoRouter] from [AppRouter]
/// - Material 3 theme via [AppTheme]
/// - Arabic locale with RTL text direction
/// - Flutter localization delegates
class BaladiApp extends StatelessWidget {
  const BaladiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = getIt<AppRouter>();

    return MaterialApp.router(
      // ─── App Identity ─────────────────────────────────────────
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,

      // ─── Theme ────────────────────────────────────────────────
      theme: AppTheme.light,

      // ─── Routing ──────────────────────────────────────────────
      routerConfig: appRouter.router,

      // ─── Localization ─────────────────────────────────────────
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [
        Locale('ar', 'EG'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ─── Builder ──────────────────────────────────────────────
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}