import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/use_cases/admin_usecases.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetDashboardAnalyticsUseCase getDashboardAnalytics;
  final GetAdminOrdersUseCase getAdminOrders;
  final UpdateAdminOrderUseCase updateAdminOrder;

  AdminDashboardLoaded? _lastLoadedState;
  Timer? _pollTimer;

  AdminBloc({
    required this.getDashboardAnalytics,
    required this.getAdminOrders,
    required this.updateAdminOrder,
  }) : super(AdminInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<FetchAdminOrdersEvent>(_onFetchAdminOrders);
    on<UpdateAdminOrderEvent>(_onUpdateAdminOrder);
    on<PollDashboardDataEvent>(_onPollDashboardData);
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map<String, dynamic>) {
        return data['message']?.toString() ?? e.message ?? 'Server error';
      }
      return e.message ?? 'Network error';
    }
    return e.toString();
  }

  Future<void> _onLoadDashboardData(
    LoadDashboardDataEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final analytics = await getDashboardAnalytics();
      final orders = await getAdminOrders(page: 1, limit: 100);

      final newState = AdminDashboardLoaded(
        analytics: analytics,
        orders: orders,
      );
      _lastLoadedState = newState;
      emit(newState);
      _startPolling();
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
    }
  }

  Future<void> _onFetchAdminOrders(
    FetchAdminOrdersEvent event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = _lastLoadedState;
    if (currentState == null) {
      emit(AdminLoading());
    }
    try {
      final orders = await getAdminOrders(
        page: event.page,
        limit: event.limit,
        search: event.search,
        dateRange: event.dateRange,
        status: event.status,
        paymentStatus: event.paymentStatus,
      );

      if (currentState != null) {
        final newState = currentState.copyWith(
          orders: orders,
          activeSearch: event.search,
          activeDateRange: event.dateRange,
          activeStatus: event.status,
          activePaymentStatus: event.paymentStatus,
        );
        _lastLoadedState = newState;
        emit(newState);
      } else {
        // Fallback if analytics not loaded yet (shouldn't really happen)
        final analytics = await getDashboardAnalytics();
        final newState = AdminDashboardLoaded(
          analytics: analytics,
          orders: orders,
          activeSearch: event.search,
          activeDateRange: event.dateRange,
          activeStatus: event.status,
          activePaymentStatus: event.paymentStatus,
        );
        _lastLoadedState = newState;
        emit(newState);
      }
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
    }
  }

  Future<void> _onUpdateAdminOrder(
    UpdateAdminOrderEvent event,
    Emitter<AdminState> emit,
  ) async {
    if (_lastLoadedState == null) return;

    try {
      await updateAdminOrder(
        orderId: event.orderId,
        status: event.status,
        paymentStatus: event.paymentStatus,
      );

      // Refresh analytics and orders, maintaining current filters
      final analytics = await getDashboardAnalytics();
      final orders = await getAdminOrders(
        page: _lastLoadedState!.orders.page,
        limit: _lastLoadedState!.orders.limit,
        search: _lastLoadedState!.activeSearch,
        dateRange: _lastLoadedState!.activeDateRange,
        status: _lastLoadedState!.activeStatus,
        paymentStatus: _lastLoadedState!.activePaymentStatus,
      );

      final newState = _lastLoadedState!.copyWith(
        analytics: analytics,
        orders: orders,
      );
      _lastLoadedState = newState;
      emit(newState);
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastLoadedState != null) emit(_lastLoadedState!);
    }
  }

  Future<void> _onPollDashboardData(
    PollDashboardDataEvent event,
    Emitter<AdminState> emit,
  ) async {
    final currentState = _lastLoadedState;
    if (currentState == null) return;

    // Silently refresh analytics and orders maintaining active filters
    try {
      final analytics = await getDashboardAnalytics();
      final orders = await getAdminOrders(
        page: currentState.orders.page,
        limit: currentState.orders.limit,
        search: currentState.activeSearch,
        dateRange: currentState.activeDateRange,
        status: currentState.activeStatus,
        paymentStatus: currentState.activePaymentStatus,
      );

      final newState = currentState.copyWith(
        analytics: analytics,
        orders: orders,
      );
      _lastLoadedState = newState;
      emit(newState);
    } catch (_) {
      // Ignore polling errors to prevent disruptive error UI during normal network blips
    }
  }

  /// Start streaming updates automatically every 10 seconds
  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!isClosed) {
        add(PollDashboardDataEvent());
      }
    });
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}
