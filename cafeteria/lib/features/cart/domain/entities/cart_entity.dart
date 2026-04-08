class CartItemEntity {
  final String id;
  final String menuItemId;
  final String menuItemName;
  final String image;
  final String? variantName;
  final String? note;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  /// Available stock. null = unlimited (hot drinks, trackStock: false).
  final int? stock;

  /// Whether stock is tracked for this item.
  final bool trackStock;

  const CartItemEntity({
    required this.id,
    required this.menuItemId,
    required this.menuItemName,
    required this.image,
    this.variantName,
    this.note,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.stock,
    this.trackStock = true,
  });
}

class CartEntity {
  final String id;
  final List<CartItemEntity> items;
  final int totalItems;
  final double totalPrice;

  const CartEntity({
    required this.id,
    required this.items,
    required this.totalItems,
    required this.totalPrice,
  });

  CartEntity copyWith({
    String? id,
    List<CartItemEntity>? items,
    int? totalItems,
    double? totalPrice,
  }) =>
      CartEntity(
        id: id ?? this.id,
        items: items ?? this.items,
        totalItems: totalItems ?? this.totalItems,
        totalPrice: totalPrice ?? this.totalPrice,
      );
}
