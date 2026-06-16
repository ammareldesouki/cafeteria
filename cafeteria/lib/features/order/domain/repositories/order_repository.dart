import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder({
    required String? deliveryLocation,
    String? note,
    DateTime? scheduledFor,
  });
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> getOrderById(String orderId);
  Future<OrderEntity> cancelOrder(String orderId);
}
