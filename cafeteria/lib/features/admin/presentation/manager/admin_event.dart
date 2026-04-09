abstract class AdminEvent {}

class LoadDashboardDataEvent extends AdminEvent {}

class PollDashboardDataEvent extends AdminEvent {}

class FetchAdminOrdersEvent extends AdminEvent {
  final int page;
  final int limit;
  final String? search;
  final String? dateRange;
  final String? status;
  final String? paymentStatus;

  FetchAdminOrdersEvent({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.dateRange,
    this.status,
    this.paymentStatus,
  });
}

class UpdateAdminOrderEvent extends AdminEvent {
  final String orderId;
  final String? status;
  final String? paymentStatus;

  UpdateAdminOrderEvent({
    required this.orderId,
    this.status,
    this.paymentStatus,
  });
}
