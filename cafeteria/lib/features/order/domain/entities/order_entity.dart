class OrderItemEntity {
  final String menuItemId;
  final String? menuItemName;
  final String? variantName;
  final String? note;
  final int quantity;
  final double unitPrice;

  const OrderItemEntity({
    required this.menuItemId,
    this.menuItemName,
    this.variantName,
    this.note,
    required this.quantity,
    required this.unitPrice,
  });

  double get subtotal => unitPrice * quantity;
}

class OrderEntity {
  final String id;
  final String userId;
  final String? userName;
  final String? userPhone;
  final String userEmail;
  final List<OrderItemEntity> items;
  final double totalPrice;
  final String? deliveryLocation;
  final String status;
  final String paymentStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderEntity({
    required this.id,
    required this.userId,
    this.userName,
    this.userPhone,
    required this.userEmail,
    required this.items,
    required this.totalPrice,
    this.deliveryLocation,
    required this.status,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isPending => status == 'pending';
  bool get isProcessing => status == 'processing';
  bool get isCompleted => status == 'completed';
  bool get isDelivered => status == 'delivered';
  bool get isCancelled => status == 'cancelled';
  bool get canCancel => status == 'pending';
}
