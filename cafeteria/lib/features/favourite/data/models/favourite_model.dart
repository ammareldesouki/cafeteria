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
    // The API returns the favourite doc; item details may be nested
    final item = json['item'] as Map<String, dynamic>? ?? json;

    return FavouriteModel(
      id: json['_id'] as String? ?? '',
      itemId: (json['itemId'] ?? item['_id'] ?? '') as String,
      name: (item['name'] ?? '') as String,
      image: (item['image'] ?? '') as String,
      price: ((item['price'] ?? 0) as num).toDouble(),
      description: (item['description'] ?? '') as String,
      category: (item['category'] ?? '') as String,
    );
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
