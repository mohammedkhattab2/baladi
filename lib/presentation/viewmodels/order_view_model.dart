/// Order ViewModel.
///
/// Handles order-related UI state and orchestrates order use cases.
/// This ViewModel does NOT contain business logic - it delegates
/// to use cases and domain services.
library;
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/product.dart';
import '../../domain/enums/order_status.dart';
import '../../domain/enums/user_role.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/place_order.dart';
import '../../domain/usecases/update_order_status.dart';
import '../base/base_view_model.dart';
import '../state/ui_state.dart';

/// ViewModel for order-related screens.
class OrderViewModel extends BaseViewModel with PaginationMixin<Order> {
  final PlaceOrder _placeOrder;
  final UpdateOrderStatus _updateOrderStatus;
  final OrderRepository _orderRepository;

  OrderViewModel({
    required PlaceOrder placeOrder,
    required UpdateOrderStatus updateOrderStatus,
    required OrderRepository orderRepository,
  })  : _placeOrder = placeOrder,
        _updateOrderStatus = updateOrderStatus,
        _orderRepository = orderRepository;

  /// Current order being viewed/edited.
  Order? _currentOrder;
  Order? get currentOrder => _currentOrder;

  /// Last place order result (contains points info).
  PlaceOrderResult? _lastPlaceOrderResult;
  PlaceOrderResult? get lastPlaceOrderResult => _lastPlaceOrderResult;

  /// UI state for single order.
  UiState<Order> _orderState = const InitialState();
  UiState<Order> get orderState => _orderState;

  /// UI state for order list.
  UiState<List<Order>> _ordersState = const InitialState();
  UiState<List<Order>> get ordersState => _ordersState;

  /// Cart items for new order.
  final List<CartItem> _cartItems = [];
  List<CartItem> get cartItems => List.unmodifiable(_cartItems);

  /// Selected store ID for current order.
  String? _selectedStoreId;
  String? get selectedStoreId => _selectedStoreId;

  /// Delivery address.
  String _deliveryAddress = '';
  String get deliveryAddress => _deliveryAddress;

  /// Delivery landmark.
  String _deliveryLandmark = '';
  String get deliveryLandmark => _deliveryLandmark;

  /// Delivery area.
  String _deliveryArea = '';
  String get deliveryArea => _deliveryArea;

  /// Customer notes.
  String _customerNotes = '';
  String get customerNotes => _customerNotes;

  /// Points to redeem.
  int _pointsToRedeem = 0;
  int get pointsToRedeem => _pointsToRedeem;

  /// Available points (from user).
  int _availablePoints = 0;
  int get availablePoints => _availablePoints;

  /// Order status filter.
  OrderStatus? _statusFilter;
  OrderStatus? get statusFilter => _statusFilter;

  // ============ CART OPERATIONS ============

  /// Add item to cart.
  void addToCart(Product product, {int quantity = 1, String? note}) {
    final existingIndex = _cartItems.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex >= 0) {
      _cartItems[existingIndex] = _cartItems[existingIndex].copyWith(
        quantity: _cartItems[existingIndex].quantity + quantity,
      );
    } else {
      _cartItems.add(CartItem(
        product: product,
        quantity: quantity,
        note: note,
      ));
    }

    // Set store if first item
    _selectedStoreId ??= product.storeId;

