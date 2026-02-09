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
    ├── base/
    │   ├── base_state.dart            # Base immutable state with status enum
    │   └── base_cubit.dart            # Base Cubit class with convenience emitters
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
        │   ├── cubits/
        │   │   ├── auth_cubit.dart
        │   │   └── auth_state.dart
        │   ├── screens/
        │   └── widgets/
        ├── customer/
        │   ├── cubits/
        │   ├── screens/
        │   └── widgets/
        ├── store/
        │   ├── cubits/
        │   ├── screens/
        │   └── widgets/
        ├── delivery/
        │   ├── cubits/
        │   ├── screens/
        │   └── widgets/
        └── admin/
            ├── cubits/
            ├── screens/
            └── widgets/
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
  
  // Cubits (registered as factory — new instance per screen)
  sl.registerFactory<CartCubit>(
    () => CartCubit(
      placeOrder: sl(),
      getPointsBalance: sl(),
      getCartSummary: sl(),
    ),
  );
}
```

### 2.6 Clean Cubit (No Business Calculations)

```dart
// lib/presentation/features/customer/cubits/cart_state.dart

/// Immutable state for the cart screen.
class CartState extends Equatable {
  final BaseStatus status;
  final String? errorMessage;
  final List<CartItem> items;
  final CartSummary? summary;
  final int availablePoints;
  final int pointsToUse;
  final Order? placedOrder;

  const CartState({
    this.status = BaseStatus.initial,
    this.errorMessage,
    this.items = const [],
    this.summary,
    this.availablePoints = 0,
    this.pointsToUse = 0,
    this.placedOrder,
  });

  const CartState.initial() : this();

  CartState copyWith({
    BaseStatus? status,
    String? errorMessage,
    List<CartItem>? items,
    CartSummary? summary,
    int? availablePoints,
    int? pointsToUse,
    Order? placedOrder,
    bool clearError = false,
    bool clearSummary = false,
    bool clearOrder = false,
  }) {
    return CartState(
      status: status ?? this.status,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      items: items ?? this.items,
      summary: clearSummary ? null : summary ?? this.summary,
      availablePoints: availablePoints ?? this.availablePoints,
      pointsToUse: pointsToUse ?? this.pointsToUse,
      placedOrder: clearOrder ? null : placedOrder ?? this.placedOrder,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, items, summary, availablePoints, pointsToUse, placedOrder];
}
```

```dart
// lib/presentation/features/customer/cubits/cart_cubit.dart

/// Cubit for the cart screen.
/// NO business calculations — delegates everything to use cases.
/// Emits immutable CartState on every change.
class CartCubit extends Cubit<CartState> {
  final PlaceOrder _placeOrder;
  final GetPointsBalance _getPointsBalance;
  final GetCartSummary _getCartSummary;

  CartCubit({
    required PlaceOrder placeOrder,
    required GetPointsBalance getPointsBalance,
    required GetCartSummary getCartSummary,
  })  : _placeOrder = placeOrder,
        _getPointsBalance = getPointsBalance,
        _getCartSummary = getCartSummary,
        super(const CartState.initial());

  void addItem(CartItem item) {
    final items = List<CartItem>.from(state.items);
    final existingIndex = items.indexWhere((i) => i.productId == item.productId);
    if (existingIndex >= 0) {
      items[existingIndex] = items[existingIndex].copyWith(
        quantity: items[existingIndex].quantity + item.quantity,
      );
    } else {
      items.add(item);
    }
    emit(state.copyWith(items: items));
    _recalculateSummary(items);
  }

  void removeItem(String productId) {
    final items = state.items.where((item) => item.productId != productId).toList();
    emit(state.copyWith(items: items));
    _recalculateSummary(items);
  }

