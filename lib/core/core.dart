/// Core module exports.
///
/// This file exports all core module components for easy importing
/// throughout the application.
///
/// Usage:
/// ```dart
/// import 'package:baladi/core/core.dart';
/// ```
library;

// Error handling
export 'error/exceptions.dart';
export 'error/failures.dart';

// Result type
// Hide Failure class from result.dart as it conflicts with failures.dart
// Use ResultFailure when you need the Result wrapper's failure type
export 'result/result.dart' hide Failure;

// Use case base
export 'usecase/usecase.dart';

// Configuration
export 'config/environment.dart';

// Utilities
export 'utils/validators.dart';
export 'utils/extensions.dart';