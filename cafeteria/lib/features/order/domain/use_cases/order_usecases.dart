import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class CreateOrderUseCase {
  final OrderRepository _repository;
  CreateOrderUseCase(this._repository);

  Future<OrderEntity> call({required String? deliveryLocation}) =>
      _repository.createOrder(deliveryLocation: deliveryLocation);
}

class GetOrdersUseCase {
  final OrderRepository _repository;
  GetOrdersUseCase(this._repository);

  Future<List<OrderEntity>> call() => _repository.getOrders();
}

class GetOrderByIdUseCase {
  final OrderRepository _repository;
  GetOrderByIdUseCase(this._repository);

  Future<OrderEntity> call(String orderId) =>
      _repository.getOrderById(orderId);
}

class CancelOrderUseCase {
  final OrderRepository _repository;
  CancelOrderUseCase(this._repository);

  Future<OrderEntity> call(String orderId) =>
      _repository.cancelOrder(orderId);
}
