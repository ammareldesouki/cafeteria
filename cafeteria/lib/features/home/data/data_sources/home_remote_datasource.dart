import 'package:dio/dio.dart';
import '../../../../core/failure/server_failure.dart';
import '../../../../core/network/dio_handler.dart';
import '../models/menu_item_model.dart';

abstract class HomeRemoteDataSource {
  Future<List<MenuItemModel>> getMenuItems();
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final NetworkDioHandler _dioHandler;
  HomeRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<List<MenuItemModel>> getMenuItems() async {
    try {
      final response = await _dioHandler.dio.get('/menu');
      final List data = response.data as List;
      return data
          .map((e) => MenuItemModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ServerFailure.fromMap(
        e.response?.data is Map<String, dynamic>
            ? e.response!.data as Map<String, dynamic>
            : {'message': e.message ?? 'Failed to load menu'},
      );
    }
  }
}
