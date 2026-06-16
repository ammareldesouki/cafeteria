import '../../../home/domain/entities/menu_item_entity.dart';
import '../repositories/admin_repository.dart';

class GetAdminMenuItemsUseCase {
  final AdminRepository _repository;

  GetAdminMenuItemsUseCase(this._repository);

  Future<List<MenuItemEntity>> call() => _repository.getAdminMenuItems();
}

class CreateMenuItemUseCase {
  final AdminRepository _repository;

  CreateMenuItemUseCase(this._repository);

  Future<MenuItemEntity> call({
    required String name,
    required double price,
    required String category,
    required String description,
    required String image,
    required bool hasVariants,
    required int stock,
    List<VariantEntity>? variants,
    bool? hasSugar,
  }) => _repository.createMenuItem(
    name: name,
    price: price,
    category: category,
    description: description,
    image: image,
    hasVariants: hasVariants,
    stock: stock,
    variants: variants,
    hasSugar: hasSugar,
  );
}

class UpdateMenuItemUseCase {
  final AdminRepository _repository;

  UpdateMenuItemUseCase(this._repository);

  Future<MenuItemEntity> call({
    required String itemId,
    String? name,
    double? price,
    String? category,
    String? description,
    String? image,
    bool? hasVariants,
    List<VariantEntity>? variants,
    bool? hasSugar,
  }) => _repository.updateMenuItem(
    itemId: itemId,
    name: name,
    price: price,
    category: category,
    description: description,
    image: image,
    hasVariants: hasVariants,
    variants: variants,
    hasSugar: hasSugar,
  );
}

class DeleteMenuItemUseCase {
  final AdminRepository _repository;

  DeleteMenuItemUseCase(this._repository);

  Future<void> call(String itemId) => _repository.deleteMenuItem(itemId);
}

class SetItemStockUseCase {
  final AdminRepository _repository;

  SetItemStockUseCase(this._repository);

  Future<MenuItemEntity> call({required String itemId, required int stock}) =>
      _repository.setItemStock(itemId: itemId, stock: stock);
}

class SetVariantStockUseCase {
  final AdminRepository _repository;

  SetVariantStockUseCase(this._repository);

  Future<MenuItemEntity> call({
    required String itemId,
    required String variantName,
    required int stock,
  }) => _repository.setVariantStock(
    itemId: itemId,
    variantName: variantName,
    stock: stock,
  );
}

class AddVariantUseCase {
  final AdminRepository _repository;

  AddVariantUseCase(this._repository);

  Future<MenuItemEntity> call({
    required String itemId,
    required String name,
    required int stock,
  }) => _repository.addVariant(itemId: itemId, name: name, stock: stock);
}

class RemoveVariantUseCase {
  final AdminRepository _repository;

  RemoveVariantUseCase(this._repository);

  Future<MenuItemEntity> call({
    required String itemId,
    required String variantName,
  }) => _repository.removeVariant(itemId: itemId, variantName: variantName);
}
