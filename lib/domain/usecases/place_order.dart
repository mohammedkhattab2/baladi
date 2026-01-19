/// PlaceOrder use case.
///
/// Orchestrates the complete order placement flow including:
/// - Order validation
/// - Points redemption validation
/// - Financial calculations
/// - Personal commission calculation
/// - Order creation
/// - Points usage recording for weekly settlement
///
/// Key Points Rules:
/// - Points discount does NOT reduce store or rider earnings
/// - Platform bears the cost of points discounts
/// - Points value is credited to store's weekly commission account
///
/// Architecture note: Use cases orchestrate domain services and
/// repositories. They don't contain business calculations themselves.
library;

import '../../core/result/result.dart' as result;
import '../../core/error/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../entities/order_item.dart';
import '../repositories/order_repository.dart';
import '../repositories/points_repository.dart';
import '../services/order_processor.dart';
import '../services/personal_commission_service.dart';
import '../services/points_service.dart';
import '../enums/order_status.dart';

/// Parameters for placing an order.
class PlaceOrderParams {
  final String customerId;
  final String storeId;
  final List<OrderItemInput> items;
  final String deliveryAddress;
  final String? customerNotes;
  final int pointsToUse;
  final bool isFreeDelivery;
  final double? storeCommissionRate;
  final double distanceKm;

  const PlaceOrderParams({
    required this.customerId,
    required this.storeId,
    required this.items,
    required this.deliveryAddress,
    this.customerNotes,
    this.pointsToUse = 0,
    this.isFreeDelivery = false,
    this.storeCommissionRate,
    this.distanceKm = 0,
  });
}

/// Result of placing an order.
class PlaceOrderResult {
  final Order order;
  final int pointsUsed;
  final int pointsEarned;
  final double customerPays;
  
  /// Personal commission tracking (tracked separately, does NOT affect other revenues).
  final PersonalCommissionResult? personalCommission;

  /// Points usage record for weekly settlement tracking.
  /// This ensures the store receives credit for points redeemed.
  final PointsUsageRecord? pointsUsageRecord;

  /// Store weekly commission credit from points redemption.
  /// This amount is added to store's weekly settlement payout.
  final double storeWeeklyCommissionCredit;

  const PlaceOrderResult({
    required this.order,
    required this.pointsUsed,
    required this.pointsEarned,
    required this.customerPays,
    this.personalCommission,
    this.pointsUsageRecord,
    this.storeWeeklyCommissionCredit = 0,
  });
}

/// Use case for placing a new order.
class PlaceOrder implements UseCase<PlaceOrderResult, PlaceOrderParams> {
  final OrderRepository _orderRepository;
  final PointsRepository _pointsRepository;
  final OrderProcessor _orderProcessor;
  final PersonalCommissionService _personalCommissionService;
  final PointsService _pointsService;

  PlaceOrder({
    required OrderRepository orderRepository,
    required PointsRepository pointsRepository,
    OrderProcessor? orderProcessor,
    PersonalCommissionService? personalCommissionService,
    PointsService? pointsService,
  })  : _orderRepository = orderRepository,
        _pointsRepository = pointsRepository,
        _orderProcessor = orderProcessor ?? OrderProcessor(),
        _personalCommissionService = personalCommissionService ?? PersonalCommissionService(),
        _pointsService = pointsService ?? PointsService();

