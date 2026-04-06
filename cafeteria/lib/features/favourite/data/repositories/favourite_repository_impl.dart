import '../../domain/entities/favourite_entity.dart';
import '../../domain/repositories/favourite_repository.dart';
import '../data_sources/favourite_remote_datasource.dart';

class FavouriteRepositoryImpl implements FavouriteRepository {
  final FavouriteRemoteDataSource remoteDataSource;

  FavouriteRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<FavouriteEntity>> getFavourites() async {
    return remoteDataSource.getFavourites();
  }

  @override
  Future<void> addFavourite(String itemId) async {
    return remoteDataSource.addFavourite(itemId);
  }

  @override
  Future<void> removeFavourite(String itemId) async {
    return remoteDataSource.removeFavourite(itemId);
  }
}
