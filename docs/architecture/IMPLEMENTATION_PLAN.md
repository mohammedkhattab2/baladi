# Baladi Flutter Implementation Plan

## MVVM + Clean Architecture Blueprint (Revised)

---

## 1. Project Structure Overview (Updated)

```
lib/
├── main.dart                          # App entry point
├── app.dart                           # MaterialApp configuration
├── injection_container.dart           # Dependency injection setup
│
├── core/                              # Shared infrastructure (NO business rules)
│   ├── error/
│   │   ├── exceptions.dart            # Custom exceptions
│   │   └── failures.dart              # Failure types for error handling
│   │
│   ├── result/
│   │   └── result.dart                # Either/Result wrapper
│   │
│   ├── usecase/
│   │   └── usecase.dart               # Base UseCase interface
│   │
│   ├── config/
│   │   ├── environment.dart           # Environment configuration (dev/prod)
│   │   └── app_config.dart            # App-wide configuration
│   │
│   └── utils/
│       ├── validators.dart            # Input validators
│       └── extensions.dart            # Dart extensions
│
├── domain/                            # Business logic (Pure Dart)
│   ├── entities/
│   │   ├── user.dart
│   │   ├── store.dart
│   │   ├── product.dart
│   │   ├── order.dart
│   │   ├── order_item.dart
│   │   ├── points.dart
│   │   ├── wallet.dart
│   │   └── settlement.dart
│   │
│   ├── enums/
│   │   ├── user_role.dart
│   │   ├── order_status.dart
│   │   └── payment_method.dart
│   │
│   ├── rules/                         # Business rules (MOVED FROM CORE)
│   │   ├── points_rules.dart          # Points calculation rules
│   │   ├── commission_rules.dart      # Commission calculation rules
│   │   ├── order_rules.dart           # Order validation rules
│   │   └── discount_rules.dart        # Discount application rules
│   │
│   ├── services/                      # Domain services for complex logic
│   │   ├── points_calculator.dart     # Points calculation service
│   │   ├── commission_calculator.dart # Commission calculation service
│   │   ├── order_validator.dart       # Order validation service
│   │   └── discount_applier.dart      # Discount application service
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── order_repository.dart
│   │   ├── product_repository.dart
│   │   ├── points_repository.dart
│   │   └── settlement_repository.dart
│   │
│   └── usecases/
│       ├── auth/
│       │   ├── login_customer.dart
│       │   ├── register_customer.dart
│       │   └── logout.dart
│       │
│       ├── order/
│       │   ├── place_order.dart       # Orchestrates domain services
│       │   ├── update_order_status.dart
│       │   ├── get_orders.dart
│       │   └── cancel_order.dart
│       │
│       ├── points/
│       │   ├── calculate_points.dart
│       │   ├── apply_points_discount.dart
│       │   └── get_points_balance.dart
│       │
│       └── settlement/
│           └── weekly_settlement.dart
│
├── data/                              # Data access layer
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── store_model.dart
│   │   ├── product_model.dart
│   │   ├── order_model.dart
│   │   ├── order_item_model.dart
│   │   ├── points_model.dart
│   │   └── settlement_model.dart
│   │
│   ├── datasources/
│   │   ├── local/
│   │   │   ├── auth_local_datasource.dart
│   │   │   ├── order_local_datasource.dart
│   │   │   ├── product_local_datasource.dart
│   │   │   └── cache_manager.dart
│   │   │
│   │   └── remote/
│   │       ├── auth_remote_datasource.dart
│   │       ├── order_remote_datasource.dart
│   │       ├── product_remote_datasource.dart
│   │       └── points_remote_datasource.dart
│   │
│   └── repositories/                  # Offline-first implementations
│       ├── auth_repository_impl.dart
│       ├── order_repository_impl.dart
│       ├── product_repository_impl.dart
│       ├── points_repository_impl.dart
│       └── settlement_repository_impl.dart
│
└── presentation/                      # UI Layer (Flutter)
    ├── core/
    │   ├── base_view_model.dart       # Base ViewModel class
    │   ├── ui_state.dart              # Generic UI state wrapper
    │   └── view_model_provider.dart   # ViewModel provider helper
    │
    ├── theme/
    │   ├── app_theme.dart
    │   ├── app_colors.dart
    │   └── app_text_styles.dart
    │
    ├── common/
    │   └── widgets/
    │       ├── loading_widget.dart
    │       ├── error_widget.dart
    │       └── empty_state_widget.dart
    │
    └── features/
        ├── auth/
        ├── customer/
        ├── store/
        ├── delivery/
        └── admin/
```

