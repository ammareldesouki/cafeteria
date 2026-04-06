
import '../../domain/entities/favourite_entity.dart';

abstract class FavouriteState {}

class FavouriteInitial extends FavouriteState {}

class FavouriteLoading extends FavouriteState {}

class FavouriteLoaded extends FavouriteState {
  final List<FavouriteEntity> favourites;

  FavouriteLoaded(this.favourites);
}

class FavouriteError extends FavouriteState {
  final String message;

  FavouriteError(this.message);
}

class FavouriteActionLoading extends FavouriteState {
  final List<FavouriteEntity> favourites;
  final String itemId;

  FavouriteActionLoading(this.favourites, this.itemId);
}