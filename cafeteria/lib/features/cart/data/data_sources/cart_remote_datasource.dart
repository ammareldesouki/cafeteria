import 'package:cafeteria/core/network/dio_handler.dart';
import '../models/cart_model.dart';

abstract class CartRemoteDataSource {
  Future<CartModel> getCart();

  Future<CartItemModel> addCartItem({
    required String menuItemId,
    required int quantity,
    String? variantName,
    String? note,
  });

  Future<CartItemModel> updateCartItem({
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

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final NetworkDioHandler _dioHandler;

  CartRemoteDataSourceImpl(this._dioHandler);

  @override
  Future<CartModel> getCart() async {
    final response = await _dioHandler.dio.get('/cart');

    // ✅ Dio already gives Map
    return CartModel.fromJson(response.data);
  }

  @override
  Future<CartItemModel> addCartItem({
    required String menuItemId,
    required int quantity,
    String? variantName,
    String? note,
  }) async {
    final body = {
      'menuItemId': menuItemId,
      'quantity': quantity,
      if (variantName != null) 'variantName': variantName,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await _dioHandler.dio.post(
      '/cart/items',
      data: body, // ✅ مش body + jsonEncode
    );

    return CartItemModel.fromJson(response.data['data']);
  }

  @override
  Future<CartItemModel> updateCartItem({
    required String itemId,
    required int quantity,
    String? variantName,
    String? note,
  }) async {
    final body = {
      'quantity': quantity,
      if (variantName != null) 'variantName': variantName,
      if (note != null && note.isNotEmpty) 'note': note,
    };

    final response = await _dioHandler.dio.put(
      '/cart/items/$itemId',
      data: body,
    );

    return CartItemModel.fromJson(response.data['data']);
  }

  @override
  Future<void> removeCartItem({
    required String itemId,
    String? variantName,
    String? note,
  }) async {
    await _dioHandler.dio.delete(
      '/cart/items/$itemId',
      queryParameters: {
        if (variantName != null) 'variantName': variantName,
        if (note != null && note.isNotEmpty) 'note': note,
      },
    );
  }

  @override
  Future<void> clearCart() async {
    await _dioHandler.dio.delete('/cart');
  }
}