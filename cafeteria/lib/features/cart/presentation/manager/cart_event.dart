abstract class CartEvent {}

class GetCartEvent extends CartEvent {}

class AddCartItemEvent extends CartEvent {
  final String menuItemId;
  final int quantity;
  final String? variantName;
  final String? note;
  final int? sugar;

  AddCartItemEvent({
    required this.menuItemId,
    required this.quantity,
    this.variantName,
    this.note,
    this.sugar,
  });
}

class UpdateCartItemEvent extends CartEvent {
  final String itemId;
  final int quantity;
  final String? variantName;
  final String? note;

  UpdateCartItemEvent({
    required this.itemId,
    required this.quantity,
    this.variantName,
    this.note,
  });
}

class RemoveCartItemEvent extends CartEvent {
  final String itemId;
  final String? variantName;
  final String? note;

  RemoveCartItemEvent({
    required this.itemId,
    this.variantName,
    this.note,
  });
}

class ClearCartEvent extends CartEvent {}
