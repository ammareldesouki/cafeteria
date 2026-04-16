// ─────────────────────────────────────────────────────────────────────────────
// category_page.dart  — UPDATED
// Changes vs original:
//   1. CartBloc is provided to _CustomizeSheet via BlocProvider.value
//   2. _addToCart() now dispatches AddCartItemEvent instead of the TODO stub
//   3. CartAddSuccess / CartError are listened to inside the sheet
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../favourite/presentation/manager/favourite_bloc.dart';
import '../../../favourite/presentation/manager/favourite_event.dart';
import '../../../favourite/presentation/manager/favourite_state.dart';
import '../../../favourite/presentation/widgets/favourite_toggle_button.dart';
import '../../domain/entities/menu_item_entity.dart';

// ── Cart imports ──────────────────────────────────────────────────────────────
import '../../../cart/presentation/manager/cart_bloc.dart';
import '../../../cart/presentation/manager/cart_event.dart';
import '../../../cart/presentation/manager/cart_state.dart';

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
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
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
              style:  Theme.of(context).textTheme.titleLarge
            ),
            const SizedBox(height: 6),
             Text(
               AppLocalizations.of(context)!.swipeToBrowseItems,
              style:   Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
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
                            scale = (1 - ((page - index).abs() * 0.05))
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

  /// true when the item tracks stock AND has 0 available
  bool get _isOutOfStock {
    if (!item.trackStock) return false;
    if (item.hasVariants && item.variants != null &&
        item.variants!.isNotEmpty) {
      return item.variants!.every((v) => (v.stock ?? 0) <= 0);
    }
    return (item.stock ?? 0) <= 0;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _isOutOfStock ? null : () => _showCustomizeSheet(context),
      child: Stack(
        children: [
          Opacity(
            opacity: _isOutOfStock ? 0.55 : 1.0,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: const Color(0xFFC9A97E), width: 1.4),
                color:  Theme.of(context).colorScheme.surface,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: FavouriteToggleButton(itemId: item.mongoId),
                    ),
                  ),
                  const SizedBox(height: 30),
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
                    style: Theme
                        .of(context)
                        .textTheme!
                        .titleLarge!
                        .copyWith(fontSize: 30),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${item.price.toStringAsFixed(0)} ${AppLocalizations.of(
                        context)!.pound} ',
                    style: Theme
                        .of(context)
                        .textTheme!
                        .titleLarge,

                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      item.description,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme
                          .of(context)
                          .textTheme!
                          .bodyLarge,

                    ),
                    ),

                  const SizedBox(height: 12),
                  Text(
                    _isOutOfStock
                        ? AppLocalizations.of(context)!.outOfStock
                        : AppLocalizations.of(context)!.addToCart,
                    style: TextStyle(
                      fontSize: 24,
                      color: _isOutOfStock
                          ? const Color(0xFFE57373)
                          : const Color(0xFF9E8E82),
                      fontWeight:
                          _isOutOfStock ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          // ── Out-of-Stock badge ──
          if (_isOutOfStock)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE57373),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.outOfStock,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Pass BOTH FavouriteBloc and CartBloc into the sheet ──────────────────
  void _showCustomizeSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<FavouriteBloc>()),
          BlocProvider.value(value: context.read<CartBloc>()),
        ],
        child: _CustomizeSheet(item: item),
      ),
    );
  }

  Widget _placeholderImage() => Container(
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

// ═══════════════════════════════════════════════════════════════════════════
// Customize Sheet
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
  final TextEditingController _noteController = TextEditingController();

  MenuItemEntity get item => widget.item;

  bool get _hasVariants =>
      item.hasVariants == true &&
          item.variants != null &&
          item.variants!.isNotEmpty;

  bool get _canAddToCart => !_hasVariants || _selectedVariant != null;

  double get _totalPrice => item.price * _quantity;

  /// Max quantity allowed.
  /// Tracked items: capped at available stock.
  /// Untracked (hot drinks): capped at 99.
  int get _maxQuantity {
    if (!item.trackStock) return 99;
    if (_hasVariants && _selectedVariant != null) {
      final v = item.variants?.firstWhere(
            (v) => v.name == _selectedVariant,
        orElse: () => const VariantEntity(name: ''),
      );
      return v?.stock ?? 0;
    }
    return item.stock ?? 0;
  }

  bool get _isOutOfStock {
    if (!item.trackStock) return false;
    if (_hasVariants) {
      if (_selectedVariant == null) {
        // If no variant is selected, check if ALL variants are out of stock
        return item.variants?.every((v) => (v.stock ?? 0) <= 0) ?? true;
      } else {
        return _maxQuantity <= 0;
      }
    }
    return (item.stock ?? 0) <= 0;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _addToCart() {
    if (!_canAddToCart) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.varaity),
          backgroundColor: Color(0xFF3B1A08),
        ),
      );
      return;
    }

    context.read<CartBloc>().add(
      AddCartItemEvent(
        menuItemId: item.mongoId, // use the backend _id
        quantity: _quantity,
        variantName: _selectedVariant,
        note: _noteController.text.trim().isNotEmpty
            ? _noteController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartAddSuccess) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${item.name} ${AppLocalizations.of(context)!.addToCart} 🛒'),
              backgroundColor: const Color(0xFF3B1A08),
            ),
          );
        }
        if (state is CartError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Container(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        decoration:  BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
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

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF3B1A08)),
                  ),
                  const SizedBox(width: 12),
                   Text(
                       AppLocalizations.of(context)!.customizeYourOrder,
                       style: Theme
                           .of(context)
                           .textTheme
                           .titleLarge!
                           .copyWith(color: TColors.primary)),

                ],
              ),

              const SizedBox(height: 20),

              // Item info card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE8D7BF)),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: item.image.isNotEmpty
                          ? Image.network(item.image,
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _thumbPlaceholder())
                          : _thumbPlaceholder(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                              style: Theme.of(context).textTheme.bodyMedium
                          ),
                          const SizedBox(height: 4),
                          Text(
                              '${item.price.toStringAsFixed(
                                  0)} ${AppLocalizations.of(context)!.pound}',
                              style: Theme.of(context).textTheme.titleLarge
                          ),
                        ],
                      ),
                    ),
                    // ❤️ Fav toggle
                    BlocBuilder<FavouriteBloc, FavouriteState>(
                      builder: (context, state) {
                        final cubit = context.read<FavouriteBloc>();
                        final isFav = _isFav(state, item.mongoId);
                        final isLoading = state is FavouriteActionLoading &&
                            state.itemId == item.mongoId;
                        return GestureDetector(
                          onTap: isLoading
                              ? null
                              : () {
                            if (isFav) {
                              cubit.add(RemoveFavouriteEvent(item.mongoId));
                            } else {
                              cubit.add(AddFavouriteEvent(item.mongoId));
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

              const SizedBox(height: 22),

              // Quantity
              Text(
                AppLocalizations.of(context)!.quantity,
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
                    onTap: _quantity < _maxQuantity
                        ? () => setState(() => _quantity++)
                        : null,
                  ),
                ],
              ),
              // ── Stock indicator ──
              if (item.trackStock)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Builder(
                    builder: (context) {
                      final int currentStock = _maxQuantity;
                      final String stockText = currentStock <= 5
                          ? '${AppLocalizations.of(context)!
                          .onlyLeftInStock}$currentStock '
                          : '$currentStock ${AppLocalizations.of(context)!
                          .inStock}';

                      return Text(
                        _hasVariants && _selectedVariant == null
                            ? AppLocalizations.of(context)!
                            .selectAvarietyToSeeAvailability
                            : stockText,
                        style: TextStyle(
                          fontSize: 12,
                          color: currentStock <= 5
                              ? const Color(0xFFE57373)
                              : const Color(0xFF8B7355),
                          fontWeight: currentStock <= 5
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      );
                    },
                  ),
                ),

              // Variants
              if (_hasVariants) ...[
                const SizedBox(height: 22),
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.varaity,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF3B1A08),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE5CC),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        AppLocalizations.of(context)!.required,
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
                    final isOutOfStock =
                        item.trackStock && (variant.stock ?? 0) <= 0;

                    return GestureDetector(
                      onTap: isOutOfStock
                          ? null
                          : () =>
                          setState(() {
                            _selectedVariant = variant.name;
                            if (_quantity > _maxQuantity) {
                              _quantity = _maxQuantity > 0 ? 1 : 0;
                            }
                          }),
                      child: Opacity(
                        opacity: isOutOfStock ? 0.5 : 1.0,
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
                                  : isOutOfStock
                                  ? const Color(0xFFE57373)
                                  : const Color(0xFFD9C7B8),
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                variant.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFF3B1A08),
                                ),
                              ),
                              if (isOutOfStock)
                                const Text(
                                  "Out",
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: Color(0xFFE57373),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Notes
              const SizedBox(height: 22),
              Text(
                AppLocalizations.of(context)!.customize,
                style: Theme
                    .of(context)
                    .textTheme!
                    .titleMedium!
                    .copyWith(color: TColors.primary),

              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(fontSize: 14, color: Color(0xFF3B1A08)),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.customizeYourOrder,
                  hintStyle: const TextStyle(color: Color(0xFFBCA999)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD9C7B8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0xFFD9C7B8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: Color(0xFF3B1A08), width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Add to Cart button
              BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  final isAdding = state is CartItemActionLoading;
                  return SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _canAddToCart && !isAdding && !_isOutOfStock
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
                      child: isAdding
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
                                ? AppLocalizations.of(context)!
                                .varaityIsRequired
                                : '${AppLocalizations.of(context)!
                                .add} $_quantity ${AppLocalizations.of(context)!
                                .toCart}  –  ${_totalPrice.toStringAsFixed(
                                0)} ${AppLocalizations.of(context)!.pound}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
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

  Widget _thumbPlaceholder() => Container(
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

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
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
