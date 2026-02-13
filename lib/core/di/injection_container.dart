// Core - Backward-compatible DI entry point.
//
// Re-exports the Injectable-based [getIt] instance as [sl] and
// [configureDependencies] as [initializeDependencies] so that
// existing imports continue to work without changes.

export 'injection.dart' show getIt, configureDependencies, resetDependencies;

import 'injection.dart';

/// Backward-compatible alias for [getIt].
///
/// Existing code that uses `sl<T>()` will continue to work.
final sl = getIt;

/// Backward-compatible alias for [configureDependencies].
///
/// Existing code that calls `initializeDependencies()` will continue to work.
Future<void> initializeDependencies() => configureDependencies();