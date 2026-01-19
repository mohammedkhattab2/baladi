/// Order repository implementation.
///
/// Implements [OrderRepository] with offline-first strategy.
/// Uses local cache for quick access and syncs with remote.
library;

import 'dart:async';

import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart' as failures;
import '../../core/result/result.dart';
import '../../domain/entities/order.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/local/order_local_data_source.dart';
import '../datasources/remote/order_remote_data_source.dart';
import '../dto/order_item_dto.dart';

/// Implementation of [OrderRepository] with offline-first strategy.
class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _remoteDataSource;
  final OrderLocalDataSource _localDataSource;

  // Stream controllers for real-time updates
  final _orderStreamControllers = <String, StreamController<Order>>{};
  final _ordersStreamController = StreamController<List<Order>>.broadcast();

  OrderRepositoryImpl({
    required OrderRemoteDataSource remoteDataSource,
    required OrderLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<Result<Order>> createOrder(Order order) async {
    try {
      // Convert order items to DTOs
      final itemDtos = order.items.map((item) => OrderItemDto(
        id: item.id,
        orderId: item.orderId,
        productId: item.productId,
        productName: item.productName,
        price: item.price,
        quantity: item.quantity,
        subtotal: item.subtotal,
        notes: item.notes,
      )).toList();

      final orderDto = await _remoteDataSource.createOrder(
        customerId: order.customerId,
        storeId: order.storeId,
        items: itemDtos,
        subtotal: order.subtotal,
        deliveryFee: order.deliveryFee,
        total: order.total,
        deliveryAddress: order.deliveryAddress,
        deliveryAddressDetails: order.deliveryLandmark,
        pointsToRedeem: order.pointsUsed,
        pointsDiscount: order.pointsDiscount,
        note: order.customerNotes,
      );

      // Cache the new order
      await _localDataSource.cacheOrder(orderDto);

      return Success(orderDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Failure(failures.ValidationFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Order>> getOrderById(String orderId) async {
    try {
      // Try remote first for fresh data
      final orderDto = await _remoteDataSource.getOrderById(orderId);
      await _localDataSource.cacheOrder(orderDto);
      return Success(orderDto.toEntity());
    } on NetworkException {
      // Fallback to cache
      try {
        final cachedOrder = await _localDataSource.getCachedOrder(orderId);
        if (cachedOrder != null) {
          return Success(cachedOrder.toEntity());
        }
        return Failure(const failures.NotFoundFailure(message: 'Order not found'));
      } on CacheException catch (e) {
        return Failure(failures.CacheFailure(message: e.message));
      }
    } on NotFoundException catch (e) {
      return Failure(failures.NotFoundFailure(message: e.message));
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getCustomerOrders({
    required String customerId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final orderDtos = await _remoteDataSource.getCustomerOrders(
        customerId: customerId,
        page: page,
        limit: pageSize,
      );

      // Cache orders
      await _localDataSource.cacheOrders(orderDtos);

      final orders = orderDtos.map((dto) => dto.toEntity()).toList();
      
      // Filter by status if provided
      if (status != null) {
        return Success(orders.where((o) => o.status == status).toList());
      }
      
      return Success(orders);
    } on NetworkException {
      // Fallback to cache
      try {
        final cachedOrders = await _localDataSource.getCachedCustomerOrders(customerId);
        var orders = cachedOrders.map((dto) => dto.toEntity()).toList();
        
        if (status != null) {
          orders = orders.where((o) => o.status == status).toList();
        }
        
        return Success(orders);
      } on CacheException catch (e) {
        return Failure(failures.CacheFailure(message: e.message));
      }
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getStoreOrders({
    required String storeId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final orderDtos = await _remoteDataSource.getStoreOrders(
        storeId: storeId,
        status: status?.name,
        page: page,
        limit: pageSize,
      );

      await _localDataSource.cacheOrders(orderDtos);

      final orders = orderDtos.map((dto) => dto.toEntity()).toList();
      return Success(orders);
    } on NetworkException {
      try {
        final cachedOrders = await _localDataSource.getCachedStoreOrders(storeId);
        var orders = cachedOrders.map((dto) => dto.toEntity()).toList();
        
        if (status != null) {
          orders = orders.where((o) => o.status == status).toList();
        }
        
        return Success(orders);
      } on CacheException catch (e) {
        return Failure(failures.CacheFailure(message: e.message));
      }
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getRiderOrders({
    required String riderId,
    OrderStatus? status,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final orderDtos = await _remoteDataSource.getRiderOrders(
        riderId: riderId,
        status: status?.name,
        page: page,
        limit: pageSize,
      );

      await _localDataSource.cacheOrders(orderDtos);

      final orders = orderDtos.map((dto) => dto.toEntity()).toList();
      return Success(orders);
    } on NetworkException {
      try {
        final cachedOrders = await _localDataSource.getCachedRiderOrders(riderId);
        var orders = cachedOrders.map((dto) => dto.toEntity()).toList();
        
        if (status != null) {
          orders = orders.where((o) => o.status == status).toList();
        }
        
        return Success(orders);
      } on CacheException catch (e) {
        return Failure(failures.CacheFailure(message: e.message));
      }
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getAllOrders({
    OrderStatus? status,
    String? storeId,
    String? riderId,
    DateTime? fromDate,
    DateTime? toDate,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final orderDtos = await _remoteDataSource.getOrdersByDateRange(
        startDate: fromDate ?? DateTime.now().subtract(const Duration(days: 30)),
        endDate: toDate ?? DateTime.now(),
        storeId: storeId,
        riderId: riderId,
      );

      var orders = orderDtos.map((dto) => dto.toEntity()).toList();
      
      if (status != null) {
        orders = orders.where((o) => o.status == status).toList();
      }

      // Paginate
      final start = (page - 1) * pageSize;
      final end = start + pageSize;
      if (start < orders.length) {
        orders = orders.sublist(start, end > orders.length ? orders.length : end);
      } else {
        orders = [];
      }

      return Success(orders);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Order>> updateOrderStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String updatedBy,
    required UserRole updaterRole,
    String? note,
  }) async {
    try {
      final orderDto = await _remoteDataSource.updateOrderStatus(
        orderId: orderId,
        newStatus: newStatus.name,
        riderId: updaterRole == UserRole.delivery ? updatedBy : null,
        note: note,
      );

      await _localDataSource.updateCachedOrder(orderDto);
      
      // Notify stream listeners
      _notifyOrderUpdate(orderDto.toEntity());

      return Success(orderDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Failure(failures.ValidationFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Order>> assignRider({
    required String orderId,
    required String riderId,
  }) async {
    try {
      final orderDto = await _remoteDataSource.assignRider(
        orderId: orderId,
        riderId: riderId,
      );

      await _localDataSource.updateCachedOrder(orderDto);
      _notifyOrderUpdate(orderDto.toEntity());

      return Success(orderDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Order>> confirmCashReceived({
    required String orderId,
    required String storeId,
    required double amount,
  }) async {
    try {
      final orderDto = await _remoteDataSource.confirmCashToShop(
        orderId: orderId,
        storeId: storeId,
      );

      await _localDataSource.updateCachedOrder(orderDto);
      _notifyOrderUpdate(orderDto.toEntity());

      return Success(orderDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Order>> cancelOrder({
    required String orderId,
    required String cancelledBy,
    required UserRole cancellerRole,
    required String reason,
  }) async {
    try {
      final orderDto = await _remoteDataSource.cancelOrder(
        orderId: orderId,
        reason: reason,
      );

      await _localDataSource.updateCachedOrder(orderDto);
      _notifyOrderUpdate(orderDto.toEntity());

      return Success(orderDto.toEntity());
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } on ValidationException catch (e) {
      return Failure(failures.ValidationFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<Map<OrderStatus, int>>> getOrderCountsByStatus({
    String? storeId,
    String? riderId,
  }) async {
    try {
      final statsMap = await _remoteDataSource.getOrderStatistics(
        entityId: storeId ?? riderId ?? 'admin',
        entityType: storeId != null ? 'store' : (riderId != null ? 'rider' : 'admin'),
      );

      final counts = <OrderStatus, int>{};
      for (final status in OrderStatus.values) {
        counts[status] = statsMap['count_${status.name}'] as int? ?? 0;
      }

      return Success(counts);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getOrdersForSettlement({
    required DateTime weekStart,
    required DateTime weekEnd,
    String? storeId,
    String? riderId,
  }) async {
    try {
      final orderDtos = await _remoteDataSource.getOrdersByDateRange(
        startDate: weekStart,
        endDate: weekEnd,
        storeId: storeId,
        riderId: riderId,
      );

      final orders = orderDtos.map((dto) => dto.toEntity()).toList();
      
      // Filter only completed orders for settlement
      final completedOrders = orders.where(
        (o) => o.status == OrderStatus.completed
      ).toList();

      return Success(completedOrders);
    } on ServerException catch (e) {
      return Failure(failures.ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      return Failure(failures.NetworkFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  @override
  Stream<Order> watchOrder(String orderId) {
    if (!_orderStreamControllers.containsKey(orderId)) {
      _orderStreamControllers[orderId] = StreamController<Order>.broadcast();
    }
    return _orderStreamControllers[orderId]!.stream;
  }

  @override
  Stream<List<Order>> watchOrders({
    String? customerId,
    String? storeId,
    String? riderId,
    OrderStatus? status,
  }) {
    return _ordersStreamController.stream;
  }

  @override
  Future<Result<void>> syncOrders() async {
    try {
      // Get pending offline orders
      final pendingOrders = await _localDataSource.getPendingOfflineOrders();
      
      // Sync each order
      for (final orderDto in pendingOrders) {
        try {
          // Try to create order on remote
          await _remoteDataSource.createOrder(
            customerId: orderDto.customerId,
            storeId: orderDto.storeId,
            items: [], // Would need to get items from local storage
            subtotal: orderDto.subtotal,
            deliveryFee: orderDto.deliveryFee,
            total: orderDto.total,
            deliveryAddress: orderDto.deliveryAddress,
            deliveryAddressDetails: orderDto.deliveryLandmark,
            pointsToRedeem: orderDto.pointsUsed,
            pointsDiscount: orderDto.pointsDiscount,
            note: orderDto.customerNotes,
          );
          
          // Mark as synced
          await _localDataSource.markOrderSynced(orderDto.id);
        } catch (_) {
          // Individual order sync failed, continue with others
        }
      }
      
      await _localDataSource.updateLastCacheTimestamp();
      
      return const Success(null);
    } on CacheException catch (e) {
      return Failure(failures.CacheFailure(message: e.message));
    } catch (e) {
      return Failure(failures.SyncFailure(message: e.toString()));
    }
  }

  @override
  Future<Result<List<Order>>> getPendingSyncOrders() async {
    try {
      final orderDtos = await _localDataSource.getPendingOfflineOrders();
      final orders = orderDtos.map((dto) => dto.toEntity()).toList();
      return Success(orders);
    } on CacheException catch (e) {
      return Failure(failures.CacheFailure(message: e.message));
    } catch (e) {
      return Failure(failures.ServerFailure(message: e.toString()));
    }
  }

  /// Notify stream listeners of order update.
  void _notifyOrderUpdate(Order order) {
    if (_orderStreamControllers.containsKey(order.id)) {
      _orderStreamControllers[order.id]!.add(order);
    }
  }

  /// Dispose stream controllers.
  void dispose() {
    for (final controller in _orderStreamControllers.values) {
      controller.close();
    }
    _ordersStreamController.close();
  }
}