/**
 * Service Layer - Stock Business Logic
 * Handles stock reservation and restoration with atomic operations.
 * Uses MongoDB atomic operations to prevent overselling under concurrency.
 *
 * Items with trackStock: false (hot drinks, made-to-order) skip all stock
 * checks and are always considered "in stock".
 */
import { menuRepository } from "@/repositories/menu.repository";
import { variantRepository } from "@/repositories/variant.repository";
import { InsufficientStockError } from "@/utils/errors";
import { ObjectId } from "mongodb";

export interface StockReservation {
	menuItemId: string | ObjectId;
	variantName?: string;
	quantity: number;
	unitPrice: number;
}

/** Stock info returned to callers (cart service, etc.) */
export interface StockInfo {
	/** Available stock count. null = unlimited (trackStock: false). */
	available: number | null;
	trackStock: boolean;
}

export const stockService = {
	/**
	 * Reserve stock for an item (atomic decrease)
	 * For items WITHOUT variants: uses menuItem.stock
	 * For items WITH variants: uses variant.stock (identified by variantName)
	 * Items with trackStock: false skip the decrease entirely.
	 * Returns the reservation details for order creation
	 * @throws InsufficientStockError if stock is insufficient
	 */
	async reserveStock(
		menuItemId: string,
		quantity: number,
		variantName?: string,
	): Promise<{
		menuItemId: ObjectId;
		variantName?: string;
		quantity: number;
		unitPrice: number;
	}> {
		const menuItem = await menuRepository.findById(menuItemId);
		if (!menuItem) {
			throw new InsufficientStockError(menuItemId, quantity, 0);
		}

		const unitPrice = menuItem.price;
		// trackStock defaults to true if field is missing in DB
		const trackStock = menuItem.trackStock !== false;

		// ── Untracked items (hot drinks) — no stock decrease needed ──
		if (!trackStock) {
			return {
				menuItemId: new ObjectId(menuItemId),
				...(variantName && { variantName }),
				quantity,
				unitPrice,
			};
		}

		// ── Tracked items — validate and decrease stock ──
		if (variantName) {
			if (!menuItem.hasVariants || !menuItem.variants) {
				throw new InsufficientStockError(menuItemId, quantity, 0);
			}

			const variant = menuItem.variants.find(
				(v) => v.name.toLowerCase() === variantName.toLowerCase(),
			);
			if (!variant) {
				throw new InsufficientStockError(menuItemId, quantity, 0);
			}

			const stockDecreased = await variantRepository.decreaseStock(
				menuItemId,
				variantName,
				quantity,
			);
			if (!stockDecreased) {
				throw new InsufficientStockError(menuItemId, quantity, variant.stock);
			}

			return {
				menuItemId: new ObjectId(menuItemId),
				variantName: variant.name,
				quantity,
				unitPrice,
			};
		} else {
			if (
				menuItem.hasVariants &&
				menuItem.variants &&
				menuItem.variants.length > 0
			) {
				throw new InsufficientStockError(menuItemId, quantity, 0);
			}

			const stockDecreased = await menuRepository.decreaseStock(
				menuItemId,
				quantity,
			);
			if (!stockDecreased) {
				throw new InsufficientStockError(menuItemId, quantity, menuItem.stock);
			}

			return {
				menuItemId: new ObjectId(menuItemId),
				quantity,
				unitPrice,
			};
		}
	},

	/**
	 * Reserve stock for multiple items (atomic, all-or-nothing)
	 * If any item fails, previously reserved items are restored
	 */
	async reserveStockBatch(
		items: Array<{
			menuItemId: string;
			variantName?: string;
			quantity: number;
		}>,
	): Promise<StockReservation[]> {
		const reservations: StockReservation[] = [];
		const reservedItems: Array<{
			menuItemId: string;
			variantName?: string;
			quantity: number;
		}> = [];

		try {
			for (const item of items) {
				const reservation = await this.reserveStock(
					item.menuItemId,
					item.quantity,
					item.variantName,
				);
				reservations.push(reservation);
				reservedItems.push({
					menuItemId: item.menuItemId,
					variantName: item.variantName,
					quantity: item.quantity,
				});
			}
			return reservations;
		} catch (error) {
			for (const reserved of reservedItems) {
				await this.restoreStock(
					reserved.menuItemId,
					reserved.quantity,
					reserved.variantName,
				);
			}
			throw error;
		}
	},

	/**
	 * Restore stock for an item (for order cancellation)
	 * Skips restoration for items with trackStock: false.
	 */
	async restoreStock(
		menuItemId: string,
		quantity: number,
		variantName?: string,
	): Promise<void> {
		const menuItem = await menuRepository.findById(menuItemId);
		if (!menuItem) return;

		// Don't restore stock for untracked items
		if (menuItem.trackStock === false) return;

		if (variantName) {
			await variantRepository.increaseStock(menuItemId, variantName, quantity);
		} else {
			await menuRepository.increaseStock(menuItemId, quantity);
		}
	},

	/**
	 * Restore stock for multiple items (for order cancellation)
	 */
	async restoreStockBatch(
		items: Array<{
			menuItemId: string;
			variantName?: string;
			quantity: number;
		}>,
	): Promise<void> {
		await Promise.all(
			items.map((item) =>
				this.restoreStock(item.menuItemId, item.quantity, item.variantName),
			),
		);
	},

	/**
	 * Check if sufficient stock is available (without reserving).
	 * Items with trackStock: false always return true.
	 */
	async checkStock(
		menuItemId: string,
		quantity: number,
		variantName?: string,
	): Promise<boolean> {
		const menuItem = await menuRepository.findById(menuItemId);
		if (!menuItem) {
			return false;
		}

		// Untracked items are always in stock
		if (menuItem.trackStock === false) {
			return true;
		}

		if (variantName) {
			if (!menuItem.hasVariants || !menuItem.variants) {
				return false;
			}
			return variantRepository.hasStock(menuItemId, variantName, quantity);
		}

		if (
			menuItem.hasVariants &&
			menuItem.variants &&
			menuItem.variants.length > 0
		) {
			return false;
		}

		return menuRepository.hasStock(menuItemId, quantity);
	},

	/**
	 * Get available stock info for an item.
	 * Returns { available: null, trackStock: false } for unlimited items.
	 * Returns { available: <number>, trackStock: true } for tracked items.
	 */
	async getAvailableStock(
		menuItemId: string,
		variantName?: string,
	): Promise<StockInfo> {
		const menuItem = await menuRepository.findById(menuItemId);
		if (!menuItem) {
			return { available: 0, trackStock: true };
		}

		if (menuItem.trackStock === false) {
			return { available: null, trackStock: false };
		}

		if (variantName) {
			if (!menuItem.hasVariants || !menuItem.variants) {
				return { available: 0, trackStock: true };
			}
			const variant = menuItem.variants.find(
				(v) => v.name.toLowerCase() === variantName.toLowerCase(),
			);
			return {
				available: variant?.stock ?? 0,
				trackStock: true,
			};
		}

		return { available: menuItem.stock, trackStock: true };
	},
};
