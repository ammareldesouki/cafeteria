import '../../domain/entities/cart_entity.dart';

class CartItemModel extends CartItemEntity {
  const CartItemModel({
    required super.id,
    required super.menuItemId,
    required super.menuItemName,
    required super.image,
    super.variantName,
    super.note,
    super.sugar,
    required super.quantity,
    required super.unitPrice,
    required super.subtotal,
    super.stock,
    super.trackStock,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) => CartItemModel(
    id: json['id'] as String,
    menuItemId: json['menuItemId'] as String,
    menuItemName: json['menuItemName'] as String,
    image: json['image'] as String? ?? '',
    variantName: json['variantName'] as String?,
    note: json['note'] as String?,
    sugar: (json['sugar'] as num?)?.toInt(),
    quantity: (json['quantity'] as num).toInt(),
    unitPrice: (json['unitPrice'] as num).toDouble(),
    subtotal: (json['subtotal'] as num).toDouble(),
    stock: (json['stock'] as num?)?.toInt(),
    trackStock: json['trackStock'] as bool? ?? true,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'menuItemId': menuItemId,
    'menuItemName': menuItemName,
    'image': image,
    if (variantName != null) 'variantName': variantName,
    if (note != null) 'note': note,
    if (sugar != null) 'sugar': sugar,
    'quantity': quantity,
    'unitPrice': unitPrice,
    'subtotal': subtotal,
    if (stock != null) 'stock': stock,
    'trackStock': trackStock,
  };
}

class CartModel extends CartEntity {
  const CartModel({
    required super.id,
    required super.items,
    required super.totalItems,
    required super.totalPrice,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return CartModel(
      id: data['id'] as String,
      items: rawItems
          .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalItems: (data['totalItems'] as num).toInt(),
      totalPrice: (data['totalPrice'] as num).toDouble(),
    );
  }
}
