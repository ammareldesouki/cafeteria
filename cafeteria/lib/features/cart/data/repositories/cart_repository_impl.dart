import '../../domain/entities/cart_entity.dart';
import '../../domain/repositories/cart_repository.dart';
import '../data_sources/cart_remote_datasource.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;

  CartRepositoryImpl(this.remoteDataSource);

  @override
  Future<CartEntity> getCart() => remoteDataSource.getCart();

  @override
  Future<CartItemEntity> addCartItem({
    required String menuItemId,
    required int quantity,
    String? variantName,
    String? note,
    int? sugar,
  }) =>
      remoteDataSource.addCartItem(
        menuItemId: menuItemId,
        quantity: quantity,
        variantName: variantName,
        note: note,
        sugar: sugar,
      );

  @override
  Future<CartItemEntity> updateCartItem({
    required String itemId,
    required int quantity,
    String? variantName,
    String? note,
  }) =>
      remoteDataSource.updateCartItem(
        itemId: itemId,
        quantity: quantity,
        variantName: variantName,
        note: note,
      );

  @override
  Future<void> removeCartItem({
    required String itemId,
    String? variantName,
    String? note,
  }) =>
      remoteDataSource.removeCartItem(
        itemId: itemId,
        variantName: variantName,
        note: note,
      );

  @override
  Future<void> clearCart() => remoteDataSource.clearCart();
}
