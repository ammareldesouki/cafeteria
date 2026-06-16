import '../../../home/domain/entities/menu_item_entity.dart';

abstract class AdminEvent {}

class LoadDashboardDataEvent extends AdminEvent {}

class PollDashboardDataEvent extends AdminEvent {}

class FetchAdminOrdersEvent extends AdminEvent {
  final int page;
  final int limit;
  final String? search;
  final String? dateRange;
  final String? status;
  final String? paymentStatus;

  FetchAdminOrdersEvent({
    this.page = 1,
    this.limit = 10,
    this.search,
    this.dateRange,
    this.status,
    this.paymentStatus,
  });
}

class UpdateAdminOrderEvent extends AdminEvent {
  final String orderId;
  final String? status;
  final String? paymentStatus;

  UpdateAdminOrderEvent({
    required this.orderId,
    this.status,
    this.paymentStatus,
  });
}

class FetchAdminMenuEvent extends AdminEvent {}

class CreateMenuItemEvent extends AdminEvent {
  final String name;
  final double price;
  final String category;
  final String description;
  final String image;
  final bool hasVariants;
  final int stock;
  final List<VariantEntity>? variants;
  final bool hasSugar;

  CreateMenuItemEvent({
    required this.name,
    required this.price,
    required this.category,
    required this.description,
    required this.image,
    required this.hasVariants,
    required this.stock,
    this.variants,
    this.hasSugar = false,
  });
}

class UpdateMenuItemEvent extends AdminEvent {
  final String itemId;
  final String? name;
  final double? price;
  final String? category;
  final String? description;
  final String? image;
  final bool? hasVariants;
  final List<VariantEntity>? variants;
  final bool? hasSugar;

  UpdateMenuItemEvent({
    required this.itemId,
    this.name,
    this.price,
    this.category,
    this.description,
    this.image,
    this.hasVariants,
    this.variants,
    this.hasSugar,
  });
}

class DeleteMenuItemEvent extends AdminEvent {
  final String itemId;

  DeleteMenuItemEvent(this.itemId);
}

class SetItemStockEvent extends AdminEvent {
  final String itemId;
  final int stock;

  SetItemStockEvent({required this.itemId, required this.stock});
}

class SetVariantStockEvent extends AdminEvent {
  final String itemId;
  final String variantName;
  final int stock;

  SetVariantStockEvent({
    required this.itemId,
    required this.variantName,
    required this.stock,
  });
}

class AddVariantEvent extends AdminEvent {
  final String itemId;
  final String name;
  final int stock;

  AddVariantEvent({
    required this.itemId,
    required this.name,
    required this.stock,
  });
}

class RemoveVariantEvent extends AdminEvent {
  final String itemId;
  final String variantName;

  RemoveVariantEvent({required this.itemId, required this.variantName});
}

class FetchPendingUsersEvent extends AdminEvent {}

class SettleUserDebtEvent extends AdminEvent {
  final String userId;

  /// null = settle the full debt; otherwise a partial amount.
  final double? amount;

  SettleUserDebtEvent({required this.userId, this.amount});
}