---

## 2. Key Architectural Adjustments

### 2.1 Business Rules in Domain Layer

All business rules MUST live in `domain/rules/`:

```dart
// lib/domain/rules/points_rules.dart

/// Business rules for points calculation.
/// Pure Dart - no external dependencies.
class PointsRules {
  /// Points earned per currency unit (100 EGP = 1 point)
  static const double pointsPerCurrencyUnit = 100.0;
  
  /// Point value in currency (1 point = 1 EGP)
  static const double pointValueInCurrency = 1.0;
  
  /// Referral bonus points
  static const int referralBonusPoints = 2;
  
  /// Minimum order amount to earn points
  static const double minimumOrderForPoints = 0.0;
  
  /// Calculate points earned from order amount
  static int calculatePointsEarned(double orderAmount) {
    if (orderAmount < minimumOrderForPoints) return 0;
    return (orderAmount / pointsPerCurrencyUnit).floor();
  }
  
  /// Calculate discount value from points
  static double calculateDiscountValue(int points) {
    return points * pointValueInCurrency;
  }
}
```

```dart
// lib/domain/rules/commission_rules.dart

/// Business rules for commission calculation.
class CommissionRules {
  /// Default store commission rate (10%)
  static const double defaultStoreCommissionRate = 0.10;
  
  /// Minimum platform commission (cannot go below 0)
  static const double minimumPlatformCommission = 0.0;
  
  /// Calculate store commission
  static double calculateStoreCommission(double subtotal, double rate) {
    return subtotal * rate;
  }
  
  /// Calculate platform commission after discount
  /// CRITICAL: Discount ONLY affects platform commission
  static double calculatePlatformCommission({
    required double storeCommission,
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    final commission = storeCommission - pointsDiscount - freeDeliveryCost;
    return commission < minimumPlatformCommission 
        ? minimumPlatformCommission 
        : commission;
  }
  
  /// Validate if discount can be applied
  static bool canApplyDiscount(double storeCommission, double discount) {
    return discount <= storeCommission;
  }
}
```

```dart
// lib/domain/rules/order_rules.dart

/// Business rules for order validation.
class OrderRules {
  /// Minimum items per order
  static const int minimumItemsPerOrder = 1;
  
  /// Default delivery fee
  static const double defaultDeliveryFee = 10.0;
  
  /// Validate order items
  static bool hasValidItems(List<dynamic> items) {
    return items.isNotEmpty && items.length >= minimumItemsPerOrder;
  }
  
  /// Validate minimum order amount
  static bool meetsMinimumOrder(double subtotal, double? minimumOrder) {
    if (minimumOrder == null) return true;
    return subtotal >= minimumOrder;
  }
}
```

### 2.2 Domain Services for Complex Logic

```dart
// lib/domain/services/points_calculator.dart

/// Domain service for points calculations.
/// Encapsulates all points-related business logic.
class PointsCalculator {
  /// Calculate points earned from an order
  int calculateEarnedPoints(double orderSubtotal) {
    return PointsRules.calculatePointsEarned(orderSubtotal);
  }
  
  /// Calculate discount value from points to use
  double calculateDiscountValue(int pointsToUse) {
    return PointsRules.calculateDiscountValue(pointsToUse);
  }
  
  /// Validate if points can be redeemed
  PointsValidationResult validatePointsRedemption({
    required int pointsToUse,
    required int availablePoints,
    required double platformCommission,
  }) {
    if (pointsToUse <= 0) {
      return PointsValidationResult.invalid('Points must be positive');
    }
    
    if (pointsToUse > availablePoints) {
      return PointsValidationResult.invalid('Insufficient points');
    }
    
    final discountValue = calculateDiscountValue(pointsToUse);
    if (discountValue > platformCommission) {
      final maxPoints = platformCommission.floor();
      return PointsValidationResult.invalid(
        'Maximum points allowed: $maxPoints',
      );
    }
    
    return PointsValidationResult.valid(discountValue);
  }
}

class PointsValidationResult {
  final bool isValid;
  final String? errorMessage;
  final double? discountValue;
  
  const PointsValidationResult._({
    required this.isValid,
    this.errorMessage,
    this.discountValue,
  });
  
  factory PointsValidationResult.valid(double discountValue) {
    return PointsValidationResult._(isValid: true, discountValue: discountValue);
  }
  
  factory PointsValidationResult.invalid(String message) {
    return PointsValidationResult._(isValid: false, errorMessage: message);
  }
}
```

