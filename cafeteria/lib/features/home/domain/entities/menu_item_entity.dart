import 'package:equatable/equatable.dart';

class VariantEntity extends Equatable {
  final String name;

  const VariantEntity({required this.name});

  @override
  List<Object?> get props => [name];
}

class MenuItemEntity extends Equatable {
  final String id;
  final String mongoId;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final bool inStock;
  final bool hasVariants;
  final List<VariantEntity>? variants;

  const MenuItemEntity({
    required this.id,
    required this.mongoId,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.inStock,
    this.hasVariants = false,
    this.variants,
  });

  @override
  List<Object?> get props => [id, name, category];
}