



class GetFavouritesEvent extends FavouriteEvent {}

class FavouriteEvent {
}

class AddFavouriteEvent extends FavouriteEvent {
  final String itemId;

  AddFavouriteEvent(this.itemId);
}

class RemoveFavouriteEvent extends FavouriteEvent {
  final String itemId;

  RemoveFavouriteEvent(this.itemId);
}