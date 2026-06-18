import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/use_cases/get_menu_items_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMenuItemsUseCase _getMenuItems;

  /// Background poll so the customer menu reflects admin changes without a
  /// manual refresh. Silent (no spinner); see [RefreshMenuEvent].
  Timer? _pollTimer;

  HomeBloc(this._getMenuItems) : super(HomeInitial()) {
    on<FetchMenuEvent>(_onFetch);
    on<RefreshMenuEvent>(_onRefresh);
    on<SearchQueryChanged>(_onSearch);
    on<ClearSearchEvent>(_onClear);
  }

  /// Build a HomeLoaded from a fresh item list, preserving any active search.
  HomeLoaded _loadedFrom(List<MenuItemEntity> items) {
    final current = state;
    final query = current is HomeLoaded ? current.searchQuery : '';
    final results = query.isEmpty
        ? const <MenuItemEntity>[]
        : items.where((i) {
            final q = query.toLowerCase();
            return i.name.toLowerCase().contains(q) ||
                i.description.toLowerCase().contains(q) ||
                i.category.toLowerCase().contains(q);
          }).toList();

    return HomeLoaded(
      allItems: items,
      coldDrinks: items.where((i) => i.category == 'cold').toList(),
      hotDrinks: items.where((i) => i.category == 'hot').toList(),
      sideItems: items
          .where((i) => i.category != 'cold' && i.category != 'hot')
          .toList(),
      searchResults: results,
      searchQuery: query,
    );
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => add(const RefreshMenuEvent()),
    );
  }

  Future<void> _onFetch(
    FetchMenuEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    final result = await _getMenuItems();
    result.fold(
      (failure) => emit(HomeError(
        'Failed to load menu',
      )),
      (items) {
        emit(_loadedFrom(items));
        _startPolling();
      },
    );
  }

  /// Silent refresh: refetch and update in place, keeping current data visible
  /// on failure (so a flaky poll never blanks the screen).
  Future<void> _onRefresh(
    RefreshMenuEvent event,
    Emitter<HomeState> emit,
  ) async {
    final result = await _getMenuItems();
    result.fold(
      (failure) {},
      (items) => emit(_loadedFrom(items)),
    );
    if (_pollTimer == null || !_pollTimer!.isActive) _startPolling();
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }

  void _onSearch(SearchQueryChanged event, Emitter<HomeState> emit) {
    final current = state;
    if (current is! HomeLoaded) return;

    if (event.query.trim().isEmpty) {
      emit(current.copyWith(searchResults: [], searchQuery: ''));
      return;
    }

    final q = event.query.toLowerCase();
    final results = current.allItems
        .where((i) =>
            i.name.toLowerCase().contains(q) ||
            i.description.toLowerCase().contains(q) ||
            i.category.toLowerCase().contains(q))
        .toList();

    emit(current.copyWith(searchResults: results, searchQuery: event.query));
  }

  void _onClear(ClearSearchEvent event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(
        searchResults: [],
        searchQuery: '',
      ));
    }
  }
}
