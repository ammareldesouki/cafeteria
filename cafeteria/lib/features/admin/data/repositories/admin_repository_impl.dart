import '../../../home/domain/entities/menu_item_entity.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/paginated_orders_entity.dart';
import '../../domain/entities/pending_user_entity.dart';
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
  Future<PendingUsersResult> getPendingUsers() =>
      remoteDataSource.getPendingUsers();

  @override
  Future<void> settleUserDebt({required String userId, double? amount}) =>
      remoteDataSource.settleUserDebt(userId: userId, amount: amount);

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

  @override
  Future<List<MenuItemEntity>> getAdminMenuItems() =>
      remoteDataSource.getAdminMenuItems();

  @override
  Future<MenuItemEntity> createMenuItem({
    required String name,
    required double price,
    required String category,
    required String description,
    required String image,
    required bool hasVariants,
    required int stock,
    List<VariantEntity>? variants,
    bool? hasSugar,
  }) => remoteDataSource.createMenuItem(
    name: name,
    price: price,
    category: category,
    description: description,
    image: image,
    hasVariants: hasVariants,
    stock: stock,
    variants: variants
        ?.map((v) => {'name': v.name, 'stock': v.stock ?? 0})
        .toList(),
    hasSugar: hasSugar,
  );

  @override
  Future<MenuItemEntity> updateMenuItem({
    required String itemId,
    String? name,
    double? price,
    String? category,
    String? description,
    String? image,
    bool? hasVariants,
    List<VariantEntity>? variants,
    bool? hasSugar,
  }) => remoteDataSource.updateMenuItem(
    itemId: itemId,
    name: name,
    price: price,
    category: category,
    description: description,
    image: image,
    hasVariants: hasVariants,
    variants: variants
        ?.map((v) => {'name': v.name, 'stock': v.stock ?? 0})
        .toList(),
    hasSugar: hasSugar,
  );

  @override
  Future<void> deleteMenuItem(String itemId) =>
      remoteDataSource.deleteMenuItem(itemId);

  @override
  Future<MenuItemEntity> setItemStock({
    required String itemId,
    required int stock,
  }) => remoteDataSource.setItemStock(itemId: itemId, stock: stock);

  @override
  Future<MenuItemEntity> setVariantStock({
    required String itemId,
    required String variantName,
    required int stock,
  }) => remoteDataSource.setVariantStock(
    itemId: itemId,
    variantName: variantName,
    stock: stock,
  );

  @override
  Future<MenuItemEntity> addVariant({
    required String itemId,
    required String name,
    required int stock,
  }) => remoteDataSource.addVariant(itemId: itemId, name: name, stock: stock);

  @override
  Future<MenuItemEntity> removeVariant({
    required String itemId,
    required String variantName,
  }) =>
      remoteDataSource.removeVariant(itemId: itemId, variantName: variantName);
}
