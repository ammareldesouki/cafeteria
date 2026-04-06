import '../entities/favourite_entity.dart';

abstract class FavouriteRepository {
  Future<List<FavouriteEntity>> getFavourites();
  Future<void> addFavourite(String itemId);
  Future<void> removeFavourite(String itemId);
}
