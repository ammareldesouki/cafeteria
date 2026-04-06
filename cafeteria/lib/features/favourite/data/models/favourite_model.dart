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
  });

  factory FavouriteModel.fromJson(Map<String, dynamic> json) {
    // API nests all item details inside the "item" key
    final item = (json['item'] as Map<String, dynamic>?) ?? {};

    return FavouriteModel(
      id: _str(json['_id']),
      itemId: _str(json['itemId']),
      name: _str(item['name']),
      image: _str(item['image']),
      price: (item['price'] as num? ?? 0).toDouble(),
      description: _str(item['description']),
      category: _str(item['category']),
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