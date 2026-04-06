import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/cart_bloc.dart';
import '../manager/cart_event.dart';
import '../manager/cart_state.dart';
import '../widgets/cart_item_card.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  void initState() {
    super.initState();
    context.read<CartBloc>().add(GetCartEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: SafeArea(
        child: BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: const Color(0xFF3B1A08),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is CartLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF3B1A08)),
              );
            }

            // Extract cart from any loaded state
            final cart = _extractCart(state);

            if (cart == null || cart.items.isEmpty) {
              return _EmptyCart(
                onRefresh: () =>
                    context.read<CartBloc>().add(GetCartEvent()),
              );
            }

            return Column(
              children: [
                // ── Header ─────────────────────────────────────────────
                _CartHeader(itemCount: cart.totalItems),

                // ── Items list ────────────────────────────────────────
                Expanded(
                  child: RefreshIndicator(
                    color: const Color(0xFF3B1A08),
                    onRefresh: () async =>
                        context.read<CartBloc>().add(GetCartEvent()),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: cart.items.length,
                      itemBuilder: (context, index) =>
                          CartItemCard(item: cart.items[index]),
                    ),
                  ),
                ),

                // ── Footer: total + checkout ──────────────────────────
                _CartFooter(
                  totalPrice: cart.totalPrice,
                  onCheckout: () {
                    // TODO: Navigate to checkout
                  },
                  onClear: () {
                    context.read<CartBloc>().add(ClearCartEvent());
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  dynamic _extractCart(CartState state) {
    if (state is CartLoaded) return state.cart;
    if (state is CartItemActionLoading) return state.cart;
    if (state is CartAddSuccess) return state.cart;
    return null;
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _CartHeader extends StatelessWidget {
  final int itemCount;

  const _CartHeader({required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF3B1A08),
            radius: 20,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'My Cart',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF3B1A08),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF3B1A08),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount item${itemCount == 1 ? '' : 's'}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Footer ───────────────────────────────────────────────────────────────────

class _CartFooter extends StatelessWidget {
  final double totalPrice;
  final VoidCallback onCheckout;
  final VoidCallback onClear;

  const _CartFooter({
    required this.totalPrice,
    required this.onCheckout,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B1A08),
                ),
              ),
              Text(
                '\$${totalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFC07722),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B1A08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Proceed to Checkout',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyCart extends StatelessWidget {
  final VoidCallback onRefresh;

  const _EmptyCart({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(
              color: Color(0xFFF0E8DC),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Color(0xFF9E7E65),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF3B1A08),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add items from the menu to get started',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF8B7355)),
          ),
          const SizedBox(height: 28),
          GestureDetector(
            onTap: onRefresh,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B1A08),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Refresh',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
