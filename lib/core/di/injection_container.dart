/// Dependency Injection container for the Baladi application.
///
/// This file sets up all dependencies using a service locator pattern.
/// We use a simple service locator for dependency injection which is
/// lightweight and doesn't require external packages.
///
/// Architecture note: DI setup is part of the core layer and provides
/// dependencies to all other layers.
library;

import '../config/environment.dart';

// Domain - Repositories (interfaces)
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/repositories/points_repository.dart';
import '../../domain/repositories/store_repository.dart';

// Domain - Services
import '../../domain/services/order_processor.dart';
import '../../domain/services/points_calculator.dart';
import '../../domain/services/commission_calculator.dart';
import '../../domain/services/personal_commission_service.dart';

/// Service locator instance.
/// 
/// Use this to access registered dependencies throughout the app.
/// Example: `final authRepo = sl<AuthRepository>();`
final sl = ServiceLocator.instance;

/// Simple service locator implementation.
/// 
/// This is a lightweight alternative to get_it that doesn't require
/// external dependencies. For production, consider using get_it package.
class ServiceLocator {
  ServiceLocator._();
  
  static final ServiceLocator instance = ServiceLocator._();
  
  final Map<Type, dynamic> _singletons = {};
  final Map<Type, dynamic Function()> _factories = {};
  final Map<Type, dynamic Function()> _lazySingletons = {};
  
  /// Register a singleton instance.
  void registerSingleton<T>(T instance) {
    _singletons[T] = instance;
  }
  
  /// Register a factory (creates new instance each time).
  void registerFactory<T>(T Function() factory) {
    _factories[T] = factory;
  }
  
  /// Register a lazy singleton (created on first access).
  void registerLazySingleton<T>(T Function() factory) {
    _lazySingletons[T] = factory;
  }
  
  /// Get a registered dependency.
  T call<T>() => get<T>();
  
  /// Get a registered dependency.
  T get<T>() {
    // Check singletons first
    if (_singletons.containsKey(T)) {
      return _singletons[T] as T;
    }
    
    // Check lazy singletons
    if (_lazySingletons.containsKey(T)) {
      final instance = _lazySingletons[T]!();
      _singletons[T] = instance;
      _lazySingletons.remove(T);
      return instance as T;
    }
    
    // Check factories
    if (_factories.containsKey(T)) {
      return _factories[T]!() as T;
    }
    
    throw Exception('Dependency not registered: $T');
  }
  
  /// Check if a dependency is registered.
  bool isRegistered<T>() {
    return _singletons.containsKey(T) ||
           _lazySingletons.containsKey(T) ||
           _factories.containsKey(T);
  }
  
  /// Reset all registrations (useful for testing).
  void reset() {
    _singletons.clear();
    _factories.clear();
    _lazySingletons.clear();
  }
}

/// Initialize all dependencies.
/// 
/// Call this at app startup before running the app.
/// [environment] determines which configuration to use.
Future<void> initDependencies({
  Environment environment = Environment.dev,
}) async {
  // Initialize environment config
  EnvironmentConfig.initialize(environment);
  
  // Register environment config
  sl.registerSingleton<EnvironmentConfig>(EnvironmentConfig.current);
  
  // Register domain services
  _registerDomainServices();
  
  // Register data sources
  await _registerDataSources();
  
  // Register repositories
  _registerRepositories();
  
  // Register use cases
  _registerUseCases();
  
  // Register ViewModels
  _registerViewModels();
}

/// Register domain services.
void _registerDomainServices() {
  sl.registerLazySingleton<PointsCalculator>(() => PointsCalculator());
  sl.registerLazySingleton<CommissionCalculator>(() => CommissionCalculator());
  sl.registerLazySingleton<OrderProcessor>(() => OrderProcessor(
    pointsCalculator: sl<PointsCalculator>(),
    commissionCalculator: sl<CommissionCalculator>(),
  ));
  
  // Personal commission service for tracking separate personal commissions
  // (5% from store, 15% from delivery fee = 1.5 EGP per order)
  // These do NOT affect store, delivery, or platform revenues
  sl.registerLazySingleton<PersonalCommissionService>(() => PersonalCommissionService());
}

