import '../entities/favourite_entity.dart';
import '../repositories/favourite_repository.dart';

class GetFavouritesUseCase {
  final FavouriteRepository repository;

  GetFavouritesUseCase(this.repository);

  Future<List<FavouriteEntity>> call() {
    return repository.getFavourites();
  }
}