  @override
  Future<result.Result<PlaceOrderResult>> call(PlaceOrderParams params) async {
    // Step 1: Validate order input
    final validationResult = _orderProcessor.validateOrderInput(
      items: params.items,
      deliveryAddress: params.deliveryAddress,
    );

    if (!validationResult.isValid) {
      return result.Failure(
        ValidationFailure(message: validationResult.errors.join(', ')),
      );
    }

    final subtotal = validationResult.subtotal!;

    // Step 2: Get customer's available points
    int availablePoints = 0;
    if (params.pointsToUse > 0) {
      final pointsResult = await _pointsRepository.getPointsBalance(params.customerId);
      
      final pointsOrError = pointsResult.fold(
        onSuccess: (points) => points.balance,
        onFailure: (_) => 0,
      );
      availablePoints = pointsOrError;
    }

    // Step 3: Calculate financials using domain services
    final financials = _orderProcessor.calculateFinancials(
      subtotal: subtotal,
      distanceKm: params.distanceKm,
      pointsToUse: params.pointsToUse,
      availablePoints: availablePoints,
      isFreeDelivery: params.isFreeDelivery,
      storeCommissionRate: params.storeCommissionRate,
    );

    // Step 4: Create order entity
    final now = DateTime.now();
    final orderNumber = _generateOrderNumber();
    
    // Temporary order ID for items (will be replaced by server)
    const tempOrderId = 'temp';
    
    final orderItems = params.items.map((input) => OrderItem(
      id: '', // Will be assigned by server
      orderId: tempOrderId,
      productId: input.productId,
      productName: input.productName,
      price: input.price,
      quantity: input.quantity,
      subtotal: input.subtotal,
      notes: input.notes,
    )).toList();

    final order = Order(
      id: '', // Will be assigned by server
      orderNumber: orderNumber,
      customerId: params.customerId,
      storeId: params.storeId,
      items: orderItems,
      subtotal: subtotal,
      deliveryFee: financials.breakdown.deliveryFee,
      pointsDiscount: financials.breakdown.pointsDiscount,
      total: financials.customerPays,
      status: OrderStatus.pending,
      deliveryAddress: params.deliveryAddress,
      customerNotes: params.customerNotes,
      pointsUsed: financials.pointsUsed,
      pointsEarned: financials.pointsEarned,
      storeCommission: financials.breakdown.storeCommission,
      platformCommission: financials.platformCommission,
      isFreeDelivery: params.isFreeDelivery,
      createdAt: now,
    );

    // Step 5: Create order in repository
    final createResult = await _orderRepository.createOrder(order);

    return createResult.fold(
      onSuccess: (createdOrder) {
        // Step 6: Redeem points if used (fire and forget, order is already created)
        PointsUsageRecord? pointsUsageRecord;
        double storeWeeklyCommissionCredit = 0;

        if (financials.pointsUsed > 0) {
          _pointsRepository.redeemPoints(
            customerId: params.customerId,
            orderId: createdOrder.id,
            points: financials.pointsUsed,
          );

          // Step 6b: Record points usage for weekly settlement
          // The store receives credit for points redeemed on their orders
          pointsUsageRecord = _pointsService.recordPointsUsage(
            orderId: createdOrder.id,
            storeId: params.storeId,
            pointsUsed: financials.pointsUsed,
            monetaryValue: financials.breakdown.pointsDiscount,
          );

          // Store receives the points discount value in weekly settlement
          storeWeeklyCommissionCredit = financials.breakdown.pointsDiscount;
        }

        // Step 7: Calculate personal commission (tracked separately, does NOT affect other revenues)
        final personalCommission = _personalCommissionService.calculateTotalCommission(
          orderSubtotal: subtotal,
          deliveryFee: financials.breakdown.deliveryFee,
          isFreeDelivery: params.isFreeDelivery,
        );

        return result.Success(PlaceOrderResult(
          order: createdOrder,
          pointsUsed: financials.pointsUsed,
          pointsEarned: financials.pointsEarned,
          customerPays: financials.customerPays,
          personalCommission: personalCommission,
          pointsUsageRecord: pointsUsageRecord,
          storeWeeklyCommissionCredit: storeWeeklyCommissionCredit,
        ));
      },
      onFailure: (failure) => result.Failure(failure),
    );
  }

  /// Generate a unique order number.
  String _generateOrderNumber() {
    final now = DateTime.now();
    final datePart = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final timePart = '${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}';
    final random = now.millisecond.toString().padLeft(3, '0');
    return 'ORD-$datePart-$timePart$random';
  }
}