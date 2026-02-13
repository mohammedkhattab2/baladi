// Data - Order repository implementation.
//
// Implements the OrderRepository contract using remote and local datasources.
// Handles order creation, retrieval, status transitions, cancellation,
// and local caching for offline access.

import 'package:injectable/injectable.dart' hide Order;

import '../../core/error/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_datasource.dart';
import '../datasources/remote/order_remote_datasource.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

/// Implementation of [OrderRepository].
@LazySingleton(as: OrderRepository)
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDatasource _remoteDatasource;
  final OrderLocalDatasource _localDatasource;
  final NetworkInfo _networkInfo;

  /// Creates an [OrderRepositoryImpl].
  OrderRepositoryImpl({
    required OrderRemoteDatasource remoteDatasource,
    required OrderLocalDatasource localDatasource,
    required NetworkInfo networkInfo,
  })  : _remoteDatasource = remoteDatasource,
        _localDatasource = localDatasource,
        _networkInfo = networkInfo;

  @override
  Future<Result<Order>> placeOrder(PlaceOrderParams params) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final itemModels = params.items
          .map((item) => item is OrderItemModel
              ? item
              : OrderItemModel.fromEntity(item))
          .toList();
      final order = await _remoteDatasource.placeOrder(
        shopId: params.shopId,
        items: itemModels,
        deliveryAddress: params.deliveryAddress,
        landmark: params.landmark,
        area: params.area,
        notes: params.notes,
        pointsToRedeem: params.pointsToRedeem,
        isFreeDelivery: params.isFreeDelivery,
      );
      // Cache the newly placed order.
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<List<Order>>> getOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      // Return cached orders as fallback when offline.
      final cached = await _localDatasource.getCachedOrders();
      if (cached.isNotEmpty) {
        return Success(cached);
      }
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final orders = await _remoteDatasource.getOrders(
        status: status?.value,
        page: page,
        perPage: perPage,
      );
      // Cache first page results for offline access.
      if (page == 1) {
        await _localDatasource.cacheOrders(orders);
      }
      return orders;
    });
  }

  @override
  Future<Result<Order>> getOrderDetails(String orderId) async {
    if (!await _networkInfo.isConnected) {
      // Try to return cached order.
      final cached = await _localDatasource.getCachedOrderById(orderId);
      if (cached != null) {
        return Success(cached);
      }
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.getOrderDetails(orderId);
      // Update cache with latest order state.
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<Order>> acceptOrder(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.acceptOrder(orderId);
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<Order>> markPreparing(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.markPreparing(orderId);
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<Order>> markPickedUp(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.markPickedUp(orderId);
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<Order>> markDelivered(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.markDelivered(orderId);
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<Order>> confirmCashReceived(String orderId) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.confirmCashReceived(orderId);
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<Order>> cancelOrder({
    required String orderId,
    String? reason,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() async {
      final order = await _remoteDatasource.cancelOrder(
        orderId: orderId,
        reason: reason,
      );
      await _localDatasource.cacheOrder(order);
      return order;
    });
  }

  @override
  Future<Result<List<Order>>> getShopOrders({
    OrderStatus? status,
    int page = 1,
    int perPage = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return const ResultFailure(
        NetworkFailure(message: 'لا يوجد اتصال بالإنترنت'),
      );
    }
    return Result.guard(() => _remoteDatasource.getShopOrders(
          status: status?.value,
          page: page,
          perPage: perPage,
        ));
  }

  @override
  Future<List<Order>> getCachedOrders() async {
    return _localDatasource.getCachedOrders();
  }

  @override
  Future<void> cacheOrders(List<Order> orders) async {
    final models = orders
        .map((o) => o is OrderModel ? o : OrderModel.fromEntity(o))
        .toList();
    await _localDatasource.cacheOrders(models);
  }

  @override
  Future<void> clearCache() async {
    await _localDatasource.clearCache();
  }
}