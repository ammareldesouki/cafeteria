import '../../domain/entities/analytics_entity.dart';
import '../../domain/entities/paginated_orders_entity.dart';

abstract class AdminState {}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final DashboardAnalyticsEntity analytics;
  final PaginatedOrdersEntity orders;
  final String? activeSearch;
  final String? activeDateRange;
  final String? activeStatus;
  final String? activePaymentStatus;

  AdminDashboardLoaded({
    required this.analytics,
    required this.orders,
    this.activeSearch,
    this.activeDateRange,
    this.activeStatus,
    this.activePaymentStatus,
  });

  AdminDashboardLoaded copyWith({
    DashboardAnalyticsEntity? analytics,
    PaginatedOrdersEntity? orders,
    String? activeSearch,
    String? activeDateRange,
    String? activeStatus,
    String? activePaymentStatus,
  }) {
    return AdminDashboardLoaded(
      analytics: analytics ?? this.analytics,
      orders: orders ?? this.orders,
      activeSearch: activeSearch ?? this.activeSearch,
      activeDateRange: activeDateRange ?? this.activeDateRange,
      activeStatus: activeStatus ?? this.activeStatus,
      activePaymentStatus: activePaymentStatus ?? this.activePaymentStatus,
    );
  }
}

class AdminError extends AdminState {
  final String message;

  AdminError(this.message);
}
