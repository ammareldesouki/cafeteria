part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class FetchMenuEvent extends HomeEvent {
  const FetchMenuEvent();
}

/// Re-fetch the menu silently (no loading spinner), keeping current data on
/// screen. Used by pull-to-refresh, app resume, and background polling so the
/// customer view stays live with admin changes.
class RefreshMenuEvent extends HomeEvent {
  const RefreshMenuEvent();
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
