import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String mongoId;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final bool inStock;

  const MenuItemEntity({
    required this.id,
    required this.mongoId,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.inStock,
  });

  @override
  List<Object?> get props => [id, name, category];
}
