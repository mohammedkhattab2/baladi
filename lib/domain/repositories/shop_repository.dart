// Domain - Shop repository interface.
//
// Defines the contract for shop-related operations including
// shop details, management, dashboard, and settlements.

import '../../core/result/result.dart';
import '../entities/product.dart';
import '../entities/shop.dart';
import '../entities/shop_settlement.dart';

/// Dashboard statistics for a shop owner.
class ShopDashboard {
  /// Total orders in the current period.
  final int totalOrders;

  /// Completed orders in the current period.
  final int completedOrders;

  /// Cancelled orders in the current period.
  final int cancelledOrders;

  /// Pending orders awaiting action.
  final int pendingOrders;

  /// Total revenue (gross sales) in the current period.
  final double totalRevenue;

  /// Total commission paid in the current period.
  final double totalCommission;

  /// Net earnings in the current period.
  final double netEarnings;

  /// Creates a [ShopDashboard].
  const ShopDashboard({
    required this.totalOrders,
    required this.completedOrders,
    required this.cancelledOrders,
    required this.pendingOrders,
    required this.totalRevenue,
    required this.totalCommission,
    required this.netEarnings,
  });
}

/// Repository contract for shop-related operations.
///
/// Handles shop details retrieval (customer-facing), shop profile
/// management (shop owner), product management, and settlements.
abstract class ShopRepository {
  // ── Customer-facing ──

  /// Fetches details of a specific shop.
  ///
  /// - [shopId]: The shop's unique identifier.
  Future<Result<Shop>> getShopDetails(String shopId);

  /// Fetches products for a specific shop.
  ///
  /// - [shopId]: The shop's unique identifier.
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Product>>> getShopProducts({
    required String shopId,
    int page = 1,
    int perPage = 20,
  });

  // ── Shop owner management ──

  /// Fetches the current shop owner's profile.
  Future<Result<Shop>> getShopProfile();

  /// Updates the shop's open/closed status.
  ///
  /// - [isOpen]: Whether the shop is accepting orders.
  Future<Result<Shop>> updateShopStatus({required bool isOpen});

  /// Fetches the shop owner's dashboard statistics.
  Future<Result<ShopDashboard>> getShopDashboard();

  /// Fetches the shop's products (owner view with all products).
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<Product>>> getOwnProducts({
    int page = 1,
    int perPage = 20,
  });

  /// Creates a new product in the shop.
  ///
  /// - [name]: Product name.
  /// - [nameAr]: Arabic product name (optional).
  /// - [description]: Product description (optional).
  /// - [price]: Product price in EGP.
  /// - [imageUrl]: Product image URL (optional).
  Future<Result<Product>> createProduct({
    required String name,
    String? nameAr,
    String? description,
    required double price,
    String? imageUrl,
  });

  /// Updates an existing product.
  ///
  /// - [productId]: The product's unique identifier.
  /// - All other fields are optional updates.
  Future<Result<Product>> updateProduct({
    required String productId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    String? imageUrl,
    bool? isAvailable,
  });

  /// Deletes a product from the shop.
  ///
  /// - [productId]: The product's unique identifier.
  Future<Result<void>> deleteProduct(String productId);

  /// Fetches the shop's settlement history.
  ///
  /// - [page]: Page number for pagination (1-based).
  /// - [perPage]: Number of items per page.
  Future<Result<List<ShopSettlement>>> getSettlements({
    int page = 1,
    int perPage = 20,
  });
}