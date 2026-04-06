import '../entities/cart_entity.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase {
  final CartRepository _repository;
  GetCartUseCase(this._repository);

  Future<CartEntity> call() => _repository.getCart();
}

class AddCartItemUseCase {
  final CartRepository _repository;
  AddCartItemUseCase(this._repository);

  Future<CartItemEntity> call({
    required String menuItemId,
    required int quantity,
    String? variantName,
    String? note,
  }) =>
      _repository.addCartItem(
        menuItemId: menuItemId,
        quantity: quantity,
        variantName: variantName,
        note: note,
      );
}

class UpdateCartItemUseCase {
  final CartRepository _repository;
  UpdateCartItemUseCase(this._repository);

  Future<CartItemEntity> call({
    required String itemId,
    required int quantity,
    String? variantName,
    String? note,
  }) =>
      _repository.updateCartItem(
        itemId: itemId,
        quantity: quantity,
        variantName: variantName,
        note: note,
      );
}

class RemoveCartItemUseCase {
  final CartRepository _repository;
  RemoveCartItemUseCase(this._repository);

  Future<void> call({
    required String itemId,
    String? variantName,
    String? note,
  }) =>
      _repository.removeCartItem(
        itemId: itemId,
        variantName: variantName,
        note: note,
      );
}

class ClearCartUseCase {
  final CartRepository _repository;
  ClearCartUseCase(this._repository);

  Future<void> call() => _repository.clearCart();
}
