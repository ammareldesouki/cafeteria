/**
 * Service Layer - Business Logic
 * Orchestrates menu operations. Calls repositories for data.
 * Add filtering, caching, validation rules here.
 */
import { menuRepository, CreateMenuItemInput, UpdateMenuItemInput, MenuItemVariant } from "@/repositories/menu.repository";

export const menuService = {
	// ─── Public read ──────────────────────────────────────────────────────────

	async getAllMenuItems() {
		const items = await menuRepository.findAll();

		return items.map((item: any) => ({
			...item,
			in_stock: item?.in_stock !== false,
		}));
	},

	// ─── Admin CRUD ───────────────────────────────────────────────────────────

	async createItem(data: CreateMenuItemInput) {
		// Enforce consistency: variant items have no top-level stock tracked
		if (data.hasVariants) {
			data.stock = 0;
		}

		// Generate sequential numeric id
		const maxId = await menuRepository.getMaxId();
		const newId = String(maxId + 1);

		const item = await menuRepository.create({ ...data, id: newId });
		return item;
	},

	async getItemById(itemId: string) {
		const item = await menuRepository.findById(itemId);
		if (!item) throw new Error("Menu item not found");
		return item;
	},

	async updateItem(itemId: string, fields: UpdateMenuItemInput) {
		const existing = await menuRepository.findById(itemId);
		if (!existing) throw new Error("Menu item not found");

		// Guard: block fields that shouldn't be changed via updateItem
		const { stock: _stock, ...safeFields } = fields as any;
		const updated = await menuRepository.update(itemId, safeFields as UpdateMenuItemInput);
		if (!updated) throw new Error("Menu item not found");
		return updated;
	},

	async deleteItem(itemId: string) {
		const deleted = await menuRepository.delete(itemId);
		if (!deleted) throw new Error("Menu item not found");
		return { success: true };
	},

	// ─── Stock management ────────────────────────────────────────────────────

	async setItemStock(itemId: string, stock: number) {
		const existing = await menuRepository.findById(itemId);
		if (!existing) throw new Error("Menu item not found");
		if (existing.hasVariants) {
			throw new Error(
				"This item uses variants. Update stock per variant instead.",
			);
		}

		const updated = await menuRepository.setStock(itemId, stock);
		if (!updated) throw new Error("Failed to update stock");
		return updated;
	},

	async setVariantStock(itemId: string, variantName: string, stock: number) {
		const existing = await menuRepository.findById(itemId);
		if (!existing) throw new Error("Menu item not found");
		if (!existing.hasVariants) {
			throw new Error(
				"This item has no variants. Update item stock directly.",
			);
		}

		const updated = await menuRepository.setVariantStock(itemId, variantName, stock);
		if (!updated) throw new Error("Variant not found or update failed");
		return updated;
	},

	// ─── Variant management ──────────────────────────────────────────────────

	async addVariant(itemId: string, variant: MenuItemVariant) {
		const existing = await menuRepository.findById(itemId);
		if (!existing) throw new Error("Menu item not found");
		if (!existing.hasVariants) {
			throw new Error("This item does not support variants.");
		}

		// Check for duplicate variant names (case-insensitive)
		const duplicate = (existing.variants ?? []).find(
			(v) => v.name.toLowerCase() === variant.name.toLowerCase(),
		);
		if (duplicate) {
			throw new Error(`Variant "${variant.name}" already exists.`);
		}

		const updated = await menuRepository.addVariant(itemId, variant);
		if (!updated) throw new Error("Failed to add variant");
		return updated;
	},

	async removeVariant(itemId: string, variantName: string) {
		const existing = await menuRepository.findById(itemId);
		if (!existing) throw new Error("Menu item not found");

		const updated = await menuRepository.removeVariant(itemId, variantName);
		if (!updated) throw new Error("Failed to remove variant");
		return updated;
	},

	// ─── Legacy / compat ────────────────────────────────────────────────────

	async updateItemStock(itemId: string, inStock: boolean) {
		const updated = await menuRepository.updateItemStock(itemId, inStock);
		if (!updated) {
			throw new Error("Menu item not found");
		}
		return updated;
	},
};
