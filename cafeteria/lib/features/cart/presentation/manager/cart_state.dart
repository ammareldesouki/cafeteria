import '../../domain/entities/cart_entity.dart';

abstract class CartState {}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

/// Cart is loaded and displayed normally
class CartLoaded extends CartState {
  final CartEntity cart;

  CartLoaded(this.cart);
}

/// An item-level action is in progress (add / update / remove)
/// We still hold the current cart so the UI doesn't flicker to a blank screen
class CartItemActionLoading extends CartState {
  final CartEntity cart;

  /// The itemId being acted on — used to show a spinner on that specific card
  final String? itemId;

  CartItemActionLoading(this.cart, {this.itemId});
}

class CartError extends CartState {
  final String message;

  CartError(this.message);
}

class CartAddSuccess extends CartState {
  final CartEntity cart;

  CartAddSuccess(this.cart);
}
