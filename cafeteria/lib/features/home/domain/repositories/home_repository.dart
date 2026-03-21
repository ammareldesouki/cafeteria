import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/menu_item_entity.dart';

abstract class HomeRepository {
  Future<Either<Failure, List<MenuItemEntity>>> getMenuItems();
}
