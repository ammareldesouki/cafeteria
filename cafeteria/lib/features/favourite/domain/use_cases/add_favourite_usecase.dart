import '../repositories/favourite_repository.dart';

class AddFavouriteUseCase {
  final FavouriteRepository repository;

  AddFavouriteUseCase(this.repository);

  Future<void> call(String itemId) {
    return repository.addFavourite(itemId);
  }
}
