import '../../../home/domain/entities/menu_item_entity.dart';
import '../../domain/entities/favourite_entity.dart';

class FavouriteModel extends FavouriteEntity {
  const FavouriteModel({
    required super.id,
    required super.itemId,
    required super.name,
    required super.image,
    required super.price,
    required super.description,
    required super.category,
    super.variantName,
    super.sugar,
    super.note,
    super.hasVariants,
    super.hasSugar,
    super.variants,
    super.stock,
    super.trackStock,
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    // API nests all item details inside the "item" key
    final item = (json['item'] as Map<String, dynamic>?) ?? {};

    // Parse variant list (same shape as the menu endpoint)
    final rawVariants = item['variants'];
    List<VariantEntity>? variants;
    if (rawVariants is List && rawVariants.isNotEmpty) {
      variants = rawVariants
          .whereType<Map<String, dynamic>>()
          .map((v) => VariantEntity(
                name: _str(v['name']),
                stock: (v['stock'] as num?)?.toInt(),
              ))
          .toList();
    }

    return FavouriteModel(
      id: _str(json['_id']),
      itemId: _str(json['itemId']),
      name: _str(item['name']),
      image: _str(item['image']),
      price: (item['price'] as num? ?? 0).toDouble(),
      description: _str(item['description']),
      category: _str(item['category']),
      variantName: json['variantName'] == null ? null : _str(json['variantName']),
      sugar: (json['sugar'] as num?)?.toInt(),
      note: json['note'] == null ? null : _str(json['note']),
      hasVariants: item['hasVariants'] as bool? ?? false,
      hasSugar: item['hasSugar'] as bool? ?? false,
      variants: variants,
      stock: (item['stock'] as num?)?.toInt(),
      trackStock: item['trackStock'] as bool? ?? true,
    );
  }

  /// Safe string extractor — never throws on unexpected types
  static String _str(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'itemId': itemId,
    'item': {
      'name': name,
      'image': image,
      'price': price,
      'description': description,
      'category': category,
    },
  };
}