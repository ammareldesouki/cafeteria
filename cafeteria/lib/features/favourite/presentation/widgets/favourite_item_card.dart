// favourite_item_card.dart — UPDATED
// Adds an "Add to Cart" icon button so users can add a favourite directly
// to the cart without navigating back to the menu.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/favourite_entity.dart';
import '../manager/favourite_bloc.dart';
import '../manager/favourite_event.dart';

// ── Cart imports ──────────────────────────────────────────────────────────────
import '../../../cart/presentation/manager/cart_bloc.dart';
import '../../../cart/presentation/manager/cart_event.dart';
import '../../../cart/presentation/manager/cart_state.dart';

class FavouriteItemCard extends StatelessWidget {
  final FavouriteEntity item;
  final bool isLoading;

  const FavouriteItemCard({
    super.key,
    required this.item,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE8D7BF), width: 1.5),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // ── Image ────────────────────────────────────────────────────
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: item.image.isNotEmpty
                    ? Image.network(
                  item.image,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
                    : _placeholder(),
              ),

              const SizedBox(width: 14),

              // ── Name + price ──────────────────────────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B1A08),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFC07722),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // ── Add to Cart button ────────────────────────────────────────
              BlocBuilder<CartBloc, CartState>(
                builder: (context, cartState) {
                  final isAddingToCart = cartState is CartItemActionLoading;
                  return GestureDetector(
                    onTap: isAddingToCart
                        ? null
                        : () {
                      context.read<CartBloc>().add(
                        AddCartItemEvent(
                          menuItemId: item.itemId,
                          quantity: 1,
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                          Text('${item.name} added to cart 🛒'),
                          backgroundColor: const Color(0xFF3B1A08),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B1A08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: isAddingToCart
                          ? const Padding(
                        padding: EdgeInsets.all(8),
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(
                        Icons.add_shopping_cart_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(width: 8),

              // ── Remove Favourite button ───────────────────────────────────
              isLoading
                  ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFE57373),
                ),
              )
                  : GestureDetector(
                onTap: () {
                  context.read<FavouriteBloc>().add(
                    RemoveFavouriteEvent(item.itemId),
                  );
                },
                child: const Icon(
                  Icons.favorite,
                  color: Color(0xFFE57373),
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    width: 80,
    height: 80,
    decoration: BoxDecoration(
      color: const Color(0xFFEDE7E0),
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Icon(Icons.local_drink_rounded,
        size: 32, color: Color(0xFFBCA999)),
  );
}