  void updateQuantity(String productId, int quantity) {
    final items = List<CartItem>.from(state.items);
    final index = items.indexWhere((item) => item.productId == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: quantity);
      }
      emit(state.copyWith(items: items));
      _recalculateSummary(items);
    }
  }

  /// Recalculate summary using domain use case — NOT in Cubit
  Future<void> _recalculateSummary(List<CartItem> items) async {
    if (items.isEmpty) {
      emit(state.copyWith(clearSummary: true));
      return;
    }

    final result = await _getCartSummary(GetCartSummaryParams(
      items: items,
      pointsToUse: state.pointsToUse,
    ));

    result.fold(
      onSuccess: (summary) => emit(state.copyWith(summary: summary)),
      onFailure: (failure) => emit(state.copyWith(
        status: BaseStatus.failure,
        errorMessage: failure.message,
      )),
    );
  }

  Future<void> loadAvailablePoints(String customerId) async {
    final result = await _getPointsBalance(
      GetPointsBalanceParams(customerId: customerId),
    );
    result.fold(
      onSuccess: (balance) => emit(state.copyWith(availablePoints: balance)),
      onFailure: (_) => emit(state.copyWith(availablePoints: 0)),
    );
  }

  Future<void> setPointsToUse(int points) async {
    emit(state.copyWith(pointsToUse: points));
    await _recalculateSummary(state.items);
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
    if (state.items.isEmpty) {
      emit(state.copyWith(status: BaseStatus.failure, errorMessage: 'Cart is empty'));
      return;
    }

    emit(state.copyWith(status: BaseStatus.loading));

    final result = await _placeOrder(PlaceOrderParams(
      customerId: customerId,
      storeId: storeId,
      items: state.items.map((item) => OrderItemInput(
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity,
      )).toList(),
      deliveryAddress: deliveryAddress,
      deliveryLandmark: deliveryLandmark,
      customerNotes: customerNotes,
      pointsToUse: state.pointsToUse,
      deliveryFee: deliveryFee,
      isFreeDelivery: isFreeDelivery,
    ));

    result.fold(
      onSuccess: (order) => emit(CartState(
        status: BaseStatus.success,
        placedOrder: order,
      )),
      onFailure: (failure) => emit(state.copyWith(
        status: BaseStatus.failure,
        errorMessage: failure.message,
      )),
    );
  }

  void clearCart() {
    emit(const CartState.initial());
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
1. `presentation/base/` - BaseCubit, BaseState with status enum
2. `presentation/theme/` - Theme configuration
3. `presentation/common/` - Shared widgets
4. `presentation/features/` - Feature modules (Cubits with immutable states, NO calculations)

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
  
  # State Management (Cubit / BLoC)
  flutter_bloc: ^9.1.0
  
  # Dependency Injection
  get_it: ^8.0.3
  
  # Networking
  http: ^1.2.2
  connectivity_plus: ^6.1.1
  
  # Local Storage
  shared_preferences: ^2.3.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  
  # Utilities
  uuid: ^4.5.1
  intl: ^0.19.0
  equatable: ^2.0.5
  
  # Firebase (Push Notifications)
  firebase_core: ^3.8.0
  firebase_messaging: ^15.1.5

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^6.0.0
  mocktail: ^1.0.4
  bloc_test: ^9.1.7
  build_runner: ^2.4.13
  hive_generator: ^2.0.1
```

---

## 5. Summary of Adjustments Made

| Original | Adjusted |
|----------|----------|
| Business rules in `core/constants/` | Moved to `domain/rules/` |
| Provider + ChangeNotifier ViewModels | Cubit + immutable State classes (flutter_bloc) |
| Calculations in ViewModels | Delegated to use cases and domain services |
| PlaceOrder does all calculations | PlaceOrder orchestrates domain services |
| No offline strategy | Explicit offline-first (local-first, remote sync) |
| Single environment | Environment config (dev/staging/prod) |
| `notifyListeners()` for UI updates | `emit(newState)` with Equatable-based rebuilds |
| Consumer / Provider.of in widgets | BlocBuilder / BlocListener in widgets |
| ChangeNotifierProvider DI | BlocProvider + GetIt factory registration |

---

*Ready for implementation in Code mode.*