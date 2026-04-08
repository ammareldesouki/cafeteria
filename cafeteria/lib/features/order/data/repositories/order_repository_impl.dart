import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../data_sources/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;

  OrderRepositoryImpl(this.remoteDataSource);

  @override
  Future<OrderEntity> createOrder({required String? deliveryLocation}) =>
      remoteDataSource.createOrder(deliveryLocation: deliveryLocation);

  @override
  Future<List<OrderEntity>> getOrders() => remoteDataSource.getOrders();

  @override
  Future<OrderEntity> getOrderById(String orderId) =>
      remoteDataSource.getOrderById(orderId);

  @override
  Future<OrderEntity> cancelOrder(String orderId) =>
      remoteDataSource.cancelOrder(orderId);
}