```dart
// lib/domain/services/commission_calculator.dart

/// Domain service for commission calculations.
class CommissionCalculator {
  /// Calculate all commissions for an order
  CommissionBreakdown calculateCommissions({
    required double subtotal,
    required double storeCommissionRate,
    required double pointsDiscount,
    required double freeDeliveryCost,
  }) {
    final storeCommission = CommissionRules.calculateStoreCommission(
      subtotal,
      storeCommissionRate,
    );
    
    final platformCommission = CommissionRules.calculatePlatformCommission(
      storeCommission: storeCommission,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );
    
    final storeEarnings = subtotal - storeCommission;
    
    return CommissionBreakdown(
      subtotal: subtotal,
      storeCommission: storeCommission,
      platformCommission: platformCommission,
      storeEarnings: storeEarnings,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );
  }
}

class CommissionBreakdown {
  final double subtotal;
  final double storeCommission;
  final double platformCommission;
  final double storeEarnings;
  final double pointsDiscount;
  final double freeDeliveryCost;
  
  const CommissionBreakdown({
    required this.subtotal,
    required this.storeCommission,
    required this.platformCommission,
    required this.storeEarnings,
    required this.pointsDiscount,
    required this.freeDeliveryCost,
  });
}
```

### 2.3 Refactored PlaceOrder UseCase (Orchestrator Pattern)

```dart
// lib/domain/usecases/order/place_order.dart

/// Use case for placing a new order.
/// ORCHESTRATES domain services - does NOT contain calculations.
class PlaceOrder implements UseCase<Order, PlaceOrderParams> {
  final OrderRepository _orderRepository;
  final PointsRepository _pointsRepository;
  final PointsCalculator _pointsCalculator;
  final CommissionCalculator _commissionCalculator;
  final OrderValidator _orderValidator;

  PlaceOrder({
    required OrderRepository orderRepository,
    required PointsRepository pointsRepository,
    required PointsCalculator pointsCalculator,
    required CommissionCalculator commissionCalculator,
    required OrderValidator orderValidator,
  })  : _orderRepository = orderRepository,
        _pointsRepository = pointsRepository,
        _pointsCalculator = pointsCalculator,
        _commissionCalculator = commissionCalculator,
        _orderValidator = orderValidator;

  @override
  Future<Result<Order>> call(PlaceOrderParams params) async {
    // Step 1: Validate order using domain service
    final validationResult = _orderValidator.validateOrder(
      items: params.items,
      minimumOrder: params.minimumOrder,
    );
    
    if (!validationResult.isValid) {
      return Failure(validationResult.errorMessage!);
    }

    // Step 2: Calculate subtotal (delegated to validator which already computed it)
    final subtotal = validationResult.subtotal!;

    // Step 3: Validate points if being used
    double pointsDiscount = 0;
    if (params.pointsToUse > 0) {
      final balanceResult = await _pointsRepository.getBalance(params.customerId);
      if (balanceResult.isFailure) {
        return Failure(balanceResult.failure!.message);
      }
      
      // Calculate preliminary commission for validation
      final preliminaryCommission = CommissionRules.calculateStoreCommission(
        subtotal,
        params.storeCommissionRate,
      );
      
      final pointsValidation = _pointsCalculator.validatePointsRedemption(
        pointsToUse: params.pointsToUse,
        availablePoints: balanceResult.data!,
        platformCommission: preliminaryCommission,
      );
      
      if (!pointsValidation.isValid) {
        return Failure(pointsValidation.errorMessage!);
      }
      
      pointsDiscount = pointsValidation.discountValue!;
    }

    // Step 4: Calculate commissions using domain service
    final freeDeliveryCost = params.isFreeDelivery ? params.deliveryFee : 0.0;
    final commissions = _commissionCalculator.calculateCommissions(
      subtotal: subtotal,
      storeCommissionRate: params.storeCommissionRate,
      pointsDiscount: pointsDiscount,
      freeDeliveryCost: freeDeliveryCost,
    );

    // Step 5: Calculate delivery fee
    final deliveryFee = params.isFreeDelivery ? 0.0 : params.deliveryFee;

    // Step 6: Calculate total
    final total = subtotal + deliveryFee - pointsDiscount;

    // Step 7: Calculate points to earn using domain service
    final pointsEarned = _pointsCalculator.calculateEarnedPoints(subtotal);

    // Step 8: Create order via repository
    return _orderRepository.createOrder(
      customerId: params.customerId,
      storeId: params.storeId,
      items: params.items,
      subtotal: subtotal,
      deliveryFee: deliveryFee,
      isFreeDelivery: params.isFreeDelivery,
      pointsUsed: params.pointsToUse,
      pointsDiscount: pointsDiscount,
      total: total,
      storeCommission: commissions.storeCommission,
      platformCommission: commissions.platformCommission,
      pointsEarned: pointsEarned,
      deliveryAddress: params.deliveryAddress,
      deliveryLandmark: params.deliveryLandmark,
      customerNotes: params.customerNotes,
    );
  }
}
```

