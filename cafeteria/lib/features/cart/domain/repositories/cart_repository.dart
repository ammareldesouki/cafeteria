import '../entities/cart_entity.dart';

abstract class CartRepository {
  Future<CartEntity> getCart();

  Future<CartItemEntity> addCartItem({
    required String menuItemId,
    required int quantity,
    String? variantName,
    String? note,
    int? sugar,
    List<Map<String, dynamic>>? selectedExtras,
  });

  Future<CartItemEntity> updateCartItem({
    required String itemId,
    required int quantity,
    String? variantName,
    String? note,
  });

  Future<void> removeCartItem({
    required String itemId,
    String? variantName,
    String? note,
  });

  Future<void> clearCart();
}
