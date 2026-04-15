import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/cart_entity.dart';
import '../manager/cart_bloc.dart';
import '../manager/cart_event.dart';
import '../manager/cart_state.dart';

class CartItemCard extends StatefulWidget {
  final CartItemEntity item;

  const CartItemCard({super.key, required this.item});

  @override
  State<CartItemCard> createState() => _CartItemCardState();
}

class _CartItemCardState extends State<CartItemCard> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.note ?? '');
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _updateQuantity(BuildContext context, int newQty) {
    if (newQty < 1) return;
    // Cap at available stock for tracked items
    final maxQty = _maxQuantity;
    if (newQty > maxQty) return;
    context.read<CartBloc>().add(UpdateCartItemEvent(
          itemId: widget.item.id,
          quantity: newQty,
          variantName: widget.item.variantName,
          note: _noteController.text,
        ));
  }

  /// Max quantity the user can set.
  /// Tracked items: capped at available stock.
  /// Untracked (hot drinks): capped at 99.
  int get _maxQuantity {
    if (!widget.item.trackStock) return 99;
    return widget.item.stock ?? 0;
  }

  void _removeItem(BuildContext context) {
    context.read<CartBloc>().add(RemoveCartItemEvent(
          itemId: widget.item.id,
          variantName: widget.item.variantName,
          note: widget.item.note,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartBloc, CartState>(
      builder: (context, state) {
        final isLoading = state is CartItemActionLoading &&
            state.itemId == widget.item.id;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE8D7BF), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Row 1: image + info + delete ──────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: widget.item.image.isNotEmpty
                          ? Image.network(
                              widget.item.image,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholder(),
                            )
                          : _placeholder(),
                    ),

                    const SizedBox(width: 14),

                    // Name + variant + price
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.item.menuItemName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF3B1A08),
                            ),
                          ),
                          if (widget.item.variantName != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              widget.item.variantName!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF8B7355),
                              ),
                            ),
                          ],
                          const SizedBox(height: 4),
                          Text(
                            '${AppLocalizations.of(context)!.pound}${widget.item
                                .unitPrice.toStringAsFixed(
                                2)} ${AppLocalizations.of(context)!.eachItem}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF8B7355),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Delete button
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
                            onTap: () => _removeItem(context),
                            child: const Icon(
                              Icons.delete_outline_rounded,
                              color: Color(0xFFE57373),
                              size: 24,
                            ),
                          ),
                  ],
                ),

                const SizedBox(height: 14),

                // ── Row 2: quantity selector + subtotal ───────────────────
                Row(
                  children: [
                    // Qty –
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: isLoading
                          ? null
                          : () => _updateQuantity(
                              context, widget.item.quantity - 1),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        '${widget.item.quantity}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF3B1A08),
                        ),
                      ),
                    ),

                    // Qty +
                    _QtyButton(
                      icon: Icons.add,
                      onTap: isLoading ||
                              widget.item.quantity >= _maxQuantity
                          ? null
                          : () => _updateQuantity(
                              context, widget.item.quantity + 1),
                    ),

                    const Spacer(),

                    // Subtotal
                    Text(
                      '\$${widget.item.subtotal.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFC07722),
                      ),
                    ),
                  ],
                ),

                // ── Stock indicator ────────────────────────────────────────
                if (widget.item.trackStock && widget.item.stock != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        widget.item.stock! <= 5
                            ? '${AppLocalizations.of(context)!
                            .onlyLeftInStock} ${widget.item.stock} left'
                            : '${widget.item.stock} ${AppLocalizations.of(
                            context)!.inStock}',
                        style: TextStyle(
                          fontSize: 11,
                          color: widget.item.stock! <= 5
                              ? const Color(0xFFE57373)
                              : const Color(0xFF8B7355),
                          fontWeight: widget.item.stock! <= 5
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),

                // ── Optional: variants selector (shown when item has a variant) ──
                if (widget.item.variantName != null) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Select Type',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF8B7355),
                    ),
                  ),
                ],

                // ── Notes field (shown for items that may need it) ─────────
                // if (widget.item.menuItemName.toLowerCase().contains('tea') ||
                //     widget.item.note != null) ...[
                //   const SizedBox(height: 12),
                //   Row(
                //     children: [
                //       // Sugar-like stepper (generic "add-on amount")
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             const Text(
                //               'Sugar Amount',
                //               style: TextStyle(
                //                   fontSize: 12, color: Color(0xFF8B7355)),
                //             ),
                //             const SizedBox(height: 6),
                //             Row(
                //               children: [
                //                 _SmallQtyButton(
                //                   icon: Icons.remove,
                //                   onTap: () {},
                //                 ),
                //                 const Padding(
                //                   padding:
                //                       EdgeInsets.symmetric(horizontal: 10),
                //                   child: Text('1',
                //                       style: TextStyle(
                //                           fontWeight: FontWeight.bold,
                //                           fontSize: 15,
                //                           color: Color(0xFF3B1A08))),
                //                 ),
                //                 _SmallQtyButton(
                //                   icon: Icons.add,
                //                   onTap: () {},
                //                 ),
                //               ],
                //             ),
                //           ],
                //         ),
                //       ),
                //       const SizedBox(width: 12),
                //       // Notes
                //       Expanded(
                //         child: Column(
                //           crossAxisAlignment: CrossAxisAlignment.start,
                //           children: [
                //             const Text(
                //               'Add Notes',
                //               style: TextStyle(
                //                   fontSize: 12, color: Color(0xFF8B7355)),
                //             ),
                //             const SizedBox(height: 6),
                //             TextField(
                //               controller: _noteController,
                //               maxLines: 2,
                //               style: const TextStyle(
                //                   fontSize: 12, color: Color(0xFF3B1A08)),
                //               onSubmitted: (_) {
                //                 context.read<CartBloc>().add(
                //                       UpdateCartItemEvent(
                //                         itemId: widget.item.id,
                //                         quantity: widget.item.quantity,
                //                         variantName: widget.item.variantName,
                //                         note: _noteController.text,
                //                       ),
                //                     );
                //               },
                //               decoration: InputDecoration(
                //                 hintText: 'Add any special instructions here...',
                //                 hintStyle: const TextStyle(
                //                     fontSize: 11, color: Color(0xFFBCA999)),
                //                 contentPadding: const EdgeInsets.symmetric(
                //                     horizontal: 10, vertical: 8),
                //                 filled: true,
                //                 fillColor: const Color(0xFFFAF7F4),
                //                 border: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(12),
                //                   borderSide: const BorderSide(
                //                       color: Color(0xFFD9C7B8)),
                //                 ),
                //                 enabledBorder: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(12),
                //                   borderSide: const BorderSide(
                //                       color: Color(0xFFD9C7B8)),
                //                 ),
                //                 focusedBorder: OutlineInputBorder(
                //                   borderRadius: BorderRadius.circular(12),
                //                   borderSide: const BorderSide(
                //                       color: Color(0xFF3B1A08), width: 1.5),
                //                 ),
                //               ),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ],
                //   ),
                // ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _placeholder() => Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFEDE7E0),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Icon(Icons.fastfood_rounded,
            size: 32, color: Color(0xFFBCA999)),
      );
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9C7B8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: const Color(0xFF3B1A08)),
      ),
    );
  }
}

class _SmallQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SmallQtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9C7B8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 13, color: const Color(0xFF3B1A08)),
      ),
    );
  }
}
