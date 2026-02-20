// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:baladi/core/di/register_module.dart' as _i697;
import 'package:baladi/core/network/api_client.dart' as _i547;
import 'package:baladi/core/network/network_info.dart' as _i725;
import 'package:baladi/core/router/app_router.dart' as _i108;
import 'package:baladi/core/services/cache_service.dart' as _i659;
import 'package:baladi/core/services/local_storage_service.dart' as _i154;
import 'package:baladi/core/services/notification_service.dart' as _i325;
import 'package:baladi/core/services/secure_storage_service.dart' as _i253;
import 'package:baladi/data/datasources/local/auth_local_datasource.dart'
    as _i779;
import 'package:baladi/data/datasources/local/cart_local_datasource.dart'
    as _i373;
import 'package:baladi/data/datasources/local/category_local_datasource.dart'
    as _i894;
import 'package:baladi/data/datasources/local/order_local_datasource.dart'
    as _i867;
import 'package:baladi/data/datasources/local/product_local_datasource.dart'
    as _i731;
import 'package:baladi/data/datasources/remote/ad_remote_datasource.dart'
    as _i398;
import 'package:baladi/data/datasources/remote/admin_remote_datasource.dart'
    as _i1073;
import 'package:baladi/data/datasources/remote/auth_remote_datasource.dart'
    as _i465;
import 'package:baladi/data/datasources/remote/category_remote_datasource.dart'
    as _i537;
import 'package:baladi/data/datasources/remote/customer_remote_datasource.dart'
    as _i71;
import 'package:baladi/data/datasources/remote/notification_remote_datasource.dart'
    as _i328;
import 'package:baladi/data/datasources/remote/order_remote_datasource.dart'
    as _i952;
import 'package:baladi/data/datasources/remote/points_remote_datasource.dart'
    as _i350;
import 'package:baladi/data/datasources/remote/product_remote_datasource.dart'
    as _i751;
import 'package:baladi/data/datasources/remote/rider_remote_datasource.dart'
    as _i4;
import 'package:baladi/data/datasources/remote/settlement_remote_datasource.dart'
    as _i928;
import 'package:baladi/data/datasources/remote/shop_remote_datasource.dart'
    as _i215;
import 'package:baladi/data/repositories/ad_repository_impl.dart' as _i451;
import 'package:baladi/data/repositories/admin_repository_impl.dart' as _i179;
import 'package:baladi/data/repositories/auth_repository_impl.dart' as _i875;
import 'package:baladi/data/repositories/category_repository_impl.dart' as _i54;
import 'package:baladi/data/repositories/customer_repository_impl.dart'
    as _i398;
import 'package:baladi/data/repositories/notification_repository_impl.dart'
    as _i1018;
import 'package:baladi/data/repositories/order_repository_impl.dart' as _i28;
import 'package:baladi/data/repositories/points_repository_impl.dart' as _i928;
import 'package:baladi/data/repositories/product_repository_impl.dart' as _i465;
import 'package:baladi/data/repositories/rider_repository_impl.dart' as _i1014;
import 'package:baladi/data/repositories/settlement_repository_impl.dart'
    as _i366;
import 'package:baladi/data/repositories/shop_repository_impl.dart' as _i984;
import 'package:baladi/domain/repositories/ad_repository.dart' as _i524;
import 'package:baladi/domain/repositories/admin_repository.dart' as _i788;
import 'package:baladi/domain/repositories/auth_repository.dart' as _i417;
import 'package:baladi/domain/repositories/category_repository.dart' as _i572;
import 'package:baladi/domain/repositories/customer_repository.dart' as _i959;
import 'package:baladi/domain/repositories/notification_repository.dart'
    as _i279;
import 'package:baladi/domain/repositories/order_repository.dart' as _i256;
import 'package:baladi/domain/repositories/points_repository.dart' as _i1037;
import 'package:baladi/domain/repositories/product_repository.dart' as _i1055;
import 'package:baladi/domain/repositories/rider_repository.dart' as _i562;
import 'package:baladi/domain/repositories/settlement_repository.dart' as _i524;
import 'package:baladi/domain/repositories/shop_repository.dart' as _i368;
import 'package:baladi/domain/services/commission_calculator.dart' as _i303;
import 'package:baladi/domain/services/points_calculator.dart' as _i390;
import 'package:baladi/domain/usecases/admin/adjust_points.dart' as _i186;
import 'package:baladi/domain/usecases/admin/close_week.dart' as _i52;
import 'package:baladi/domain/usecases/admin/get_admin_dashboard.dart' as _i19;
import 'package:baladi/domain/usecases/admin/get_settlement_report.dart'
    as _i789;
