import 'package:cafeteria/core/network/dio_handler.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({required String? deliveryLocation});
  Future<List<OrderModel>> getOrders();
  Future<OrderModel> getOrderById(String orderId);
  Future<OrderModel> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final NetworkDioHandler _dioHandler;

  OrderRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<OrderModel> createOrder({required String? deliveryLocation}) async {
    final body = <String, dynamic>{};
    if (deliveryLocation != null && deliveryLocation.isNotEmpty) {
      body['deliveryLocation'] = deliveryLocation;
    }

    final response = await _dioHandler.dio.post('/orders', data: body);
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<List<OrderModel>> getOrders() async {
    final response = await _dioHandler.dio.get('/orders');
    final data = response.data as List<dynamic>;
    return data
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    final response = await _dioHandler.dio.get('/orders/$orderId');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> cancelOrder(String orderId) async {
    final response = await _dioHandler.dio.post('/orders/$orderId/cancel');
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
