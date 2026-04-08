import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> createOrder({required String? deliveryLocation});
  Future<List<OrderEntity>> getOrders();
  Future<OrderEntity> getOrderById(String orderId);
  Future<OrderEntity> cancelOrder(String orderId);
}
