class OrderItemExtraEntity {
  final String name;
  final double price;

  const OrderItemExtraEntity({required this.name, required this.price});
}

class OrderItemEntity {
  final String menuItemId;
  final String? menuItemName;
  final String? variantName;
  final String? note;
  final int? sugar;
  final int quantity;
  final double unitPrice;
  final List<OrderItemExtraEntity>? selectedExtras;

  const OrderItemEntity({
    required this.menuItemId,
    this.menuItemName,
    this.variantName,
    this.note,
    this.sugar,
    required this.quantity,
    required this.unitPrice,
    this.selectedExtras,
  });

  double get extrasTotal =>
      (selectedExtras ?? []).fold<double>(0, (s, e) => s + e.price);

  double get subtotal => (unitPrice + extrasTotal) * quantity;
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
  final String? note;
  final DateTime? scheduledFor;
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
    this.note,
    this.scheduledFor,
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