/// Register data sources.
/// 
/// Note: Data source implementations need to be created.
/// These are placeholder registrations using the interface types.
Future<void> _registerDataSources() async {
  // Local data sources will be implemented with SharedPreferences/Hive
  // Remote data sources will be implemented with Supabase
  
  // For now, we'll register placeholder implementations that will
  // be replaced with real implementations during development.
  
  // These registrations will be uncommented when implementations exist:
  // sl.registerLazySingleton<AuthLocalDataSource>(
  //   () => AuthLocalDataSourceImpl(),
  // );
  // sl.registerLazySingleton<AuthRemoteDataSource>(
  //   () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  // );
}

/// Register repositories.
void _registerRepositories() {
  // Note: Repository registrations require data source implementations.
  // These will be enabled when data sources are implemented.
  
  // For MVP, we can use mock implementations or direct Supabase calls.
  // Uncomment when data sources are ready:
  
  // sl.registerLazySingleton<AuthRepository>(
  //   () => AuthRepositoryImpl(
  //     localDataSource: sl<AuthLocalDataSource>(),
  //     remoteDataSource: sl<AuthRemoteDataSource>(),
  //   ),
  // );
  
  // sl.registerLazySingleton<OrderRepository>(
  //   () => OrderRepositoryImpl(
  //     localDataSource: sl<OrderLocalDataSource>(),
  //     remoteDataSource: sl<OrderRemoteDataSource>(),
  //   ),
  // );
}

/// Register use cases.
void _registerUseCases() {
  // Use cases will be registered when repositories are available.
  // Uncomment when repositories are ready:
  
  // sl.registerLazySingleton<LoginCustomer>(
  //   () => LoginCustomer(authRepository: sl<AuthRepository>()),
  // );
  
  // sl.registerLazySingleton<PlaceOrder>(
  //   () => PlaceOrder(
  //     orderRepository: sl<OrderRepository>(),
  //     pointsRepository: sl<PointsRepository>(),
  //     orderProcessor: sl<OrderProcessor>(),
  //     pointsCalculator: sl<PointsCalculator>(),
  //     commissionCalculator: sl<CommissionCalculator>(),
  //     personalCommissionService: sl<PersonalCommissionService>(),
  //   ),
  // );
  
  // sl.registerLazySingleton<UpdateOrderStatus>(
  //   () => UpdateOrderStatus(
  //     orderRepository: sl<OrderRepository>(),
  //     pointsRepository: sl<PointsRepository>(),
  //     orderProcessor: sl<OrderProcessor>(),
  //   ),
  // );
}

/// Register ViewModels.
/// 
/// ViewModels are registered as factories since each screen
/// should get a fresh instance.
void _registerViewModels() {
  // ViewModels will be registered when use cases are available.
  // Uncomment when use cases are ready:
  
  // sl.registerFactory<AuthViewModel>(
  //   () => AuthViewModel(loginCustomer: sl<LoginCustomer>()),
  // );
  
  // sl.registerFactory<OrderViewModel>(
  //   () => OrderViewModel(
  //     placeOrder: sl<PlaceOrder>(),
  //     updateOrderStatus: sl<UpdateOrderStatus>(),
  //     orderRepository: sl<OrderRepository>(),
  //   ),
  // );
}

/// Helper extension for cleaner syntax.
extension ServiceLocatorExtension on ServiceLocator {
  /// Shorthand for getting dependencies.
  T read<T>() => get<T>();
}

/// Initialize dependencies for testing with mocks.
/// 
/// This allows tests to provide mock implementations.
Future<void> initTestDependencies({
  AuthRepository? mockAuthRepository,
  OrderRepository? mockOrderRepository,
  PointsRepository? mockPointsRepository,
  StoreRepository? mockStoreRepository,
}) async {
  sl.reset();
  
  // Register domain services
  _registerDomainServices();
  
  // Register mocks if provided
  if (mockAuthRepository != null) {
    sl.registerSingleton<AuthRepository>(mockAuthRepository);
  }
  if (mockOrderRepository != null) {
    sl.registerSingleton<OrderRepository>(mockOrderRepository);
  }
  if (mockPointsRepository != null) {
    sl.registerSingleton<PointsRepository>(mockPointsRepository);
  }
  if (mockStoreRepository != null) {
    sl.registerSingleton<StoreRepository>(mockStoreRepository);
  }
}