    notifyListenersSafe();
  }

  /// Remove item from cart.
  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    
    // Clear store if cart is empty
    if (_cartItems.isEmpty) {
      _selectedStoreId = null;
    }

    notifyListenersSafe();
  }

  /// Update cart item quantity.
  void updateCartItemQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
      notifyListenersSafe();
    }
  }

  /// Update cart item note.
  void updateCartItemNote(String productId, String? note) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(note: note);
      notifyListenersSafe();
    }
  }

  /// Clear cart.
  void clearCart() {
    _cartItems.clear();
    _selectedStoreId = null;
    notifyListenersSafe();
  }

  /// Get cart subtotal.
  double get cartSubtotal {
    return _cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  /// Get cart item count.
  int get cartItemCount {
    return _cartItems.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if cart is empty.
  bool get isCartEmpty => _cartItems.isEmpty;

  // ============ ORDER FIELDS ============

  /// Set delivery address.
  void setDeliveryAddress(String value) {
    _deliveryAddress = value;
    notifyListenersSafe();
  }

  /// Set delivery landmark.
  void setDeliveryLandmark(String value) {
    _deliveryLandmark = value;
    notifyListenersSafe();
  }

  /// Set delivery area.
  void setDeliveryArea(String value) {
    _deliveryArea = value;
    notifyListenersSafe();
  }

  /// Set customer notes.
  void setCustomerNotes(String value) {
    _customerNotes = value;
    notifyListenersSafe();
  }

  /// Set points to redeem.
  void setPointsToRedeem(int points) {
    if (points <= _availablePoints) {
      _pointsToRedeem = points;
      notifyListenersSafe();
    }
  }

  /// Set available points (from user profile).
  void setAvailablePoints(int points) {
    _availablePoints = points;
    if (_pointsToRedeem > _availablePoints) {
      _pointsToRedeem = _availablePoints;
    }
    notifyListenersSafe();
  }

  /// Build full delivery address from components.
  String _buildFullDeliveryAddress() {
    final parts = <String>[];
    if (_deliveryAddress.isNotEmpty) parts.add(_deliveryAddress);
    if (_deliveryLandmark.isNotEmpty) parts.add('Landmark: $_deliveryLandmark');
    if (_deliveryArea.isNotEmpty) parts.add('Area: $_deliveryArea');
    return parts.join(', ');
  }

  // ============ ORDER OPERATIONS ============

  /// Place new order.
  Future<Order?> placeNewOrder({
    required String customerId,
    bool isFreeDelivery = false,
    double? storeCommissionRate,
    double distanceKm = 0,
  }) async {
    if (!_validateOrderFields()) {
      return null;
    }

    _orderState = const LoadingState();
    notifyListenersSafe();

    // Convert cart items to OrderItemInput
    final orderItems = _cartItems.map((item) => OrderItemInput(
      productId: item.product.id,
      productName: item.product.name,
      price: item.product.effectivePrice,
      quantity: item.quantity,
      notes: item.note,
    )).toList();

    final result = await _placeOrder(PlaceOrderParams(
      customerId: customerId,
      storeId: _selectedStoreId!,
      items: orderItems,
      deliveryAddress: _buildFullDeliveryAddress(),
      customerNotes: _customerNotes.isNotEmpty ? _customerNotes : null,
      pointsToUse: _pointsToRedeem,
      isFreeDelivery: isFreeDelivery,
      storeCommissionRate: storeCommissionRate,
      distanceKm: distanceKm,
    ));

    return result.fold(
      onSuccess: (placeOrderResult) {
        _lastPlaceOrderResult = placeOrderResult;
        _currentOrder = placeOrderResult.order;
        _orderState = SuccessState(placeOrderResult.order);
        clearCart();
        _clearOrderFields();
        notifyListenersSafe();
        return placeOrderResult.order;
      },
      onFailure: (failure) {
        _orderState = ErrorState.fromFailure(failure);
        notifyListenersSafe();
        return null;
      },
    );
  }

  /// Load order by ID.
  Future<void> loadOrder(String orderId) async {
    _orderState = const LoadingState();
    notifyListenersSafe();

    final result = await _orderRepository.getOrderById(orderId);

    result.fold(
      onSuccess: (order) {
        _currentOrder = order;
        _orderState = SuccessState(order);
        notifyListenersSafe();
      },
      onFailure: (failure) {
        _orderState = ErrorState.fromFailure(failure);
        notifyListenersSafe();
      },
    );
  }

  /// Load customer orders.
  Future<void> loadCustomerOrders(String customerId) async {
    _ordersState = const LoadingState();
    notifyListenersSafe();

    final result = await _orderRepository.getCustomerOrders(
      customerId: customerId,
      status: _statusFilter,
    );

    result.fold(
      onSuccess: (orders) {
        if (orders.isEmpty) {
          _ordersState = const EmptyState(message: 'No orders found');
        } else {
          _ordersState = SuccessState(orders);
        }
        notifyListenersSafe();
      },
      onFailure: (failure) {
        _ordersState = ErrorState.fromFailure(failure);
        notifyListenersSafe();
      },
    );
  }

  /// Load store orders.
  Future<void> loadStoreOrders(String storeId) async {
    _ordersState = const LoadingState();
    notifyListenersSafe();

    final result = await _orderRepository.getStoreOrders(
      storeId: storeId,
      status: _statusFilter,
    );

    result.fold(
      onSuccess: (orders) {
        if (orders.isEmpty) {
          _ordersState = const EmptyState(message: 'No orders found');
        } else {
          _ordersState = SuccessState(orders);
        }
        notifyListenersSafe();
      },
      onFailure: (failure) {
        _ordersState = ErrorState.fromFailure(failure);
        notifyListenersSafe();
      },
    );
  }

  /// Load rider orders.
  Future<void> loadRiderOrders(String riderId) async {
    _ordersState = const LoadingState();
    notifyListenersSafe();

    final result = await _orderRepository.getRiderOrders(
      riderId: riderId,
      status: _statusFilter,
    );

    result.fold(
      onSuccess: (orders) {
        if (orders.isEmpty) {
          _ordersState = const EmptyState(message: 'No orders found');
        } else {
          _ordersState = SuccessState(orders);
        }
        notifyListenersSafe();
      },
      onFailure: (failure) {
        _ordersState = ErrorState.fromFailure(failure);
        notifyListenersSafe();
      },
    );
  }

  /// Update order status.
  Future<bool> updateStatus({
    required String orderId,
    required OrderStatus newStatus,
    required String updatedBy,
    required UserRole updaterRole,
    String? note,
    String? cancellationReason,
  }) async {
    setOperationLoading('updateStatus', true);

    final result = await _updateOrderStatus(UpdateOrderStatusParams(
      orderId: orderId,
      newStatus: newStatus,
      updatedBy: updatedBy,
      updaterRole: updaterRole,
      note: note,
      cancellationReason: cancellationReason,
    ));

    setOperationLoading('updateStatus', false);

    return result.fold(
      onSuccess: (updateResult) {
        _currentOrder = updateResult.order;
        _orderState = SuccessState(updateResult.order);
        notifyListenersSafe();
        return true;
      },
      onFailure: (failure) {
        setErrorFromFailure(failure);
        return false;
      },
    );
  }

  /// Accept an order (for stores).
  Future<bool> acceptOrder(String orderId, String storeId) {
    return updateStatus(
      orderId: orderId,
      newStatus: OrderStatus.accepted,
      updatedBy: storeId,
      updaterRole: UserRole.store,
    );
  }

  /// Start preparing an order (for stores).
  Future<bool> startPreparing(String orderId, String storeId) {
    return updateStatus(
      orderId: orderId,
      newStatus: OrderStatus.preparing,
      updatedBy: storeId,
      updaterRole: UserRole.store,
    );
  }

  /// Mark order as picked up (for riders).
  Future<bool> markAsPickedUp(String orderId, String riderId) {
    return updateStatus(
      orderId: orderId,
      newStatus: OrderStatus.pickedUp,
      updatedBy: riderId,
      updaterRole: UserRole.delivery,
    );
  }

  /// Mark shop as paid (for riders).
  Future<bool> markShopPaid(String orderId, String riderId) {
    return updateStatus(
      orderId: orderId,
      newStatus: OrderStatus.shopPaid,
      updatedBy: riderId,
      updaterRole: UserRole.delivery,
    );
  }

  /// Complete an order (for admin).
  Future<bool> completeOrder(String orderId, String adminId) {
    return updateStatus(
      orderId: orderId,
      newStatus: OrderStatus.completed,
      updatedBy: adminId,
      updaterRole: UserRole.admin,
    );
  }

  /// Cancel an order.
  Future<bool> cancelOrder({
    required String orderId,
    required String cancelledBy,
    required UserRole cancellerRole,
    required String reason,
  }) {
    return updateStatus(
      orderId: orderId,
      newStatus: OrderStatus.cancelled,
      updatedBy: cancelledBy,
      updaterRole: cancellerRole,
      cancellationReason: reason,
    );
  }

  /// Set status filter.
  void setStatusFilter(OrderStatus? status) {
    _statusFilter = status;
    notifyListenersSafe();
  }

  /// Clear current order.
  void clearCurrentOrder() {
    _currentOrder = null;
    _lastPlaceOrderResult = null;
    _orderState = const InitialState();
    notifyListenersSafe();
  }

  // ============ VALIDATION ============

  bool _validateOrderFields() {
    if (_cartItems.isEmpty) {
      setError('Cart is empty');
      return false;
    }

    if (_selectedStoreId == null) {
      setError('No store selected');
      return false;
    }

    if (_deliveryAddress.isEmpty) {
      setError('Delivery address is required');
      return false;
    }

    return true;
  }

  void _clearOrderFields() {
    _deliveryAddress = '';
    _deliveryLandmark = '';
    _deliveryArea = '';
    _customerNotes = '';
    _pointsToRedeem = 0;
  }

  /// Reset view model state.
  @override
  void reset() {
    super.reset();
    _currentOrder = null;
    _lastPlaceOrderResult = null;
    _orderState = const InitialState();
    _ordersState = const InitialState();
    _cartItems.clear();
    _selectedStoreId = null;
    _clearOrderFields();
    _statusFilter = null;
    resetPagination();
  }
}

/// Cart item model for order creation.
class CartItem {
  final Product product;
  final int quantity;
  final String? note;

  const CartItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  double get totalPrice => product.effectivePrice * quantity;

  CartItem copyWith({
    Product? product,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  /// Convert to OrderItemInput for use case.
  OrderItemInput toOrderItemInput() {
    return OrderItemInput(
      productId: product.id,
      productName: product.name,
      price: product.effectivePrice,
      quantity: quantity,
      notes: note,
    );
  }
}