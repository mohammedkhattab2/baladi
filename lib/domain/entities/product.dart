/// Product entity in the Baladi application.
/// 
/// This is a pure domain entity representing a product
/// that a store sells through the platform.
/// 
/// Architecture note: Entities are immutable value objects that
/// represent core business concepts.
library;
/// Represents a product in the system.
class Product {
  /// Unique identifier for the product.
  final String id;

  /// Store ID that owns this product.
  final String storeId;

  /// Product name in English.
  final String name;

  /// Product name in Arabic (optional).
  final String? nameAr;

  /// Product description.
  final String? description;

  /// Product price in EGP.
  final double price;

  /// Discounted price if on sale (optional).
  final double? discountPrice;

  /// Product image URL.
  final String? imageUrl;

  /// Product category within the store.
  final String? category;

  /// Whether the product is currently available.
  final bool isAvailable;

  /// Sort order for display.
  final int sortOrder;

  /// When the product was created.
  final DateTime createdAt;

  /// When the product was last updated.
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.storeId,
    required this.name,
    this.nameAr,
    this.description,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    this.category,
    this.isAvailable = true,
    this.sortOrder = 0,
    required this.createdAt,
    this.updatedAt,
  });

  /// Creates a copy of this product with the given fields replaced.
  Product copyWith({
    String? id,
    String? storeId,
    String? name,
    String? nameAr,
    String? description,
    double? price,
    double? discountPrice,
    String? imageUrl,
    String? category,
    bool? isAvailable,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      name: name ?? this.name,
      nameAr: nameAr ?? this.nameAr,
      description: description ?? this.description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      isAvailable: isAvailable ?? this.isAvailable,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Returns the effective price (discount or regular).
  double get effectivePrice => discountPrice ?? price;

  /// Returns true if the product is on sale.
  bool get isOnSale => discountPrice != null && discountPrice! < price;

  /// Returns the discount percentage if on sale.
  double? get discountPercentage {
    if (!isOnSale) return null;
    return ((price - discountPrice!) / price) * 100;
  }

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
    return other is Product && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Product(id: $id, name: $name, price: $price)';
}