### 2.4 Offline-First Repository Strategy

```dart
// lib/data/repositories/order_repository_impl.dart

/// Offline-first implementation of OrderRepository.
/// Strategy: Local-first, remote sync.
class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDataSource _localDataSource;
  final OrderRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;
  final SyncManager _syncManager;

  OrderRepositoryImpl({
    required OrderLocalDataSource localDataSource,
    required OrderRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
    required SyncManager syncManager,
  })  : _localDataSource = localDataSource,
        _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo,
        _syncManager = syncManager;

  @override
  Future<Result<Order>> createOrder({
    required String customerId,
    required String storeId,
    required List<OrderItemInput> items,
    required double subtotal,
    required double deliveryFee,
    required bool isFreeDelivery,
    required int pointsUsed,
    required double pointsDiscount,
    required double total,
    required double storeCommission,
    required double platformCommission,
    required int pointsEarned,
    required String deliveryAddress,
    String? deliveryLandmark,
    String? customerNotes,
  }) async {
    // Step 1: Always save locally first (offline-first)
    final localOrder = OrderModel(
      id: _generateLocalId(),
      customerId: customerId,
      storeId: storeId,
      // ... all fields
      syncStatus: SyncStatus.pending,
      createdAt: DateTime.now(),
    );
    
    await _localDataSource.saveOrder(localOrder);
    
    // Step 2: Try to sync with remote if online
    if (await _networkInfo.isConnected) {
      try {
        final remoteResult = await _remoteDataSource.createOrder(localOrder);
        
        if (remoteResult.isSuccess) {
          // Update local with server-generated ID and mark as synced
          final syncedOrder = localOrder.copyWith(
            id: remoteResult.data!.id,
            syncStatus: SyncStatus.synced,
          );
          await _localDataSource.updateOrder(syncedOrder);
          return Success(syncedOrder.toEntity());
        }
      } catch (e) {
        // Failed to sync - will be synced later
        _syncManager.scheduleSync(SyncTask.order(localOrder.id));
      }
    } else {
      // Offline - schedule sync for later
      _syncManager.scheduleSync(SyncTask.order(localOrder.id));
    }
    
    return Success(localOrder.toEntity());
  }

  @override
  Future<Result<List<Order>>> getOrders(String userId) async {
    // Always return local data first
    final localOrders = await _localDataSource.getOrders(userId);
    
    // Try to refresh from remote if online
    if (await _networkInfo.isConnected) {
      try {
        final remoteResult = await _remoteDataSource.getOrders(userId);
        if (remoteResult.isSuccess) {
          // Merge and update local cache
          await _localDataSource.saveOrders(remoteResult.data!);
          return Success(remoteResult.data!.map((m) => m.toEntity()).toList());
        }
      } catch (e) {
        // Failed to fetch remote - return cached data
      }
    }
    
    return Success(localOrders.map((m) => m.toEntity()).toList());
  }

  String _generateLocalId() => 'local_${DateTime.now().millisecondsSinceEpoch}';
}

enum SyncStatus { pending, syncing, synced, failed }
```

### 2.5 Environment Configuration

