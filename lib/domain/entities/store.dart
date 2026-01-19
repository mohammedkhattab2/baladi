/// Store entity in the Baladi application.
/// 
/// This is a pure domain entity representing a merchant/store
/// that sells products through the platform.
/// 
/// Architecture note: Entities are immutable value objects that
/// represent core business concepts.
library;
/// Represents a store/merchant in the system.
class Store {
  /// Unique identifier for the store.
  final String id;

  /// User ID associated with this store.
  final String userId;

  /// Store name in English.
  final String name;

  /// Store name in Arabic (optional).
  final String? nameAr;

  /// Category ID this store belongs to.
  final String categoryId;

  /// Store description.
  final String? description;

  /// Store phone number.
  final String? phone;

  /// Store address.
  final String? address;

  /// Store logo URL.
  final String? logoUrl;

  /// Store cover image URL.
  final String? coverImageUrl;

  /// Commission rate for this store (e.g., 0.10 for 10%).
  final double commissionRate;

  /// Minimum order amount required.
  final double minOrderAmount;

  /// Whether the store is currently open.
  final bool isOpen;

  /// Whether the store is active in the system.
  final bool isActive;

  /// Whether the store has been approved by admin.
  final bool isApproved;

  /// Store rating (0-5 scale).
  final double rating;

  /// Total number of completed orders.
  final int totalOrders;

  /// When the store was created.
  final DateTime createdAt;

  /// When the store was last updated.
  final DateTime? updatedAt;

  const Store({
    required this.id,
    required this.userId,
    required this.name,
    this.nameAr,
    required this.categoryId,
    this.description,
    this.phone,
    this.address,
    this.logoUrl,
    this.coverImageUrl,
    this.commissionRate = 0.10,
    this.minOrderAmount = 0,
    this.isOpen = true,
    this.isActive = true,
    this.isApproved = false,
    this.rating = 0,
    this.totalOrders = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this store with the given fields replaced.
  Store copyWith({
    String? id,
    String? userId,
    String? name,
    String? nameAr,
    String? categoryId,
    String? description,
    String? phone,
    String? address,
    String? logoUrl,
    String? coverImageUrl,
    double? commissionRate,
    double? minOrderAmount,
    bool? isOpen,
    bool? isActive,
    bool? isApproved,
    double? rating,
    int? totalOrders,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Store(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      categoryId: categoryId ?? this.categoryId,
      description: description ?? this.description,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      logoUrl: logoUrl ?? this.logoUrl,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      commissionRate: commissionRate ?? this.commissionRate,
      minOrderAmount: minOrderAmount ?? this.minOrderAmount,
      isOpen: isOpen ?? this.isOpen,
      isActive: isActive ?? this.isActive,
      isApproved: isApproved ?? this.isApproved,
      rating: rating ?? this.rating,
      totalOrders: totalOrders ?? this.totalOrders,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns true if the store can accept orders.
  bool get canAcceptOrders => isActive && isApproved && isOpen;

  /// Returns the display name based on locale preference.
  String displayName({bool preferArabic = false}) {
    if (preferArabic && nameAr != null && nameAr!.isNotEmpty) {
      return nameAr!;
    }
    return name;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Store && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Store(id: $id, name: $name)';
}