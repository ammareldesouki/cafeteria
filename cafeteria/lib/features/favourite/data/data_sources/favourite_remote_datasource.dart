import 'package:cafeteria/core/network/dio_handler.dart';
import 'package:dio/dio.dart';
import '../models/favourite_model.dart';

abstract class FavouriteRemoteDataSource {
  Future<List<FavouriteModel>> getFavourites();
  Future<void> addFavourite(String itemId);
  Future<void> removeFavourite(String itemId);
}

class FavouriteRemoteDataSourceImpl implements FavouriteRemoteDataSource {
  final NetworkDioHandler _dioHandler; // inject the same Dio instance your app already uses

  FavouriteRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<List<FavouriteModel>> getFavourites() async {
    final response = await _dioHandler.dio.get('/favorites');

    // response.data is already decoded by Dio as List<dynamic>
    final List<dynamic> data = response.data as List<dynamic>;

    return data
        .map((e) => FavouriteModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> addFavourite(String itemId) async {
    await _dioHandler.dio.post(
      '/favorites',
      data: {'itemId': itemId},
    );
  }

  @override
  Future<void> removeFavourite(String itemId) async {
    await _dioHandler.dio.delete('/favorites/$itemId');
  }
}