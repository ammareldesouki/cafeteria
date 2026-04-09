import '../entities/analytics_entity.dart';
import '../entities/paginated_orders_entity.dart';
import '../repositories/admin_repository.dart';
import '../../../order/domain/entities/order_entity.dart';

class GetDashboardAnalyticsUseCase {
  final AdminRepository _repository;

  GetDashboardAnalyticsUseCase(this._repository);

  Future<DashboardAnalyticsEntity> call() =>
      _repository.getDashboardAnalytics();
}

class GetAdminOrdersUseCase {
  final AdminRepository _repository;

  GetAdminOrdersUseCase(this._repository);

  Future<PaginatedOrdersEntity> call({
    required int page,
    required int limit,
    String? search,
    String? dateRange,
    String? status,
    String? paymentStatus,
  }) => _repository.getAdminOrders(
    page: page,
    limit: limit,
    search: search,
    dateRange: dateRange,
    status: status,
    paymentStatus: paymentStatus,
  );
}

class UpdateAdminOrderUseCase {
  final AdminRepository _repository;

  UpdateAdminOrderUseCase(this._repository);

  Future<OrderEntity> call({
    required String orderId,
    String? status,
    String? paymentStatus,
  }) => _repository.updateAdminOrder(
    orderId: orderId,
    status: status,
    paymentStatus: paymentStatus,
  );
}
