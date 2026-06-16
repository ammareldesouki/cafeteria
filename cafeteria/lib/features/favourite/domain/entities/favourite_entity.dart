import '../../../home/domain/entities/menu_item_entity.dart';

class FavouriteEntity {
  final String id;
  final String itemId;
  final String name;
  final String image;
  final double price;
  final String description;
  final String category;

  /// Remembered customization from when the item was favourited.
  final String? variantName;
  final int? sugar;
  final String? note;

  /// Item options (so the customize sheet can be reopened pre-filled).
  final bool hasVariants;
  final bool hasSugar;
  final List<VariantEntity>? variants;
  final int? stock;
  final bool trackStock;

  const FavouriteEntity({
    required this.id,
    required this.itemId,
    required this.name,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
    this.variantName,
    this.sugar,
    this.note,
    this.hasVariants = false,
    this.hasSugar = false,
    this.variants,
    this.stock,
    this.trackStock = true,
  });

  /// Rebuild a [MenuItemEntity] from this favourite so it can be opened in the
  /// customize sheet. `itemId` is the backend Mongo `_id`.
  MenuItemEntity toMenuItem() => MenuItemEntity(
        id: itemId,
        mongoId: itemId,
        name: name,
        price: price,
        image: image,
        category: category,
        description: description,
        inStock: true,
        hasVariants: hasVariants,
        variants: variants,
        hasSugar: hasSugar,
        stock: stock,
        trackStock: trackStock,
      );
}