import 'package:baladi/domain/usecases/admin/manage_users.dart' as _i1048;
import 'package:baladi/domain/usecases/admin/settle_period.dart' as _i516;
import 'package:baladi/domain/usecases/auth/login_customer.dart' as _i851;
import 'package:baladi/domain/usecases/auth/login_user.dart' as _i211;
import 'package:baladi/domain/usecases/auth/logout.dart' as _i968;
import 'package:baladi/domain/usecases/auth/recover_pin.dart' as _i829;
import 'package:baladi/domain/usecases/auth/register_customer.dart' as _i304;
import 'package:baladi/domain/usecases/catalog/get_categories.dart' as _i609;
import 'package:baladi/domain/usecases/catalog/get_category_shops.dart'
    as _i163;
import 'package:baladi/domain/usecases/catalog/get_shop_products.dart' as _i874;
import 'package:baladi/domain/usecases/customer/apply_referral.dart' as _i147;
import 'package:baladi/domain/usecases/customer/get_profile.dart' as _i309;
import 'package:baladi/domain/usecases/customer/update_address.dart' as _i1065;
import 'package:baladi/domain/usecases/customer/update_profile.dart' as _i455;
import 'package:baladi/domain/usecases/order/cancel_order.dart' as _i902;
import 'package:baladi/domain/usecases/order/get_order_details.dart' as _i42;
import 'package:baladi/domain/usecases/order/get_orders.dart' as _i206;
import 'package:baladi/domain/usecases/order/place_order.dart' as _i566;
import 'package:baladi/domain/usecases/order/update_order_status.dart' as _i6;
import 'package:baladi/domain/usecases/points/get_points_balance.dart' as _i7;
import 'package:baladi/domain/usecases/points/get_points_history.dart' as _i894;
import 'package:baladi/domain/usecases/points/redeem_points.dart' as _i550;
import 'package:baladi/domain/usecases/rider/accept_delivery.dart' as _i273;
import 'package:baladi/domain/usecases/rider/get_available_orders.dart'
    as _i594;
import 'package:baladi/domain/usecases/rider/get_rider_dashboard.dart' as _i302;
import 'package:baladi/domain/usecases/rider/get_rider_earnings.dart' as _i122;
import 'package:baladi/domain/usecases/rider/get_rider_orders.dart' as _i228;
import 'package:baladi/domain/usecases/rider/toggle_availability.dart' as _i91;
import 'package:baladi/domain/usecases/shop/confirm_cash_received.dart'
    as _i683;
import 'package:baladi/domain/usecases/shop/get_shop_dashboard.dart' as _i506;
import 'package:baladi/domain/usecases/shop/get_shop_orders.dart' as _i493;
import 'package:baladi/domain/usecases/shop/get_shop_settlements.dart'
    as _i1033;
import 'package:baladi/domain/usecases/shop/manage_product.dart' as _i840;
import 'package:baladi/domain/usecases/shop/toggle_shop_status.dart' as _i351;
import 'package:baladi/presentation/cubits/ad/ad_cubit.dart' as _i954;
import 'package:baladi/presentation/cubits/admin/admin_cubit.dart' as _i520;
import 'package:baladi/presentation/cubits/auth/auth_cubit.dart' as _i99;
import 'package:baladi/presentation/cubits/cart/cart_cubit.dart' as _i491;
import 'package:baladi/presentation/cubits/catalog/categories_cubit.dart'
    as _i615;
import 'package:baladi/presentation/cubits/catalog/shop_products_cubit.dart'
    as _i354;
import 'package:baladi/presentation/cubits/checkout/checkout_cubit.dart'
    as _i511;
import 'package:baladi/presentation/cubits/customer/customer_profile_cubit.dart'
    as _i786;
import 'package:baladi/presentation/cubits/notification/notification_cubit.dart'
    as _i48;
import 'package:baladi/presentation/cubits/order/order_cubit.dart' as _i517;
import 'package:baladi/presentation/cubits/points/points_cubit.dart' as _i580;
import 'package:baladi/presentation/cubits/rider/rider_cubit.dart' as _i116;
import 'package:baladi/presentation/cubits/settlement/settlement_cubit.dart'
    as _i1015;
