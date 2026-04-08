import '../../domain/entities/order_entity.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

/// Order list loaded
class OrdersLoaded extends OrderState {
  final List<OrderEntity> orders;
  OrdersLoaded(this.orders);
}

/// Order is being created (placing)
class OrderPlacing extends OrderState {}

/// Order created successfully
class OrderPlaced extends OrderState {
  final OrderEntity order;
  OrderPlaced(this.order);
}

/// An order was cancelled
class OrderCancelled extends OrderState {
  final OrderEntity order;
  OrderCancelled(this.order);
}

/// Action in progress while list is visible
class OrderActionLoading extends OrderState {
  final List<OrderEntity> orders;
  final String? actionOrderId;
  OrderActionLoading(this.orders, {this.actionOrderId});
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}
