import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/cart_entity.dart';
import '../../domain/use_cases/cart_usecases.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartUseCase getCartUseCase;
  final AddCartItemUseCase addCartItemUseCase;
  final UpdateCartItemUseCase updateCartItemUseCase;
  final RemoveCartItemUseCase removeCartItemUseCase;
  final ClearCartUseCase clearCartUseCase;

  CartBloc({
    required this.getCartUseCase,
    required this.addCartItemUseCase,
    required this.updateCartItemUseCase,
    required this.removeCartItemUseCase,
    required this.clearCartUseCase,
  }) : super(CartInitial()) {
    on<GetCartEvent>(_onGetCart);
    on<AddCartItemEvent>(_onAddCartItem);
    on<UpdateCartItemEvent>(_onUpdateCartItem);
    on<RemoveCartItemEvent>(_onRemoveCartItem);
    on<ClearCartEvent>(_onClearCart);
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  CartEntity? get _currentCart {
    final s = state;
    if (s is CartLoaded) return s.cart;
    if (s is CartItemActionLoading) return s.cart;
    if (s is CartAddSuccess) return s.cart;
    return null;
  }

  // ── handlers ───────────────────────────────────────────────────────────────

  Future<void> _onGetCart(GetCartEvent event, Emitter<CartState> emit) async {
    emit(CartLoading());
    try {
      final cart = await getCartUseCase();
      emit(CartLoaded(cart));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onAddCartItem(
      AddCartItemEvent event, Emitter<CartState> emit) async {
    final current = _currentCart;
    if (current != null) {
      emit(CartItemActionLoading(current));
    }
    try {
      final newItem = await addCartItemUseCase(
        menuItemId: event.menuItemId,
        quantity: event.quantity,
        variantName: event.variantName,
        note: event.note,
      );

      // Optimistically insert the new item, then re-fetch for accuracy
      final updatedItems = <CartItemEntity>[...(current?.items ?? []), newItem];
      final updatedCart = current?.copyWith(items: updatedItems) ??
          CartEntity(
            id: '',
            items: [newItem],
            totalItems: 1,
            totalPrice: newItem.subtotal,
          );
      emit(CartAddSuccess(updatedCart));

      // Re-fetch for accurate totals
      final freshCart = await getCartUseCase();
      emit(CartLoaded(freshCart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (current != null) emit(CartLoaded(current));
    }
  }

  Future<void> _onUpdateCartItem(
      UpdateCartItemEvent event, Emitter<CartState> emit) async {
    final current = _currentCart;
    if (current != null) {
      emit(CartItemActionLoading(current, itemId: event.itemId));
    }
    try {
      await updateCartItemUseCase(
        itemId: event.itemId,
        quantity: event.quantity,
        variantName: event.variantName,
        note: event.note,
      );
      final freshCart = await getCartUseCase();
      emit(CartLoaded(freshCart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (current != null) emit(CartLoaded(current));
    }
  }

  Future<void> _onRemoveCartItem(
      RemoveCartItemEvent event, Emitter<CartState> emit) async {
    final current = _currentCart;
    if (current != null) {
      emit(CartItemActionLoading(current, itemId: event.itemId));
    }
    try {
      await removeCartItemUseCase(
        itemId: event.itemId,
        variantName: event.variantName,
        note: event.note,
      );
      final freshCart = await getCartUseCase();
      emit(CartLoaded(freshCart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (current != null) emit(CartLoaded(current));
    }
  }

  Future<void> _onClearCart(
      ClearCartEvent event, Emitter<CartState> emit) async {
    final current = _currentCart;
    if (current != null) emit(CartItemActionLoading(current));
    try {
      await clearCartUseCase();
      final freshCart = await getCartUseCase();
      emit(CartLoaded(freshCart));
    } catch (e) {
      emit(CartError(e.toString()));
      if (current != null) emit(CartLoaded(current));
    }
  }
}
