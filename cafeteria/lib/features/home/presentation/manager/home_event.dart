part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class FetchMenuEvent extends HomeEvent {
  const FetchMenuEvent();
}

class SearchQueryChanged extends HomeEvent {
  final String query;
  const SearchQueryChanged(this.query);
  @override
  List<Object?> get props => [query];
}

class ClearSearchEvent extends HomeEvent {
  const ClearSearchEvent();
}
