import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../domain/use_cases/admin_menu_usecases.dart';
import '../../domain/use_cases/admin_usecases.dart';
import 'admin_event.dart';
import 'admin_state.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final GetDashboardAnalyticsUseCase getDashboardAnalytics;
  final GetAdminOrdersUseCase getAdminOrders;
  final UpdateAdminOrderUseCase updateAdminOrder;
  final GetPendingUsersUseCase getPendingUsers;
  final SettleUserDebtUseCase settleUserDebt;

  // Menu UseCases
  final GetAdminMenuItemsUseCase getAdminMenuItems;
  final CreateMenuItemUseCase createMenuItem;
  final UpdateMenuItemUseCase updateMenuItem;
  final DeleteMenuItemUseCase deleteMenuItem;
  final SetItemStockUseCase setItemStock;
  final SetVariantStockUseCase setVariantStock;
  final AddVariantUseCase addVariant;
  final RemoveVariantUseCase removeVariant;

  AdminDashboardLoaded? _lastLoadedState;
  AdminMenuLoaded? _lastMenuState;
  Timer? _pollTimer;

  AdminMenuLoaded? get lastMenuState => _lastMenuState;

  AdminDashboardLoaded? get lastDashboardState => _lastLoadedState;

  AdminBloc({
    required this.getDashboardAnalytics,
    required this.getAdminOrders,
    required this.updateAdminOrder,
    required this.getPendingUsers,
    required this.settleUserDebt,
    required this.getAdminMenuItems,
    required this.createMenuItem,
    required this.updateMenuItem,
    required this.deleteMenuItem,
    required this.setItemStock,
    required this.setVariantStock,
    required this.addVariant,
    required this.removeVariant,
  }) : super(AdminInitial()) {
    on<LoadDashboardDataEvent>(_onLoadDashboardData);
    on<FetchAdminOrdersEvent>(_onFetchAdminOrders);
    on<UpdateAdminOrderEvent>(_onUpdateAdminOrder);
    on<PollDashboardDataEvent>(_onPollDashboardData);
    on<FetchPendingUsersEvent>(_onFetchPendingUsers);
    on<SettleUserDebtEvent>(_onSettleUserDebt);

    // Menu Handlers
    on<FetchAdminMenuEvent>(_onFetchAdminMenu);
    on<CreateMenuItemEvent>(_onCreateMenuItem);
    on<UpdateMenuItemEvent>(_onUpdateMenuItem);
    on<DeleteMenuItemEvent>(_onDeleteMenuItem);
    on<SetItemStockEvent>(_onSetItemStock);
    on<SetVariantStockEvent>(_onSetVariantStock);
    on<AddVariantEvent>(_onAddVariant);
    on<RemoveVariantEvent>(_onRemoveVariant);
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

  Future<void> _onFetchPendingUsers(
    FetchPendingUsersEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(PendingUsersLoading());
    try {
      final result = await getPendingUsers();
      emit(PendingUsersLoaded(result));
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
    }
  }

  Future<void> _onSettleUserDebt(
    SettleUserDebtEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await settleUserDebt(userId: event.userId, amount: event.amount);
      // Reload the pending list so the settled/reduced user updates.
      final result = await getPendingUsers();
      emit(PendingUsersLoaded(result));
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      // Re-fetch so the list returns to a consistent state.
      try {
        emit(PendingUsersLoaded(await getPendingUsers()));
      } catch (_) {}
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

  // ─── Menu Handlers ───────────────────────────────────────────────────────

  Future<void> _onFetchAdminMenu(
    FetchAdminMenuEvent event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      final items = await getAdminMenuItems();
      final newState = AdminMenuLoaded(items);
      _lastMenuState = newState;
      emit(newState);
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
    }
  }

  Future<void> _onCreateMenuItem(
    CreateMenuItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await createMenuItem(
        name: event.name,
        price: event.price,
        category: event.category,
        description: event.description,
        image: event.image,
        hasVariants: event.hasVariants,
        stock: event.stock,
        variants: event.variants,
        hasSugar: event.hasSugar,
      );
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }

  Future<void> _onUpdateMenuItem(
    UpdateMenuItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await updateMenuItem(
        itemId: event.itemId,
        name: event.name,
        price: event.price,
        category: event.category,
        description: event.description,
        image: event.image,
        hasVariants: event.hasVariants,
        variants: event.variants,
        hasSugar: event.hasSugar,
      );
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }

  Future<void> _onDeleteMenuItem(
    DeleteMenuItemEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await deleteMenuItem(event.itemId);
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }

  Future<void> _onSetItemStock(
    SetItemStockEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await setItemStock(itemId: event.itemId, stock: event.stock);
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }

  Future<void> _onSetVariantStock(
    SetVariantStockEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await setVariantStock(
        itemId: event.itemId,
        variantName: event.variantName,
        stock: event.stock,
      );
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }

  Future<void> _onAddVariant(
    AddVariantEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await addVariant(
        itemId: event.itemId,
        name: event.name,
        stock: event.stock,
      );
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }

  Future<void> _onRemoveVariant(
    RemoveVariantEvent event,
    Emitter<AdminState> emit,
  ) async {
    try {
      await removeVariant(itemId: event.itemId, variantName: event.variantName);
      add(FetchAdminMenuEvent());
    } catch (e) {
      emit(AdminError(_friendlyError(e)));
      if (_lastMenuState != null) emit(_lastMenuState!);
    }
  }
}
