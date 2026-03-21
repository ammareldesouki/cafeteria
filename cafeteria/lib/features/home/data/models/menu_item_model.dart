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
  });

  factory MenuItemModel.fromMap(Map<String, dynamic> map) => MenuItemModel(
        id: map['id']?.toString() ?? '',
        mongoId: map['_id']?.toString() ?? '',
        name: map['name'] ?? '',
        price: (map['price'] as num?)?.toDouble() ?? 0.0,
        image: map['image'] ?? '',
        category: map['category'] ?? '',
        description: map['description'] ?? '',
        inStock: map['in_stock'] ?? false,
      );
}
