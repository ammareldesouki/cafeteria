import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/use_cases/get_menu_items_usecase.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetMenuItemsUseCase _getMenuItems;

  HomeBloc(this._getMenuItems) : super(HomeInitial()) {
    on<FetchMenuEvent>(_onFetch);
    on<SearchQueryChanged>(_onSearch);
    on<ClearSearchEvent>(_onClear);
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
      (items) => emit(HomeLoaded(
        allItems: items,
        coldDrinks: items.where((i) => i.category == 'cold').toList(),
        hotDrinks: items.where((i) => i.category == 'hot').toList(),
        sideItems: items
            .where((i) => i.category != 'cold' && i.category != 'hot')
            .toList(),
      )),
    );
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
