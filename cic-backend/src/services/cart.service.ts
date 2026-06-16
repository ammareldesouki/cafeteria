import { cartRepository } from "@/repositories/cart.repository";
import { menuRepository } from "@/repositories/menu.repository";
import { stockService } from "@/services/stock.service";
import {
	InvalidQuantityError,
	ItemNotFoundError,
	CartItemNotFoundError,
	InsufficientStockError,
} from "@/utils/errors";
import { ObjectId } from "mongodb";

export interface CartItemResponse {
	id: string;
	menuItemId: string;
	menuItemName: string;
	image?: string;
	variantName?: string;
	note?: string;
	sugar?: number;
	quantity: number;
	unitPrice: number;
	subtotal: number;
	/** Available stock. null = unlimited (hot drinks). */
	stock: number | null;
	/** Whether stock is tracked for this item. */
	trackStock: boolean;
}

export interface CartResponse {
	id: string;
	userId: string;
	items: CartItemResponse[];
	totalItems: number;
	totalPrice: number;
}

export const cartService = {
	/**
	 * Get or create cart
	 */
	async getOrCreateCart(userId: string): Promise<CartResponse> {
		let cart = await cartRepository.findByUserId(userId);

		if (!cart) {
			cart = await cartRepository.create(userId);
		}

		return this.formatCartResponse(cart);
	},

	/**
	 * Add item — validates stock before adding to cart.
	 * For tracked items: ensures (existing cart qty + new qty) <= available stock.
	 * For untracked items (hot drinks): no limit (capped at 99 as sanity check).
	 */
	async addItem(
		userId: string,
		menuItemId: string,
		quantity: number,
		variantName?: string,
		note?: string,
		sugar?: number,
	): Promise<CartItemResponse> {
		if (!Number.isInteger(quantity) || quantity <= 0) {
			throw new InvalidQuantityError(quantity, "must be a positive integer");
		}

		const menuItem = await menuRepository.findById(menuItemId);
		if (!menuItem) {
			throw new ItemNotFoundError(menuItemId);
		}

		// ── Stock validation ──────────────────────────────────────────────
		const trackStock = menuItem.trackStock !== false;

		if (trackStock) {
			// Get how many of this exact item+variant are already in cart
			const existingCartItem = await cartRepository.getItem(
				userId,
				new ObjectId(menuItemId),
				variantName,
				note,
			);
			const existingQty = existingCartItem?.quantity ?? 0;
			const totalRequested = existingQty + quantity;

			// Get available stock
			const stockInfo = await stockService.getAvailableStock(
				menuItemId,
				variantName,
			);
			const available = stockInfo.available ?? 0;

			if (totalRequested > available) {
				throw new InsufficientStockError(
					menuItemId,
					totalRequested,
					available,
				);
			}
		} else {
			// Sanity cap for unlimited items
			const existingCartItem = await cartRepository.getItem(
				userId,
				new ObjectId(menuItemId),
				variantName,
				note,
			);
			const existingQty = existingCartItem?.quantity ?? 0;
			if (existingQty + quantity > 99) {
				throw new InvalidQuantityError(
					existingQty + quantity,
					"maximum 99 per item",
				);
			}
		}

		await cartRepository.addItem(
			userId,
			new ObjectId(menuItemId),
			variantName,
			quantity,
			note,
			sugar,
		);

		const cartItem = await cartRepository.getItem(
			userId,
			new ObjectId(menuItemId),
			variantName,
			note,
		);

		if (!cartItem) {
			throw new CartItemNotFoundError(menuItemId);
		}

		// Get stock info for response
		const stockInfo = await stockService.getAvailableStock(
			menuItemId,
			variantName,
		);

		return {
			id: cartItem.menuItemId.toString(),
			menuItemId,
			menuItemName: menuItem.name,
			image: menuItem.image,
			...(variantName && { variantName }),
			...(note && { note }),
			...(typeof cartItem.sugar === "number" && { sugar: cartItem.sugar }),
			quantity: cartItem.quantity,
			unitPrice: menuItem.price,
			subtotal: menuItem.price * cartItem.quantity,
			stock: stockInfo.available,
			trackStock: stockInfo.trackStock,
		};
	},

	/**
	 * Update quantity — validates new quantity against stock.
	 * For tracked items: ensures new qty <= available stock.
	 * For untracked items: capped at 99.
	 */
	async updateItemQuantity(
		userId: string,
		menuItemId: string,
		quantity: number,
		variantName?: string,
		note?: string,
	): Promise<CartItemResponse> {
		if (!Number.isInteger(quantity) || quantity <= 0) {
			throw new InvalidQuantityError(quantity, "must be a positive integer");
		}

		const menuItem = await menuRepository.findById(menuItemId);
		if (!menuItem) {
			throw new ItemNotFoundError(menuItemId);
		}

		// ── Stock validation ──────────────────────────────────────────────
		const trackStock = menuItem.trackStock !== false;

		if (trackStock) {
			const stockInfo = await stockService.getAvailableStock(
				menuItemId,
				variantName,
			);
			const available = stockInfo.available ?? 0;

			if (quantity > available) {
				throw new InsufficientStockError(menuItemId, quantity, available);
			}
		} else {
			if (quantity > 99) {
				throw new InvalidQuantityError(quantity, "maximum 99 per item");
			}
		}

		await cartRepository.updateItemQuantity(
			userId,
			new ObjectId(menuItemId),
			variantName,
			quantity,
			note,
		);

		// Get stock info for response
		const stockInfo = await stockService.getAvailableStock(
			menuItemId,
			variantName,
		);

		return {
			id: menuItemId,
			menuItemId,
			menuItemName: menuItem.name,
			image: menuItem.image,
			...(variantName && { variantName }),
			...(note && { note }),
			quantity,
			unitPrice: menuItem.price,
			subtotal: menuItem.price * quantity,
			stock: stockInfo.available,
			trackStock: stockInfo.trackStock,
		};
	},

	/**
	 * Remove item
	 */
	async removeItem(
		userId: string,
		menuItemId: string,
		variantName?: string,
		note?: string,
	): Promise<void> {
		const cartItem = await cartRepository.getItem(
			userId,
			new ObjectId(menuItemId),
			variantName,
			note,
		);

		if (!cartItem) {
			throw new CartItemNotFoundError(menuItemId);
		}

		await cartRepository.removeItem(
			userId,
			new ObjectId(menuItemId),
			variantName,
			note,
		);
	},

	/**
	 * Clear cart
	 */
	async clearCart(userId: string): Promise<void> {
		await cartRepository.clearCart(userId);
	},

	/**
	 * Format response — includes stock info per item
	 */
	async formatCartResponse(cart: {
		_id?: ObjectId;
		userId: string;
		items: Array<{
			menuItemId: ObjectId;
			variantName?: string;
			note?: string;
			sugar?: number;
			quantity: number;
		}>;
	}): Promise<CartResponse> {
		const formattedItems: CartItemResponse[] = [];
		let totalItems = 0;
		let totalPrice = 0;

		for (const item of cart.items) {
			const menuItem = await menuRepository.findById(
				item.menuItemId.toString(),
			);

			if (!menuItem) continue;

			const unitPrice = menuItem.price;
			const subtotal = unitPrice * item.quantity;

			totalItems += item.quantity;
			totalPrice += subtotal;

			// Get stock info per item
			const stockInfo = await stockService.getAvailableStock(
				item.menuItemId.toString(),
				item.variantName,
			);

			formattedItems.push({
				id: item.menuItemId.toString(),
				menuItemId: item.menuItemId.toString(),
				menuItemName: menuItem.name,
				image: menuItem.image,
				...(item.variantName && { variantName: item.variantName }),
				...(item.note && { note: item.note }),
				...(typeof item.sugar === "number" && { sugar: item.sugar }),
				quantity: item.quantity,
				unitPrice,
				subtotal,
				stock: stockInfo.available,
				trackStock: stockInfo.trackStock,
			});
		}

		return {
			id: cart._id?.toString() || "",
			userId: cart.userId,
			items: formattedItems,
			totalItems,
			totalPrice,
		};
	},
};