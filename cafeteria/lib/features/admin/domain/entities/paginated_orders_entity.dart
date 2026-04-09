import '../../../order/data/models/order_model.dart';
import '../../../order/domain/entities/order_entity.dart';

class PaginatedOrdersEntity {
  final List<OrderEntity> data;
  final int totalCount;
  final int page;
  final int limit;
  final int totalPages;

  const PaginatedOrdersEntity({
    required this.data,
    required this.totalCount,
    required this.page,
    required this.limit,
    required this.totalPages,
  });
}

class PaginatedOrdersModel extends PaginatedOrdersEntity {
  const PaginatedOrdersModel({
    required super.data,
    required super.totalCount,
    required super.page,
    required super.limit,
    required super.totalPages,
  });

  factory PaginatedOrdersModel.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List<dynamic>? ?? [];
    return PaginatedOrdersModel(
      data: rawData
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalCount: (json['totalCount'] as num?)?.toInt() ?? 0,
      page: (json['page'] as num?)?.toInt() ?? 1,
      limit: (json['limit'] as num?)?.toInt() ?? 10,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
    );
  }
}
