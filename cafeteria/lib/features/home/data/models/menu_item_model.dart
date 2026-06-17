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
    super.extras,
    super.hasSugar,
    super.stock,
    super.trackStock,
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) {
    // Parse variants list — API field is "variants": [{"name": "Mango"}, ...]
    // or null when the item has no variants
    final rawVariants = map['variants'];
    final List<VariantEntity>? variants;

    if (rawVariants != null && rawVariants is List && rawVariants.isNotEmpty) {
      variants = rawVariants.map((v) {
        if (v is Map<String, dynamic>) {
          return VariantEntity(
            name: v['name']?.toString() ?? '',
            stock: (v['stock'] as num?)?.toInt(),
          );
        }
        return VariantEntity(name: v.toString());
      }).toList();
    } else {
      variants = null;
    }

    // Parse extras list — API field is "extras": [{"name": "Extra Cheese", "price": 5}]
    final rawExtras = map['extras'];
    final List<ExtraOptionEntity>? extras;

    if (rawExtras != null && rawExtras is List && rawExtras.isNotEmpty) {
      extras = rawExtras.map((e) {
        if (e is Map<String, dynamic>) {
          return ExtraOptionEntity(
            name: e['name']?.toString() ?? '',
            price: (e['price'] as num?)?.toDouble() ?? 0.0,
          );
        }
        return ExtraOptionEntity(name: e.toString(), price: 0.0);
      }).toList();
    } else {
      extras = null;
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
      extras: extras,
      hasSugar: map['hasSugar'] ?? false,
      stock: (map['stock'] as num?)?.toInt(),
      trackStock: map['trackStock'] ?? true,
    );
  }
}