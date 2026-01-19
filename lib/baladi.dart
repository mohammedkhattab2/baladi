/// Baladi - Daily needs delivery app for small communities.
///
/// This is the main barrel file that exports all layers.
/// Import with: `import 'package:baladi/baladi.dart';`
///
/// For specific layers, use:
/// - `import 'package:baladi/core/core.dart';`
/// - `import 'package:baladi/domain/domain.dart';`
/// - `import 'package:baladi/data/data.dart';`
/// - `import 'package:baladi/presentation/presentation.dart';`
library;

// Core Layer
export 'core/core.dart';

// Domain Layer
export 'domain/domain.dart';

// Data Layer
export 'data/data.dart';

// Presentation Layer
export 'presentation/presentation.dart';

// Dependency Injection
export 'core/di/injection_container.dart';