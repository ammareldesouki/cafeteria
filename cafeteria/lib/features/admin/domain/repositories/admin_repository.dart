import '../../../home/domain/entities/menu_item_entity.dart';
import '../../../order/domain/entities/order_entity.dart';
import '../entities/analytics_entity.dart';
import '../entities/paginated_orders_entity.dart';

abstract class AdminRepository {
  Future<DashboardAnalyticsEntity> getDashboardAnalytics();

  Future<PaginatedOrdersEntity> getAdminOrders({
    required int page,
    required int limit,
    String? search,
    String? dateRange,
    String? status,
    String? paymentStatus,
  });

  Future<OrderEntity> updateAdminOrder({
    required String orderId,
    String? status,
    String? paymentStatus,
  });

  // Menu Management
  Future<List<MenuItemEntity>> getAdminMenuItems();

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
  });

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
  });

  Future<void> deleteMenuItem(String itemId);

  Future<MenuItemEntity> setItemStock({
    required String itemId,
    required int stock,
  });

  Future<MenuItemEntity> setVariantStock({
    required String itemId,
    required String variantName,
    required int stock,
  });

  Future<MenuItemEntity> addVariant({
    required String itemId,
    required String name,
    required int stock,
  });

  Future<MenuItemEntity> removeVariant({
    required String itemId,
    required String variantName,
  });
}
