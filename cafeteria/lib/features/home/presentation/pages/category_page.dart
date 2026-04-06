import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../favourite/presentation/manager/favourite_bloc.dart';
import '../../../favourite/presentation/manager/favourite_event.dart';
import '../../../favourite/presentation/manager/favourite_state.dart';
import '../../../favourite/presentation/widgets/favourite_toggle_button.dart';
import '../../domain/entities/menu_item_entity.dart';

// ─── Cart Bloc imports (adjust path to match your project) ───────────────────
// import '../../../cart/presentation/manager/cart_bloc.dart';
// import '../../../cart/presentation/manager/cart_event.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final PageController _controller = PageController(viewportFraction: 0.80);
  int currentIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args =
    ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    final String category = args['category'] as String;
    final List<MenuItemEntity> products =
    args['products'] as List<MenuItemEntity>;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // ── Top bar ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                  const Spacer(),
                  const CircleAvatar(
                    backgroundColor: Color(0xFF3B1A08),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            Text(
              category,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B1A08),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              "Swipe to browse items",
              style: TextStyle(fontSize: 15, color: Color(0xFF8B7355)),
            ),

            const SizedBox(height: 20),

            // ── Search bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFD9C7B8)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.search_rounded, color: Color(0xFF8B7355)),
                    SizedBox(width: 10),
                    Text(
                      "Search items...",
                      style: TextStyle(color: Color(0xFF9E8E82)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // ── PageView — wrapped in Expanded to fix the layout crash ─────
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return PageView.builder(
                    controller: _controller,
                    itemCount: products.length,
                    onPageChanged: (index) =>
                        setState(() => currentIndex = index),
                    itemBuilder: (context, index) {
                      final item = products[index];

                      return AnimatedBuilder(
                        animation: _controller,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (_controller.position.hasContentDimensions) {
                            final page =
                                _controller.page ?? currentIndex.toDouble();
                            scale =
                                (1 - ((page - index).abs() * 0.05))
                                    .clamp(0.85, 1.0);
                          }
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: _ProductCard(item: item),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // ── Page indicator dots ────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(products.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: index == currentIndex ? 22 : 8,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == currentIndex
                        ? const Color(0xFF3B1A08)
                        : const Color(0xFFD9C7B8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Product Card
// ═══════════════════════════════════════════════════════════════════════════

class _ProductCard extends StatelessWidget {
  final MenuItemEntity item;

  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showCustomizeSheet(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Stack(
          children: [
            // ── Card body ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border:
                Border.all(color: const Color(0xFFC9A97E), width: 1.4),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.brown.withOpacity(0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),

                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: item.image.isNotEmpty
                        ? Image.network(
                      item.image,
                      width: 140,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _placeholderImage(),
                    )
                        : _placeholderImage(),
                  ),

                  const SizedBox(height: 22),

                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B1A08),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    '${item.price.toStringAsFixed(0)} L.E',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3B1A08),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF8B7355)),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "Tap to customize and add to cart",
                    style:
                    TextStyle(fontSize: 12, color: Color(0xFF9E8E82)),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // ── ❤️ Favourite button ───────────────────────────────────────
            Positioned(
              top: 12,
              right: 20,
              child: FavouriteToggleButton(itemId: item.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<FavouriteBloc>(),
        child: _CustomizeSheet(item: item),
      ),
    );
  }

  Widget _placeholderImage() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7E0),
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Icon(Icons.local_drink_rounded,
          size: 56, color: Color(0xFFBCA999)),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Customize Sheet  —  variants + quantity + favourite + add to cart
// ═══════════════════════════════════════════════════════════════════════════

class _CustomizeSheet extends StatefulWidget {
  final MenuItemEntity item;

  const _CustomizeSheet({required this.item});

  @override
  State<_CustomizeSheet> createState() => _CustomizeSheetState();
}

class _CustomizeSheetState extends State<_CustomizeSheet> {
  int _quantity = 1;
  String? _selectedVariant;
  bool _addingToCart = false;

  MenuItemEntity get item => widget.item;

  /// True when the item has variants the user must choose from
  bool get _hasVariants =>
      item.hasVariants == true &&
          item.variants != null &&
          item.variants!.isNotEmpty;

  /// Whether the "Add to Cart" button should be enabled
  bool get _canAddToCart => !_hasVariants || _selectedVariant != null;

  double get _totalPrice => item.price * _quantity;

  // ── Cart API call ────────────────────────────────────────────────────────
  Future<void> _addToCart() async {
    if (!_canAddToCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a variant first'),
          backgroundColor: Color(0xFF3B1A08),
        ),
      );
      return;
    }

    setState(() => _addingToCart = true);

    try {
      // TODO: replace with your CartBloc event, e.g.:
      // context.read<CartBloc>().add(AddCartItemEvent(
      //   menuItemId: item.id,
      //   quantity: _quantity,
      //   variantName: _selectedVariant,   // null when no variants
      // ));
      //
      // The API body sent will be:
      //   { "menuItemId": item.id, "quantity": _quantity }               ← no variants
      //   { "menuItemId": item.id, "quantity": _quantity,
      //     "variantName": _selectedVariant }                            ← with variants

      await Future.delayed(const Duration(milliseconds: 600)); // remove when using real bloc

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to cart 🛒'),
            backgroundColor: const Color(0xFF3B1A08),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFFFF3E8),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Drag handle ──────────────────────────────────────────────
            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9C7B8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            // ── Header ───────────────────────────────────────────────────
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded,
                      size: 20, color: Color(0xFF3B1A08)),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Customize Your Order",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Color(0xFF3B1A08)),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Item info card ────────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE8D7BF)),
              ),
              child: Row(
                children: [
                  // Thumbnail
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.image.isNotEmpty
                        ? Image.network(
                      item.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _thumbPlaceholder(),
                    )
                        : _thumbPlaceholder(),
                  ),

                  const SizedBox(width: 14),

                  // Name + price
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3B1A08),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.price.toStringAsFixed(0)} L.E',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF8B7355),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ❤️ Favourite toggle
                  BlocBuilder<FavouriteBloc, FavouriteState>(
                    builder: (context, state) {
                      final cubit = context.read<FavouriteBloc>();
                      final isFav = _isFav(state, item.id);
                      final isLoading = state is FavouriteActionLoading &&
                          state.itemId == item.id;

                      return GestureDetector(
                        onTap: isLoading
                            ? null
                            : () {
                          if (isFav) {
                            cubit.add(
                                RemoveFavouriteEvent(item.id));
                          } else {
                            cubit.add(AddFavouriteEvent(item.id));
                          }
                        },
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: isLoading
                              ? const SizedBox(
                            key: ValueKey('loading'),
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF3B1A08),
                            ),
                          )
                              : Icon(
                            isFav
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            key: ValueKey(isFav),
                            color: isFav
                                ? const Color(0xFFE57373)
                                : const Color(0xFF8B7355),
                            size: 26,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Quantity selector ─────────────────────────────────────────
            const SizedBox(height: 22),

            const Text(
              "Quantity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF3B1A08),
              ),
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_quantity > 1) setState(() => _quantity--);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '$_quantity',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B1A08),
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _quantity++),
                ),
              ],
            ),

            // ── Variants ──────────────────────────────────────────────────
            if (_hasVariants) ...[
              const SizedBox(height: 22),

              Row(
                children: [
                  const Text(
                    "Select Type",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF3B1A08),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Required badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE5CC),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Required",
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFBF6E2E),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: item.variants!.map((variant) {
                  final isSelected = _selectedVariant == variant.name;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedVariant = variant.name),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF3B1A08)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF3B1A08)
                              : const Color(0xFFD9C7B8),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        variant.name,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFF3B1A08),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],

            // ── Notes ────────────────────────────────────────────────────
            const SizedBox(height: 22),

            const Text(
              "Notes",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF3B1A08),
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              maxLines: 2,
              style: const TextStyle(fontSize: 14, color: Color(0xFF3B1A08)),
              decoration: InputDecoration(
                hintText: "Add any special instructions here...",
                hintStyle: const TextStyle(color: Color(0xFFBCA999)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: Color(0xFFD9C7B8)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                  const BorderSide(color: Color(0xFFD9C7B8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                      color: Color(0xFF3B1A08), width: 1.5),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ── Add to Cart button ────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: _canAddToCart && !_addingToCart
                    ? _addToCart
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canAddToCart
                      ? const Color(0xFF3B1A08)
                      : const Color(0xFFD9C7B8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: _addingToCart
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.shopping_cart_outlined,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _hasVariants && _selectedVariant == null
                          ? 'Select a variant first'
                          : 'Add $_quantity to Cart  –  ${_totalPrice.toStringAsFixed(0)} L.E',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _isFav(FavouriteState state, String itemId) {
    if (state is FavouriteLoaded) {
      return state.favourites.any((f) => f.itemId == itemId);
    }
    if (state is FavouriteActionLoading) {
      return state.favourites.any((f) => f.itemId == itemId);
    }
    return false;
  }

  Widget _thumbPlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFEDE7E0),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.local_drink_rounded,
          size: 32, color: Color(0xFFBCA999)),
    );
  }
}

// ── Small quantity button ────────────────────────────────────────────────────

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFD9C7B8)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF3B1A08)),
      ),
    );
  }
}