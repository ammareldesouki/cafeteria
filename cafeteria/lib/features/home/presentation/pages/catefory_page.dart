import 'package:flutter/material.dart';
import '../../domain/entities/menu_item_entity.dart';

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  final PageController _controller = PageController(viewportFraction: 0.75);
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
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3B1A08),
              ),
            ),

            const SizedBox(height: 6),
            const Text(
              "Swipe to browse items",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF8B7355),
              ),
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
              child: PageView.builder(
                controller: _controller,
                itemCount: products.length,
                onPageChanged: (index) {
                  setState(() => currentIndex = index);
                },
                itemBuilder: (context, index) {
                  final item = products[index];

                  return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      double value = 1.0;

                      if (_controller.position.hasContentDimensions) {
                        final page = _controller.page ?? currentIndex.toDouble();
                        value = (1 - ((page - index).abs() * 0.05))
                            .clamp(0.85, 1.0);
                      }

                      return Transform.scale(
                        scale: value,
                        child: child,
                      );
                    },
                    child: _ProductCard(item: item),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

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

class _ProductCard extends StatelessWidget {
  final MenuItemEntity item;

  const _ProductCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFC9A97E), width: 1.4),
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
                  fontSize: 13,
                  color: Color(0xFF8B7355),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Tap to customize and add to cart",
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF9E8E82),
              ),
            ),
          ],
        ),
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
      child: const Icon(
        Icons.local_drink_rounded,
        size: 56,
        color: Color(0xFFBCA999),
      ),
    );
  }
}