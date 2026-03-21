import 'package:dartz/dartz.dart';
import '../../../../core/failure/failure.dart';
import '../entities/menu_item_entity.dart';
import '../repositories/home_repository.dart';

class GetMenuItemsUseCase {
  final HomeRepository _repository;
  GetMenuItemsUseCase(this._repository);

  Future<Either<Failure, List<MenuItemEntity>>> call() =>
      _repository.getMenuItems();
}
