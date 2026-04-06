import '../repositories/favourite_repository.dart';

class RemoveFavouriteUseCase {
  final FavouriteRepository repository;

  RemoveFavouriteUseCase(this.repository);

  Future<void> call(String itemId) {
    return repository.removeFavourite(itemId);
  }
}
