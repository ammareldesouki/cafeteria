class DashboardAnalyticsEntity {
  final int activeOrders;
  final int totalOrders;
  final double totalRevenue;
  final double pendingRevenue;

  const DashboardAnalyticsEntity({
    required this.activeOrders,
    required this.totalOrders,
    required this.totalRevenue,
    required this.pendingRevenue,
  });
}

class DashboardAnalyticsModel extends DashboardAnalyticsEntity {
  const DashboardAnalyticsModel({
    required super.activeOrders,
    required super.totalOrders,
    required super.totalRevenue,
    required super.pendingRevenue,
  });

  factory DashboardAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return DashboardAnalyticsModel(
      activeOrders: (json['activeOrders'] as num?)?.toInt() ?? 0,
      totalOrders: (json['totalOrders'] as num?)?.toInt() ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      pendingRevenue: (json['pendingRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
