import '../../domain/entities/order_entity.dart';

class OrderItemExtraModel extends OrderItemExtraEntity {
  const OrderItemExtraModel({required super.name, required super.price});

  factory OrderItemExtraModel.fromJson(Map<String, dynamic> json) =>
      OrderItemExtraModel(
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
      );
}

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.menuItemId,
    super.menuItemName,
    super.variantName,
    super.note,
    super.sugar,
    required super.quantity,
    required super.unitPrice,
    super.selectedExtras,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    final rawExtras = json['selectedExtras'] as List<dynamic>?;
    return OrderItemModel(
      menuItemId: json['menuItemId']?.toString() ?? '',
      menuItemName: json['menuItemName'] as String?,
      variantName: json['variantName'] as String?,
      note: json['note'] as String?,
      sugar: (json['sugar'] as num?)?.toInt(),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      selectedExtras: rawExtras != null && rawExtras.isNotEmpty
          ? rawExtras
              .map((e) =>
                  OrderItemExtraModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
    );
  }
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
    super.note,
    super.scheduledFor,
    required super.status,
    required super.paymentStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'] as List<dynamic>? ?? [];
    final rawScheduled = json['scheduledFor'] as String?;
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
      note: json['note'] as String?,
      scheduledFor: rawScheduled != null ? DateTime.parse(rawScheduled) : null,
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
