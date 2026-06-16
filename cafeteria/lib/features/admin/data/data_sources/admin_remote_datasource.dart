import 'package:cafeteria/core/network/dio_handler.dart';
import '../../../home/data/models/menu_item_model.dart';
import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/paginated_orders_entity.dart';
import '../../domain/entities/pending_user_entity.dart';
import '../../../order/data/models/order_model.dart';

abstract class AdminRemoteDataSource {
  Future<DashboardAnalyticsModel> getDashboardAnalytics();

  Future<PendingUsersResult> getPendingUsers();

  Future<void> settleUserDebt({required String userId, double? amount});

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

  Future<List<MenuItemModel>> getAdminMenuItems();

  Future<MenuItemModel> createMenuItem({
    required String name,
    required double price,
    required String category,
    required String description,
    required String image,
    required bool hasVariants,
    required int stock,
    List<Map<String, dynamic>>? variants,
    bool? hasSugar,
  });

  Future<MenuItemModel> updateMenuItem({
    required String itemId,
    String? name,
    double? price,
    String? category,
    String? description,
    String? image,
    bool? hasVariants,
    List<Map<String, dynamic>>? variants,
    bool? hasSugar,
  });

  Future<void> deleteMenuItem(String itemId);

  Future<MenuItemModel> setItemStock({
    required String itemId,
    required int stock,
  });

  Future<MenuItemModel> setVariantStock({
    required String itemId,
    required String variantName,
    required int stock,
  });

  Future<MenuItemModel> addVariant({
    required String itemId,
    required String name,
    required int stock,
  });

  Future<MenuItemModel> removeVariant({
    required String itemId,
    required String variantName,
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
  Future<PendingUsersResult> getPendingUsers() async {
    final response = await _dioHandler.dio.get('/admin/pending-users');
    final data = response.data as Map<String, dynamic>;
    final users = (data['users'] as List<dynamic>? ?? [])
        .map((e) {
          final m = e as Map<String, dynamic>;
          return PendingUserEntity(
            userId: m['userId']?.toString() ?? '',
            username: m['username']?.toString() ?? '',
            pendingAmount: (m['pendingAmount'] as num? ?? 0).toDouble(),
            unpaidOrders: (m['unpaidOrders'] as num? ?? 0).toInt(),
          );
        })
        .toList();
    return PendingUsersResult(
      totalPending: (data['totalPending'] as num? ?? 0).toDouble(),
      userCount: (data['userCount'] as num? ?? 0).toInt(),
      users: users,
    );
  }

  @override
  Future<void> settleUserDebt({required String userId, double? amount}) async {
    await _dioHandler.dio.post(
      '/admin/users/$userId/settle',
      data: {if (amount != null) 'amount': amount},
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

  @override
  Future<List<MenuItemModel>> getAdminMenuItems() async {
    final response = await _dioHandler.dio.get('/admin/menu');
    final List data = response.data as List;
    return data
        .map((e) => MenuItemModel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MenuItemModel> createMenuItem({
    required String name,
    required double price,
    required String category,
    required String description,
    required String image,
    required bool hasVariants,
    required int stock,
    List<Map<String, dynamic>>? variants,
    bool? hasSugar,
  }) async {
    final body = {
      'name': name,
      'price': price,
      'category': category,
      'description': description,
      'image': image,
      'hasVariants': hasVariants,
      'stock': stock,
    };
    if (variants != null) body['variants'] = variants;
    if (hasSugar != null) body['hasSugar'] = hasSugar;

    final response = await _dioHandler.dio.post('/admin/menu', data: body);
    return MenuItemModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<MenuItemModel> updateMenuItem({
    required String itemId,
    String? name,
    double? price,
    String? category,
    String? description,
    String? image,
    bool? hasVariants,
    List<Map<String, dynamic>>? variants,
    bool? hasSugar,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (price != null) body['price'] = price;
    if (category != null) body['category'] = category;
    if (description != null) body['description'] = description;
    if (image != null) body['image'] = image;
    if (hasVariants != null) body['hasVariants'] = hasVariants;
    if (variants != null) body['variants'] = variants;
    if (hasSugar != null) body['hasSugar'] = hasSugar;

    final response = await _dioHandler.dio.put(
        '/admin/menu/$itemId', data: body);
    return MenuItemModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMenuItem(String itemId) async {
    await _dioHandler.dio.delete('/admin/menu/$itemId');
  }

  @override
  Future<MenuItemModel> setItemStock({
    required String itemId,
    required int stock,
  }) async {
    final response = await _dioHandler.dio.patch(
      '/admin/menu/$itemId/stock',
      data: {'stock': stock},
    );
    return MenuItemModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<MenuItemModel> setVariantStock({
    required String itemId,
    required String variantName,
    required int stock,
  }) async {
    final response = await _dioHandler.dio.patch(
      '/admin/menu/$itemId/variants/${Uri.encodeComponent(variantName)}/stock',
      data: {'stock': stock},
    );
    return MenuItemModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<MenuItemModel> addVariant({
    required String itemId,
    required String name,
    required int stock,
  }) async {
    final response = await _dioHandler.dio.post(
      '/admin/menu/$itemId/variants',
      data: {'name': name, 'stock': stock},
    );
    return MenuItemModel.fromMap(response.data as Map<String, dynamic>);
  }

  @override
  Future<MenuItemModel> removeVariant({
    required String itemId,
    required String variantName,
  }) async {
    final response = await _dioHandler.dio.delete(
      '/admin/menu/$itemId/variants/${Uri.encodeComponent(variantName)}',
    );
    return MenuItemModel.fromMap(response.data as Map<String, dynamic>);
  }
}
