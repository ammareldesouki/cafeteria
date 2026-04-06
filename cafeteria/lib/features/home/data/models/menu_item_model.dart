import '../../domain/entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.mongoId,
    required super.name,
    required super.price,
    required super.image,
    required super.category,
    required super.description,
    required super.inStock,
    super.hasVariants,
    super.variants,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    // Parse variants list — API field is "variants": [{"name": "Mango"}, ...]
    // or null when the item has no variants
    final rawVariants = map['variants'];
    final List<VariantEntity>? variants;

    if (rawVariants != null && rawVariants is List && rawVariants.isNotEmpty) {
      variants = rawVariants
          .map((v) => VariantEntity(name: v['name']?.toString() ?? ''))
          .toList();
    } else {
      variants = null;
    }

    return MenuItemModel(
      id: map['id']?.toString() ?? '',
      mongoId: map['_id']?.toString() ?? '',
      name: map['name'] ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      image: map['image'] ?? '',
      category: map['category'] ?? '',
      description: map['description'] ?? '',
      inStock: map['inStock'] ?? map['in_stock'] ?? false,
      hasVariants: map['hasVariants'] ?? false,
      variants: variants,
    );
  }
}