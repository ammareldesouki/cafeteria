part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<MenuItemEntity> allItems;
  final List<MenuItemEntity> coldDrinks;
  final List<MenuItemEntity> hotDrinks;
  final List<MenuItemEntity> sideItems;
  final List<MenuItemEntity> searchResults;
  final String searchQuery;

  const HomeLoaded({
    required this.allItems,
    required this.coldDrinks,
    required this.hotDrinks,
    required this.sideItems,
    this.searchResults = const [],
    this.searchQuery = '',
  });

  bool get isSearching => searchQuery.isNotEmpty;

  HomeLoaded copyWith({
    List<MenuItemEntity>? searchResults,
    String? searchQuery,
  }) =>
      HomeLoaded(
        allItems: allItems,
        coldDrinks: coldDrinks,
        hotDrinks: hotDrinks,
        sideItems: sideItems,
        searchResults: searchResults ?? this.searchResults,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  @override
  List<Object?> get props => [allItems, searchResults, searchQuery];
}

class HomeError extends HomeState {
  final String message;
  const HomeError(this.message);
  @override
  List<Object?> get props => [message];
}
