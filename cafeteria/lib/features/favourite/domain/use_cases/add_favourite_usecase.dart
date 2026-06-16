import '../repositories/favourite_repository.dart';

class AddFavouriteUseCase {
  final FavouriteRepository repository;

  AddFavouriteUseCase(this.repository);

  Future<void> call(
    String itemId, {
    String? variantName,
    int? sugar,
    String? note,
  }) {
    return repository.addFavourite(
      itemId,
      variantName: variantName,
      sugar: sugar,
      note: note,
    );
  }
}
