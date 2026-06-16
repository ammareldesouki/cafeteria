abstract class OrderEvent {}

class CreateOrderEvent extends OrderEvent {
  final String? deliveryLocation;
  final String? note;
  final DateTime? scheduledFor;

  CreateOrderEvent({this.deliveryLocation, this.note, this.scheduledFor});
}

class GetOrdersEvent extends OrderEvent {}

class RefreshOrdersEvent extends OrderEvent {}

class CancelOrderEvent extends OrderEvent {
  final String orderId;
  CancelOrderEvent(this.orderId);
}

/// Poll a single order for status updates
class PollOrderStatusEvent extends OrderEvent {
  final String orderId;
  PollOrderStatusEvent(this.orderId);
}
