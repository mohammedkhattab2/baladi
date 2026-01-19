/// Domain layer barrel file.
///
/// This file exports all domain layer components for easy importing.
/// Import with: `import 'package:baladi/domain/domain.dart';`
library;

// Enums
export 'enums/enums.dart';

// Entities
export 'entities/user.dart';
export 'entities/store.dart';
export 'entities/product.dart';
export 'entities/order.dart';
export 'entities/order_item.dart';
export 'entities/points.dart';
export 'entities/wallet.dart';
export 'entities/settlement.dart';

// Business Rules
export 'rules/points_rules.dart';
export 'rules/commission_rules.dart';
export 'rules/order_rules.dart';

// Domain Services
export 'services/points_calculator.dart';
export 'services/commission_calculator.dart';
export 'services/order_processor.dart';
export 'services/personal_commission_service.dart';

// Repository Interfaces
export 'repositories/auth_repository.dart';
export 'repositories/order_repository.dart';
export 'repositories/points_repository.dart' hide PointsTransactionType, PointsTransaction;
export 'repositories/store_repository.dart';
export 'repositories/settlement_repository.dart';

// Use Cases
export 'usecases/place_order.dart';
export 'usecases/update_order_status.dart';
export 'usecases/login_customer.dart';