```dart
// lib/core/config/environment.dart

/// Environment configuration for dependency injection.
enum Environment { dev, staging, prod }

class EnvironmentConfig {
  final Environment environment;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool useMockData;
  final Duration cacheTimeout;
  final Duration syncInterval;
  
  const EnvironmentConfig._({
    required this.environment,
    required this.apiBaseUrl,
    required this.enableLogging,
    required this.useMockData,
    required this.cacheTimeout,
    required this.syncInterval,
  });
  
  static const EnvironmentConfig dev = EnvironmentConfig._(
    environment: Environment.dev,
    apiBaseUrl: 'http://localhost:3000/api',
    enableLogging: true,
    useMockData: true,
    cacheTimeout: Duration(minutes: 5),
    syncInterval: Duration(seconds: 30),
  );
  
  static const EnvironmentConfig staging = EnvironmentConfig._(
    environment: Environment.staging,
    apiBaseUrl: 'https://staging-api.baladi.app/api',
    enableLogging: true,
    useMockData: false,
    cacheTimeout: Duration(minutes: 10),
    syncInterval: Duration(minutes: 1),
  );
  
  static const EnvironmentConfig prod = EnvironmentConfig._(
    environment: Environment.prod,
    apiBaseUrl: 'https://api.baladi.app/api',
    enableLogging: false,
    useMockData: false,
    cacheTimeout: Duration(minutes: 15),
    syncInterval: Duration(minutes: 2),
  );
  
  static EnvironmentConfig current = dev;
  
  static void initialize(Environment env) {
    current = switch (env) {
      Environment.dev => dev,
      Environment.staging => staging,
      Environment.prod => prod,
    };
  }
}
```

```dart
// lib/injection_container.dart

/// Dependency injection container with environment support.
final GetIt sl = GetIt.instance;

Future<void> initializeDependencies(Environment environment) async {
  // Initialize environment
  EnvironmentConfig.initialize(environment);
  final config = EnvironmentConfig.current;
  
  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());
  sl.registerLazySingleton<SyncManager>(() => SyncManagerImpl());
  
  // Domain Services
  sl.registerLazySingleton<PointsCalculator>(() => PointsCalculator());
  sl.registerLazySingleton<CommissionCalculator>(() => CommissionCalculator());
  sl.registerLazySingleton<OrderValidator>(() => OrderValidator());
  
  // Data Sources
  if (config.useMockData) {
    sl.registerLazySingleton<OrderRemoteDataSource>(
      () => MockOrderRemoteDataSource(),
    );
  } else {
    sl.registerLazySingleton<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(
        baseUrl: config.apiBaseUrl,
        enableLogging: config.enableLogging,
      ),
    );
  }
  
  sl.registerLazySingleton<OrderLocalDataSource>(
    () => OrderLocalDataSourceImpl(),
  );
  
  // Repositories (Offline-First)
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      networkInfo: sl(),
      syncManager: sl(),
    ),
  );
  
  // Use Cases
  sl.registerLazySingleton<PlaceOrder>(
    () => PlaceOrder(
      orderRepository: sl(),
      pointsRepository: sl(),
      pointsCalculator: sl(),
      commissionCalculator: sl(),
      orderValidator: sl(),
    ),
  );
  
  // ViewModels
  sl.registerFactory<CartViewModel>(
    () => CartViewModel(
      placeOrder: sl(),
      getPointsBalance: sl(),
    ),
  );
}
```

### 2.6 Clean ViewModel (No Business Calculations)

