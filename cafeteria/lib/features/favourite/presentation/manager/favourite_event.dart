



class GetFavouritesEvent extends FavouriteEvent {}

class FavouriteEvent {
}

class AddFavouriteEvent extends FavouriteEvent {
  final String itemId;
  final String? variantName;
  final int? sugar;
  final String? note;

  AddFavouriteEvent(
    this.itemId, {
    this.variantName,
    this.sugar,
    this.note,
  });
}

class RemoveFavouriteEvent extends FavouriteEvent {
  final String itemId;

  RemoveFavouriteEvent(this.itemId);
}