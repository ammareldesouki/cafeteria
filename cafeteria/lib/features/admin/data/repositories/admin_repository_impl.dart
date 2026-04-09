import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/paginated_orders_entity.dart';
import '../../domain/repositories/admin_repository.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../data_sources/admin_remote_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminRemoteDataSource remoteDataSource;

  AdminRepositoryImpl(this.remoteDataSource);

  @override
  Future<DashboardAnalyticsEntity> getDashboardAnalytics() =>
      remoteDataSource.getDashboardAnalytics();

  @override
  Future<PaginatedOrdersEntity> getAdminOrders({
    required int page,
    required int limit,
    String? search,
    String? dateRange,
    String? status,
    String? paymentStatus,
  }) => remoteDataSource.getAdminOrders(
    page: page,
    limit: limit,
    search: search,
    dateRange: dateRange,
    status: status,
    paymentStatus: paymentStatus,
  );

  @override
  Future<OrderEntity> updateAdminOrder({
    required String orderId,
    String? status,
    String? paymentStatus,
  }) => remoteDataSource.updateAdminOrder(
    orderId: orderId,
    status: status,
    paymentStatus: paymentStatus,
  );
}