```dart
// lib/presentation/features/customer/viewmodels/cart_viewmodel.dart

/// ViewModel for the cart screen.
/// NO business calculations - delegates everything to use cases.
class CartViewModel extends BaseViewModel<CartState> {
  final PlaceOrder _placeOrder;
  final GetPointsBalance _getPointsBalance;
  final GetCartSummary _getCartSummary; // New use case for summary

  CartViewModel({
    required PlaceOrder placeOrder,
    required GetPointsBalance getPointsBalance,
    required GetCartSummary getCartSummary,
  })  : _placeOrder = placeOrder,
        _getPointsBalance = getPointsBalance,
        _getCartSummary = getCartSummary;

  final List<CartItem> _items = [];
  CartSummary? _summary;
  int _availablePoints = 0;
  int _pointsToUse = 0;

  List<CartItem> get items => List.unmodifiable(_items);
  CartSummary? get summary => _summary;
  int get availablePoints => _availablePoints;
  int get pointsToUse => _pointsToUse;

  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      _items.add(item);
    }
    _recalculateSummary();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.productId == productId);
    _recalculateSummary();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
      _recalculateSummary();
    }
  }

  /// Recalculate summary using domain use case - NOT in ViewModel
  Future<void> _recalculateSummary() async {
    if (_items.isEmpty) {
      _summary = null;
      notifyListeners();
      return;
    }

    final result = await _getCartSummary(GetCartSummaryParams(
      items: _items,
      pointsToUse: _pointsToUse,
    ));

    result.fold(
      onSuccess: (summary) {
        _summary = summary;
        notifyListeners();
      },
      onFailure: (failure) {
        setError(failure.message);
      },
    );
  }

  Future<void> loadAvailablePoints(String customerId) async {
    final result = await _getPointsBalance(
      GetPointsBalanceParams(customerId: customerId),
    );
    result.fold(
      onSuccess: (balance) {
        _availablePoints = balance;
        notifyListeners();
      },
      onFailure: (_) {
        _availablePoints = 0;
        notifyListeners();
      },
    );
  }

  Future<void> setPointsToUse(int points) async {
    _pointsToUse = points;
    await _recalculateSummary();
  }

  Future<void> placeOrder({
    required String customerId,
    required String storeId,
    required String deliveryAddress,
    String? deliveryLandmark,
    String? customerNotes,
    required double deliveryFee,
    bool isFreeDelivery = false,
  }) async {
    if (_items.isEmpty) {
      setError('Cart is empty');
      return;
    }

    setLoading();

    final result = await _placeOrder(PlaceOrderParams(
      customerId: customerId,
      storeId: storeId,
      items: _items.map((item) => OrderItemInput(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity,
      )).toList(),
      deliveryAddress: deliveryAddress,
      deliveryLandmark: deliveryLandmark,
      customerNotes: customerNotes,
      pointsToUse: _pointsToUse,
      deliveryFee: deliveryFee,
      isFreeDelivery: isFreeDelivery,
    ));

    result.fold(
      onSuccess: (order) {
        _items.clear();
        _pointsToUse = 0;
        _summary = null;
        setData(CartState.orderPlaced(order));
      },
      onFailure: (failure) {
        setError(failure.message);
      },
    );
  }

  void clearCart() {
    _items.clear();
    _pointsToUse = 0;
    _summary = null;
    setInitial();
  }
}
```

---

## 3. Updated Implementation Order

### Phase 1: Core Foundation
1. `core/error/exceptions.dart`
2. `core/error/failures.dart`
3. `core/result/result.dart`
4. `core/usecase/usecase.dart`
5. `core/config/environment.dart`

### Phase 2: Domain Layer (Pure Dart)
1. `domain/enums/` - All enums
2. `domain/entities/` - All entities
3. `domain/rules/` - Business rules (points, commission, order, discount)
4. `domain/services/` - Domain services (calculators, validators)
5. `domain/repositories/` - Repository interfaces
6. `domain/usecases/` - Use cases (orchestrating services)

### Phase 3: Data Layer (Offline-First)
1. `data/models/` - DTOs with fromJson/toJson
2. `data/datasources/local/` - Local data sources
3. `data/datasources/remote/` - Remote data sources
4. `data/repositories/` - Offline-first repository implementations

### Phase 4: Presentation Layer
1. `presentation/core/` - Base classes
2. `presentation/theme/` - Theme configuration
3. `presentation/common/` - Shared widgets
4. `presentation/features/` - Feature modules (ViewModels with NO calculations)

### Phase 5: Integration
1. `injection_container.dart` - Environment-aware DI setup
2. `app.dart` - App configuration
3. `main.dart` - Entry point with environment selection

---

## 4. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # State Management (MVVM)
  provider: ^6.1.1
  
  # Dependency Injection
  get_it: ^7.6.7
  
  # Networking
  http: ^1.2.0
  connectivity_plus: ^5.0.2
  
  # Local Storage
  shared_preferences: ^2.2.2
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utilities
  uuid: ^4.3.3
  intl: ^0.19.0
  
  # Firebase (Push Notifications)
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.10

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4
  build_runner: ^2.4.8
  hive_generator: ^2.0.1
```

---

## 5. Summary of Adjustments Made

| Original | Adjusted |
|----------|----------|
| Business rules in `core/constants/` | Moved to `domain/rules/` |
| Calculations in ViewModels | Delegated to use cases and domain services |
| PlaceOrder does all calculations | PlaceOrder orchestrates domain services |
| No offline strategy | Explicit offline-first (local-first, remote sync) |
| Single environment | Environment config (dev/staging/prod) |

---

*Ready for implementation in Code mode.*