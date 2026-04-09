import 'package:cafeteria/core/network/dio_handler.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/paginated_orders_entity.dart';
import '../../../order/data/models/order_model.dart';

abstract class AdminRemoteDataSource {
  Future<DashboardAnalyticsModel> getDashboardAnalytics();

  Future<PaginatedOrdersModel> getAdminOrders({
    required int page,
    required int limit,
    String? search,
    String? dateRange,
    String? status,
    String? paymentStatus,
  });

  Future<OrderModel> updateAdminOrder({
    required String orderId,
    String? status,
    String? paymentStatus,
  });
}

class AdminRemoteDataSourceImpl implements AdminRemoteDataSource {
  final NetworkDioHandler _dioHandler;

  AdminRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<DashboardAnalyticsModel> getDashboardAnalytics() async {
    final response = await _dioHandler.dio.get('/admin/analytics');
    return DashboardAnalyticsModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }

  @override
  Future<PaginatedOrdersModel> getAdminOrders({
    required int page,
    required int limit,
    String? search,
    String? dateRange,
    String? status,
    String? paymentStatus,
  }) async {
    final queryParams = <String, dynamic>{'page': page, 'limit': limit};

    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (dateRange != null && dateRange.isNotEmpty)
      queryParams['dateRange'] = dateRange;
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (paymentStatus != null && paymentStatus.isNotEmpty)
      queryParams['paymentStatus'] = paymentStatus;

    final response = await _dioHandler.dio.get(
      '/admin/orders',
      queryParameters: queryParams,
    );
    return PaginatedOrdersModel.fromJson(response.data as Map<String, dynamic>);
  }

  @override
  Future<OrderModel> updateAdminOrder({
    required String orderId,
    String? status,
    String? paymentStatus,
  }) async {
    final body = <String, dynamic>{};
    if (status != null) body['status'] = status;
    if (paymentStatus != null) body['paymentStatus'] = paymentStatus;

    final response = await _dioHandler.dio.patch(
      '/admin/orders/$orderId',
      data: body,
    );
    return OrderModel.fromJson(response.data as Map<String, dynamic>);
  }
}
