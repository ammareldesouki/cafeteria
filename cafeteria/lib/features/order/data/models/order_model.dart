import '../../domain/entities/order_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.menuItemId,
    super.menuItemName,
    super.variantName,
    super.note,
    super.sugar,
    required super.quantity,
    required super.unitPrice,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) => OrderItemModel(
        menuItemId: json['menuItemId']?.toString() ?? '',
        menuItemName: json['menuItemName'] as String?,
        variantName: json['variantName'] as String?,
        note: json['note'] as String?,
        sugar: (json['sugar'] as num?)?.toInt(),
        quantity: (json['quantity'] as num).toInt(),
        unitPrice: (json['unitPrice'] as num).toDouble(),
      );
}

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.userId,
    super.userName,
    super.userPhone,
    required super.userEmail,
    required super.items,
    required super.totalPrice,
    super.deliveryLocation,
    required super.status,
    required super.paymentStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    return OrderModel(
      id: json['_id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      userName: json['username']?.toString(),
      userPhone: json['userPhone']?.toString(),
      userEmail: json['userEmail']?.toString() ?? '',
      items: rawItems
          .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      deliveryLocation: json['deliveryLocation'] as String?,
      status: json['status']?.toString() ?? 'pending',
      paymentStatus: json['paymentStatus']?.toString() ?? 'unpaid',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'].toString())
          : DateTime.now(),
    );
  }
}