import 'package:baladi/presentation/cubits/shop/shop_management_cubit.dart'
    as _i221;
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:firebase_messaging/firebase_messaging.dart' as _i892;
import 'package:flutter_secure_storage/flutter_secure_storage.dart' as _i558;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.factory<_i303.CommissionCalculator>(
      () => const _i303.CommissionCalculator(),
    );
    gh.factory<_i390.PointsCalculator>(() => const _i390.PointsCalculator());
    gh.lazySingleton<_i895.Connectivity>(() => registerModule.connectivity);
    gh.lazySingleton<_i892.FirebaseMessaging>(
      () => registerModule.firebaseMessaging,
    );
    gh.lazySingleton<_i558.FlutterSecureStorage>(
      () => registerModule.flutterSecureStorage,
    );
    gh.lazySingleton<_i460.SharedPreferencesAsync>(
      () => registerModule.sharedPreferencesAsync,
    );
    gh.lazySingleton<_i325.NotificationService>(
      () => _i325.NotificationServiceImpl(gh<_i892.FirebaseMessaging>()),
    );
    gh.lazySingleton<_i154.LocalStorageService>(
      () => _i154.LocalStorageServiceImpl(gh<_i460.SharedPreferencesAsync>()),
    );
    gh.lazySingleton<_i659.CacheService>(() => _i659.CacheServiceImpl());
    gh.lazySingleton<_i894.CategoryLocalDatasource>(
      () => _i894.CategoryLocalDatasourceImpl(
        cacheService: gh<_i659.CacheService>(),
      ),
    );
    gh.lazySingleton<_i731.ProductLocalDatasource>(
      () => _i731.ProductLocalDatasourceImpl(
        cacheService: gh<_i659.CacheService>(),
      ),
    );
    gh.lazySingleton<_i725.NetworkInfo>(
      () => _i725.NetworkInfoImpl(gh<_i895.Connectivity>()),
    );
    gh.lazySingleton<_i253.SecureStorageService>(
      () => _i253.SecureStorageServiceImpl(gh<_i558.FlutterSecureStorage>()),
    );
    gh.lazySingleton<_i108.AppRouter>(
      () => _i108.AppRouter(secureStorage: gh<_i253.SecureStorageService>()),
    );
    gh.lazySingleton<_i867.OrderLocalDatasource>(
      () => _i867.OrderLocalDatasourceImpl(
        cacheService: gh<_i659.CacheService>(),
      ),
    );
    gh.lazySingleton<_i373.CartLocalDatasource>(
      () =>
          _i373.CartLocalDatasourceImpl(cacheService: gh<_i659.CacheService>()),
    );
    gh.lazySingleton<_i779.AuthLocalDatasource>(
      () => _i779.AuthLocalDatasourceImpl(
        secureStorage: gh<_i253.SecureStorageService>(),
        localStorage: gh<_i154.LocalStorageService>(),
        cacheService: gh<_i659.CacheService>(),
      ),
    );
    gh.lazySingleton<_i547.ApiClient>(
      () => registerModule.apiClient(gh<_i253.SecureStorageService>()),
    );
    gh.lazySingleton<_i751.ProductRemoteDatasource>(
      () => _i751.ProductRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.factory<_i491.CartCubit>(
      () => _i491.CartCubit(cartDatasource: gh<_i373.CartLocalDatasource>()),
    );
    gh.lazySingleton<_i465.AuthRemoteDatasource>(
      () => _i465.AuthRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i350.PointsRemoteDatasource>(
      () => _i350.PointsRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i952.OrderRemoteDatasource>(
      () => _i952.OrderRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i71.CustomerRemoteDatasource>(
      () => _i71.CustomerRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i4.RiderRemoteDatasource>(
      () => _i4.RiderRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i537.CategoryRemoteDatasource>(
      () =>
          _i537.CategoryRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i928.SettlementRemoteDatasource>(
      () => _i928.SettlementRemoteDatasourceImpl(
        apiClient: gh<_i547.ApiClient>(),
      ),
    );
    gh.lazySingleton<_i215.ShopRemoteDatasource>(
      () => _i215.ShopRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i1037.PointsRepository>(
      () => _i928.PointsRepositoryImpl(
        remoteDatasource: gh<_i350.PointsRemoteDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i524.SettlementRepository>(
      () => _i366.SettlementRepositoryImpl(
        remoteDatasource: gh<_i928.SettlementRemoteDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i562.RiderRepository>(
      () => _i1014.RiderRepositoryImpl(
        remoteDatasource: gh<_i4.RiderRemoteDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i368.ShopRepository>(
      () => _i984.ShopRepositoryImpl(
        remoteDatasource: gh<_i215.ShopRemoteDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i594.GetAvailableOrders>(
      () => _i594.GetAvailableOrders(gh<_i562.RiderRepository>()),
    );
    gh.lazySingleton<_i302.GetRiderDashboard>(
      () => _i302.GetRiderDashboard(gh<_i562.RiderRepository>()),
    );
    gh.lazySingleton<_i122.GetRiderEarnings>(
      () => _i122.GetRiderEarnings(gh<_i562.RiderRepository>()),
    );
    gh.lazySingleton<_i228.GetRiderOrders>(
      () => _i228.GetRiderOrders(gh<_i562.RiderRepository>()),
    );
    gh.lazySingleton<_i91.ToggleAvailability>(
      () => _i91.ToggleAvailability(gh<_i562.RiderRepository>()),
    );
    gh.lazySingleton<_i959.CustomerRepository>(
      () => _i398.CustomerRepositoryImpl(
        remoteDatasource: gh<_i71.CustomerRemoteDatasource>(),
        localDatasource: gh<_i779.AuthLocalDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i572.CategoryRepository>(
      () => _i54.CategoryRepositoryImpl(
        remoteDatasource: gh<_i537.CategoryRemoteDatasource>(),
        localDatasource: gh<_i894.CategoryLocalDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i789.GetSettlementReport>(
      () => _i789.GetSettlementReport(gh<_i524.SettlementRepository>()),
    );
    gh.lazySingleton<_i516.GetShopSettlementDetail>(
      () => _i516.GetShopSettlementDetail(gh<_i524.SettlementRepository>()),
    );
    gh.lazySingleton<_i1073.AdminRemoteDatasource>(
      () => _i1073.AdminRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i1055.ProductRepository>(
      () => _i465.ProductRepositoryImpl(
        remoteDatasource: gh<_i751.ProductRemoteDatasource>(),
        localDatasource: gh<_i731.ProductLocalDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i328.NotificationRemoteDatasource>(
      () => _i328.NotificationRemoteDatasourceImpl(
        apiClient: gh<_i547.ApiClient>(),
      ),
    );
    gh.lazySingleton<_i417.AuthRepository>(
      () => _i875.AuthRepositoryImpl(
        remoteDatasource: gh<_i465.AuthRemoteDatasource>(),
        localDatasource: gh<_i779.AuthLocalDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i398.AdRemoteDatasource>(
      () => _i398.AdRemoteDatasourceImpl(apiClient: gh<_i547.ApiClient>()),
    );
    gh.lazySingleton<_i788.AdminRepository>(
      () => _i179.AdminRepositoryImpl(
        remoteDatasource: gh<_i1073.AdminRemoteDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i256.OrderRepository>(
      () => _i28.OrderRepositoryImpl(
        remoteDatasource: gh<_i952.OrderRemoteDatasource>(),
        localDatasource: gh<_i867.OrderLocalDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i7.GetPointsBalance>(
      () => _i7.GetPointsBalance(gh<_i1037.PointsRepository>()),
    );
    gh.lazySingleton<_i894.GetPointsHistory>(
      () => _i894.GetPointsHistory(gh<_i1037.PointsRepository>()),
    );
    gh.lazySingleton<_i851.LoginCustomer>(
      () => _i851.LoginCustomer(gh<_i417.AuthRepository>()),
    );
    gh.lazySingleton<_i211.LoginUser>(
      () => _i211.LoginUser(gh<_i417.AuthRepository>()),
    );
    gh.lazySingleton<_i968.Logout>(
      () => _i968.Logout(gh<_i417.AuthRepository>()),
    );
    gh.lazySingleton<_i829.RecoverPin>(
      () => _i829.RecoverPin(gh<_i417.AuthRepository>()),
    );
    gh.lazySingleton<_i304.RegisterCustomer>(
      () => _i304.RegisterCustomer(gh<_i417.AuthRepository>()),
    );
    gh.lazySingleton<_i550.RedeemPoints>(
      () => _i550.RedeemPoints(
        gh<_i1037.PointsRepository>(),
        gh<_i390.PointsCalculator>(),
      ),
    );
    gh.lazySingleton<_i524.AdRepository>(
      () => _i451.AdRepositoryImpl(
        remoteDatasource: gh<_i398.AdRemoteDatasource>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.lazySingleton<_i506.GetShopDashboard>(
      () => _i506.GetShopDashboard(gh<_i368.ShopRepository>()),
    );
    gh.lazySingleton<_i1033.GetShopSettlements>(
      () => _i1033.GetShopSettlements(gh<_i368.ShopRepository>()),
    );
    gh.lazySingleton<_i840.CreateProduct>(
      () => _i840.CreateProduct(gh<_i368.ShopRepository>()),
    );
    gh.lazySingleton<_i840.UpdateProduct>(
      () => _i840.UpdateProduct(gh<_i368.ShopRepository>()),
    );
    gh.lazySingleton<_i840.DeleteProduct>(
      () => _i840.DeleteProduct(gh<_i368.ShopRepository>()),
    );
    gh.lazySingleton<_i351.ToggleShopStatus>(
      () => _i351.ToggleShopStatus(gh<_i368.ShopRepository>()),
    );
    gh.factory<_i580.PointsCubit>(
      () => _i580.PointsCubit(
        getPointsBalance: gh<_i7.GetPointsBalance>(),
        getPointsHistory: gh<_i894.GetPointsHistory>(),
      ),
    );
    gh.lazySingleton<_i874.GetShopProducts>(
      () => _i874.GetShopProducts(gh<_i1055.ProductRepository>()),
    );
    gh.factory<_i954.AdCubit>(
      () => _i954.AdCubit(adRepository: gh<_i524.AdRepository>()),
    );
    gh.lazySingleton<_i186.AdjustPoints>(
      () => _i186.AdjustPoints(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i52.CloseWeek>(
      () => _i52.CloseWeek(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i19.GetAdminDashboard>(
      () => _i19.GetAdminDashboard(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.GetUsers>(
      () => _i1048.GetUsers(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.ToggleUserStatus>(
      () => _i1048.ToggleUserStatus(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.ResetUserPassword>(
      () => _i1048.ResetUserPassword(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.CreateShopAsAdmin>(
      () => _i1048.CreateShopAsAdmin(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.UpdateShopAsAdmin>(
      () => _i1048.UpdateShopAsAdmin(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.CreateRiderAsAdmin>(
      () => _i1048.CreateRiderAsAdmin(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i1048.UpdateRiderAsAdmin>(
      () => _i1048.UpdateRiderAsAdmin(gh<_i788.AdminRepository>()),
    );
    gh.lazySingleton<_i147.ApplyReferral>(
      () => _i147.ApplyReferral(gh<_i959.CustomerRepository>()),
    );
    gh.lazySingleton<_i309.GetProfile>(
      () => _i309.GetProfile(gh<_i959.CustomerRepository>()),
    );
    gh.lazySingleton<_i1065.UpdateAddress>(
      () => _i1065.UpdateAddress(gh<_i959.CustomerRepository>()),
    );
    gh.lazySingleton<_i455.UpdateProfile>(
      () => _i455.UpdateProfile(gh<_i959.CustomerRepository>()),
    );
    gh.lazySingleton<_i902.CancelOrder>(
      () => _i902.CancelOrder(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i42.GetOrderDetails>(
      () => _i42.GetOrderDetails(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i206.GetOrders>(
      () => _i206.GetOrders(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i566.PlaceOrder>(
      () => _i566.PlaceOrder(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i6.UpdateOrderStatus>(
      () => _i6.UpdateOrderStatus(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i273.AcceptDelivery>(
      () => _i273.AcceptDelivery(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i683.ConfirmCashReceived>(
      () => _i683.ConfirmCashReceived(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i493.GetShopOrders>(
      () => _i493.GetShopOrders(gh<_i256.OrderRepository>()),
    );
    gh.lazySingleton<_i609.GetCategories>(
      () => _i609.GetCategories(gh<_i572.CategoryRepository>()),
    );
    gh.lazySingleton<_i163.GetCategoryShops>(
      () => _i163.GetCategoryShops(gh<_i572.CategoryRepository>()),
    );
    gh.factory<_i511.CheckoutCubit>(
      () => _i511.CheckoutCubit(
        placeOrder: gh<_i566.PlaceOrder>(),
        getPointsBalance: gh<_i7.GetPointsBalance>(),
        pointsCalculator: gh<_i390.PointsCalculator>(),
        commissionCalculator: gh<_i303.CommissionCalculator>(),
      ),
    );
    gh.lazySingleton<_i279.NotificationRepository>(
      () => _i1018.NotificationRepositoryImpl(
        remoteDatasource: gh<_i328.NotificationRemoteDatasource>(),
        cacheService: gh<_i659.CacheService>(),
        networkInfo: gh<_i725.NetworkInfo>(),
      ),
    );
    gh.factory<_i99.AuthCubit>(
      () => _i99.AuthCubit(
        registerCustomer: gh<_i304.RegisterCustomer>(),
        loginCustomer: gh<_i851.LoginCustomer>(),
        loginUser: gh<_i211.LoginUser>(),
        logout: gh<_i968.Logout>(),
        recoverPin: gh<_i829.RecoverPin>(),
        authRepository: gh<_i417.AuthRepository>(),
      ),
    );
    gh.factory<_i1015.SettlementCubit>(
      () => _i1015.SettlementCubit(
        settlementRepository: gh<_i524.SettlementRepository>(),
        getSettlementReport: gh<_i789.GetSettlementReport>(),
        getShopSettlementDetail: gh<_i516.GetShopSettlementDetail>(),
        closeWeek: gh<_i52.CloseWeek>(),
      ),
    );
    gh.factory<_i520.AdminCubit>(
      () => _i520.AdminCubit(
        getAdminDashboard: gh<_i19.GetAdminDashboard>(),
        closeWeek: gh<_i52.CloseWeek>(),
        adjustPoints: gh<_i186.AdjustPoints>(),
        adminRepository: gh<_i788.AdminRepository>(),
        resetUserPassword: gh<_i1048.ResetUserPassword>(),
        createShopAsAdmin: gh<_i1048.CreateShopAsAdmin>(),
        updateShopAsAdmin: gh<_i1048.UpdateShopAsAdmin>(),
        createRiderAsAdmin: gh<_i1048.CreateRiderAsAdmin>(),
        updateRiderAsAdmin: gh<_i1048.UpdateRiderAsAdmin>(),
      ),
    );
    gh.factory<_i786.CustomerProfileCubit>(
      () => _i786.CustomerProfileCubit(
        getProfile: gh<_i309.GetProfile>(),
        updateProfile: gh<_i455.UpdateProfile>(),
        updateAddress: gh<_i1065.UpdateAddress>(),
        applyReferral: gh<_i147.ApplyReferral>(),
      ),
    );
    gh.factory<_i354.ShopProductsCubit>(
      () =>
          _i354.ShopProductsCubit(getShopProducts: gh<_i874.GetShopProducts>()),
    );
    gh.factory<_i48.NotificationCubit>(
      () => _i48.NotificationCubit(
        notificationRepository: gh<_i279.NotificationRepository>(),
      ),
    );
    gh.factory<_i221.ShopManagementCubit>(
      () => _i221.ShopManagementCubit(
        getShopDashboard: gh<_i506.GetShopDashboard>(),
        getShopOrders: gh<_i493.GetShopOrders>(),
        getShopSettlements: gh<_i1033.GetShopSettlements>(),
        createProduct: gh<_i840.CreateProduct>(),
        updateProduct: gh<_i840.UpdateProduct>(),
        deleteProduct: gh<_i840.DeleteProduct>(),
        updateOrderStatus: gh<_i6.UpdateOrderStatus>(),
        shopRepository: gh<_i368.ShopRepository>(),
      ),
    );
    gh.factory<_i517.OrderCubit>(
      () => _i517.OrderCubit(
        getOrders: gh<_i206.GetOrders>(),
        getOrderDetails: gh<_i42.GetOrderDetails>(),
        placeOrder: gh<_i566.PlaceOrder>(),
        updateOrderStatus: gh<_i6.UpdateOrderStatus>(),
        cancelOrder: gh<_i902.CancelOrder>(),
      ),
    );
    gh.factory<_i116.RiderCubit>(
      () => _i116.RiderCubit(
        getRiderDashboard: gh<_i302.GetRiderDashboard>(),
        toggleAvailability: gh<_i91.ToggleAvailability>(),
        getAvailableOrders: gh<_i594.GetAvailableOrders>(),
        getRiderOrders: gh<_i228.GetRiderOrders>(),
        updateOrderStatus: gh<_i6.UpdateOrderStatus>(),
        riderRepository: gh<_i562.RiderRepository>(),
      ),
    );
    gh.factory<_i615.CategoriesCubit>(
      () => _i615.CategoriesCubit(
        getCategories: gh<_i609.GetCategories>(),
        getCategoryShops: gh<_i163.GetCategoryShops>(),
      ),
    );
    return this;
  }
}

class _$RegisterModule extends _i697.RegisterModule {}
