// Data - Shop repository implementation.
//
// Implements the ShopRepository contract using remote datasource.
// Handles both customer-facing shop details and shop owner management.

import 'package:injectable/injectable.dart';

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/shop.dart';
import '../../domain/entities/shop_settlement.dart';
import '../../domain/repositories/shop_repository.dart';
import '../datasources/remote/shop_remote_datasource.dart';

/// Implementation of [ShopRepository].
@LazySingleton(as: ShopRepository)
class ShopRepositoryImpl implements ShopRepository {
  final ShopRemoteDatasource _remoteDatasource;
  final NetworkInfo _networkInfo;

  /// Creates a [ShopRepositoryImpl].
  ShopRepositoryImpl({
    required ShopRemoteDatasource remoteDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<Shop>> getShopDetails(String shopId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getShopDetails(shopId));
  }

  @override
  Future<Result<List<Product>>> getShopProducts({
    required String shopId,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getShopProducts(
          shopId: shopId,
          page: page,
          perPage: perPage,
        ));
  }

  @override
  Future<Result<Shop>> getShopProfile() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getShopProfile());
  }

  @override
  Future<Result<Shop>> updateShopStatus({required bool isOpen}) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.updateShopStatus(isOpen: isOpen),
    );
  }

  @override
  Future<Result<ShopDashboard>> getShopDashboard() async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final json = await _remoteDatasource.getShopDashboard();
      return ShopDashboard(
        totalOrders: json['total_orders'] as int? ?? 0,
        completedOrders: json['completed_orders'] as int? ?? 0,
        cancelledOrders: json['cancelled_orders'] as int? ?? 0,
        pendingOrders: json['pending_orders'] as int? ?? 0,
        totalRevenue: (json['total_revenue'] as num?)?.toDouble() ?? 0,
        totalCommission: (json['total_commission'] as num?)?.toDouble() ?? 0,
        netEarnings: (json['net_earnings'] as num?)?.toDouble() ?? 0,
      );
    });
  }

  @override
  Future<Result<List<Product>>> getOwnProducts({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getOwnProducts(page: page, perPage: perPage),
    );
  }

  @override
  Future<Result<Product>> createProduct({
    required String name,
    String? nameAr,
    String? description,
    required double price,
    String? imageUrl,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.createProduct(
          name: name,
          nameAr: nameAr,
          description: description,
          price: price,
          imageUrl: imageUrl,
        ));
  }

  @override
  Future<Result<Product>> updateProduct({
    required String productId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.updateProduct(
          productId: productId,
          name: name,
          nameAr: nameAr,
          description: description,
          price: price,
          imageUrl: imageUrl,
          isAvailable: isAvailable,
        ));
  }

  @override
  Future<Result<void>> deleteProduct(String productId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.deleteProduct(productId));
  }

  @override
  Future<Result<List<ShopSettlement>>> getSettlements({
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(
      () => _remoteDatasource.getSettlements(page: page, perPage: perPage),
    );
  }
}