import { cartRepository } from "@/repositories/cart.repository";
import { menuRepository } from "@/repositories/menu.repository";
import {
	InvalidQuantityError,
	ItemNotFoundError,
	CartItemNotFoundError,
} from "@/utils/errors";
import { ObjectId } from "mongodb";

export interface CartItemResponse {
	id: string;
	menuItemId: string;
	menuItemName: string;
	image?: string; // ✅ الصورة
	variantName?: string;
	note?: string;
	quantity: number;
	unitPrice: number;
	subtotal: number;
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
	 * Add item
	 */
	async addItem(
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

		await cartRepository.addItem(
			userId,
			new ObjectId(menuItemId),
			variantName,
			quantity,
			note,
			
			 
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

		return {
			id: cartItem.menuItemId.toString(),
			menuItemId,
			menuItemName: menuItem.name,
			image: menuItem.image, // ✅ الصورة من المنيو
			...(variantName && { variantName }),
			...(note && { note }),
			quantity: cartItem.quantity,
			unitPrice: menuItem.price,
			subtotal: menuItem.price * cartItem.quantity,
		};
	},

	/**
	 * Update quantity
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

		await cartRepository.updateItemQuantity(
			userId,
			new ObjectId(menuItemId),
			variantName,
			quantity,
			note,
		);

		return {
			id: menuItemId,
			menuItemId,
			menuItemName: menuItem.name,
			image: menuItem.image, // ✅ الصورة
			...(variantName && { variantName }),
			...(note && { note }),
			quantity,
			unitPrice: menuItem.price,
			subtotal: menuItem.price * quantity,
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
	 * Format response (🔥 أهم جزء)
	 */
	async formatCartResponse(cart: {
		_id?: ObjectId;
		userId: string;
		items: Array<{
			menuItemId: ObjectId;
			variantName?: string;
			note?: string;
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

			formattedItems.push({
				id: item.menuItemId.toString(),
				menuItemId: item.menuItemId.toString(),
				menuItemName: menuItem.name,
				image: menuItem.image, // ✅ الحل هنا
				...(item.variantName && { variantName: item.variantName }),
				...(item.note && { note: item.note }),
				quantity: item.quantity,
				unitPrice,
				subtotal,
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