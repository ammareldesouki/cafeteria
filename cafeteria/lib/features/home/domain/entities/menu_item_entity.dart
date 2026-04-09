import 'package:equatable/equatable.dart';

class VariantEntity extends Equatable {
  final String name;
  final int? stock;

  const VariantEntity({required this.name, this.stock});

  @override
  List<Object?> get props => [name, stock];
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

  /// Available stock count. null means unlimited (hot drinks).
  final int? stock;

  /// Whether stock is tracked for this item.
  /// false = hot drinks / made-to-order (no stock limit).
  final bool trackStock;

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
    this.stock,
    this.trackStock = true,
  });

  @override
  List<Object?> get props => [id, name, category];
}