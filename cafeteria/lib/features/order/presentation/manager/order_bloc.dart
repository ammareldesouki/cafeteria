import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/use_cases/order_usecases.dart';
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final CancelOrderUseCase cancelOrderUseCase;

  Timer? _pollTimer;

  OrderBloc({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.cancelOrderUseCase,
  }) : super(OrderInitial()) {
    on<CreateOrderEvent>(_onCreateOrder);
    on<GetOrdersEvent>(_onGetOrders);
    on<RefreshOrdersEvent>(_onRefreshOrders);
    on<CancelOrderEvent>(_onCancelOrder);
    on<PollOrderStatusEvent>(_onPollOrderStatus);
  }

  List<OrderEntity>? get _currentOrders {
    final s = state;
    if (s is OrdersLoaded) return s.orders;
    if (s is OrderActionLoading) return s.orders;
    return null;
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        final errorObj = data['error'];
        if (errorObj is Map<String, dynamic>) {
          final msg = errorObj['message']?.toString() ?? '';
          if (msg.isNotEmpty) return msg;
        }
        final msg = data['message']?.toString();
        if (msg != null && msg.isNotEmpty) return msg;
      }
      return e.message ?? 'Network error';
    }
    return e.toString();
  }

  Future<void> _onCreateOrder(
      CreateOrderEvent event, Emitter<OrderState> emit) async {
    emit(OrderPlacing());
    try {
      final order = await createOrderUseCase(
        deliveryLocation: event.deliveryLocation,
        note: event.note,
        scheduledFor: event.scheduledFor,
      );
      emit(OrderPlaced(order));
    } catch (e) {
      emit(OrderError(_friendlyError(e)));
    }
  }

  Future<void> _onGetOrders(
      GetOrdersEvent event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final orders = await getOrdersUseCase();
      emit(OrdersLoaded(orders));
      _startPolling();
    } catch (e) {
      emit(OrderError(_friendlyError(e)));
    }
  }

  Future<void> _onRefreshOrders(
      RefreshOrdersEvent event, Emitter<OrderState> emit) async {
    final current = _currentOrders;
    try {
      final orders = await getOrdersUseCase();
      emit(OrdersLoaded(orders));
    } catch (e) {
      if (current != null) {
        emit(OrdersLoaded(current));
      } else {
        emit(OrderError(_friendlyError(e)));
      }
    }
  }

  Future<void> _onCancelOrder(
      CancelOrderEvent event, Emitter<OrderState> emit) async {
    final current = _currentOrders;
    if (current != null) {
      emit(OrderActionLoading(current, actionOrderId: event.orderId));
    }
    try {
      await cancelOrderUseCase(event.orderId);
      final orders = await getOrdersUseCase();
      emit(OrderCancelled(orders.firstWhere((o) => o.id == event.orderId)));
      // Quick delay then re-emit loaded list
      await Future.delayed(const Duration(milliseconds: 300));
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrderError(_friendlyError(e)));
      if (current != null) emit(OrdersLoaded(current));
    }
  }

  Future<void> _onPollOrderStatus(
      PollOrderStatusEvent event, Emitter<OrderState> emit) async {
    // Silently refresh orders list
    try {
      final orders = await getOrdersUseCase();
      emit(OrdersLoaded(orders));
    } catch (_) {
      // Ignore polling errors
    }
  }

  /// Auto-refresh orders every 10 seconds for status tracking
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!isClosed) {
        add(PollOrderStatusEvent(''));
      }
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
