import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../../../../core/failure/server_failure.dart';
import '../../domain/entities/menu_item_entity.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remote;
  HomeRepositoryImpl(this._remote);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems() async {
    try {
      final items = await _remote.getMenuItems();
      return Right(items);
    } on ServerFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
