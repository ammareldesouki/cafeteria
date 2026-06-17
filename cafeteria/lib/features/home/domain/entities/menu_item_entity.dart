import 'package:equatable/equatable.dart';

class VariantEntity extends Equatable {
  final String name;
  final int? stock;

  const VariantEntity({required this.name, this.stock});

  @override
  List<Object?> get props => [name, stock];
}

class ExtraOptionEntity extends Equatable {
  final String name;
  final double price;

  const ExtraOptionEntity({required this.name, required this.price});

  @override
  List<Object?> get props => [name, price];
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

  /// Priced extra options customers can add (e.g. extra cheese, whipped cream).
  final List<ExtraOptionEntity>? extras;

  /// When true, the customer can pick a sugar amount when ordering.
  final bool hasSugar;

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
    this.extras,
    this.hasSugar = false,
    this.stock,
    this.trackStock = true,
  });

  @override
  List<Object?> get props => [id, name, category];
}