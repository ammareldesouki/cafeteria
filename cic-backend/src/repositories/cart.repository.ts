/**
 * Repository Layer - Cart Data Access
 * Abstracts database operations for shopping carts.
 * All MongoDB queries for carts live here. No business logic.
 */
import mongoose from "mongoose";
import { ObjectId } from "mongodb";

const collection = mongoose.connection.collection<Cart>("carts");

export interface CartItem {
	menuItemId: ObjectId;
	variantName?: string;
	note?: string;
	/** Selected sugar amount (spoons) for items that offer it. */
	sugar?: number;
	quantity: number;
}

export interface Cart {
	_id?: ObjectId;
	userId: string;
	items: CartItem[];
	createdAt: Date;
	updatedAt: Date;
}

export const cartRepository = {
	/**
	 * Find cart by user ID
	 */
	async findByUserId(userId: string): Promise<Cart | null> {
		return collection.findOne({ userId });
	},

	/**
	 * Remove a menu item from every cart (called when the item is deleted).
	 */
	async removeMenuItemFromAllCarts(menuItemId: ObjectId): Promise<void> {
		await collection.updateMany(
			{ "items.menuItemId": menuItemId },
			{
				$pull: { items: { menuItemId } } as any,
				$set: { updatedAt: new Date() },
			},
		);
	},

	/**
	 * Create a new cart for user
	 */
	async create(userId: string): Promise<Cart> {
		const cart: Cart = {
			userId,
			items: [],
			createdAt: new Date(),
			updatedAt: new Date(),
		};
		const result = await collection.insertOne(cart as Cart);
		return { ...cart, _id: result.insertedId };
	},

	/**
	 * Add item to cart (or update quantity if exists)
	 */
	async addItem(
		userId: string,
		menuItemId: ObjectId,
		variantName: string | undefined,
		quantity: number,
		note?: string,
		sugar?: number,
	): Promise<Cart | null> {
		const existingItem = await this.getItem(userId, menuItemId, variantName, note);

		if (existingItem) {
			const arrayFilterElem: Record<string, unknown> = {
				"elem.menuItemId": menuItemId,
			};

			if (variantName) {
				arrayFilterElem["elem.variantName"] = {
					$regex: new RegExp(`^${variantName}$`, "i"),
				};
			} else {
				arrayFilterElem["elem.variantName"] = { $exists: false };
			}

			if (note) {
				arrayFilterElem["elem.note"] = {
					$regex: new RegExp(`^${note}$`, "i"),
				};
			} else {
				arrayFilterElem["elem.note"] = { $exists: false };
			}

			const updateOp = {
				$inc: { "items.$[elem].quantity": quantity },
				$set: { updatedAt: new Date() },
			};


			const result = await collection.findOneAndUpdate(
				{ userId },
				updateOp,
				{
					arrayFilters: [arrayFilterElem],
					returnDocument: "after",
				},
			);
			return result;
		}

		const normalizedVariantName = variantName?.toLowerCase();
		const newItem: CartItem = {
			menuItemId,
			...(normalizedVariantName && { variantName: normalizedVariantName }),
			...(note && { note }),
			...(typeof sugar === "number" && { sugar }),
			quantity,
		};

		const result = await collection.findOneAndUpdate(
			{ userId },
			{
				$push: { items: newItem },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Update cart item quantity
	 */
	async updateItemQuantity(
		userId: string,
		menuItemId: ObjectId,
		variantName: string | undefined,
		quantity: number,
		note: string | undefined,
	): Promise<Cart | null> {
		const arrayFilterElem: Record<string, unknown> = {
			"elem.menuItemId": menuItemId,
		};

		if (variantName) {
			arrayFilterElem["elem.variantName"] = {
				$regex: new RegExp(`^${variantName}$`, "i"),
			};
		} else {
			arrayFilterElem["elem.variantName"] = { $exists: false };
		}

		if (note) {
			arrayFilterElem["elem.note"] = {
				$regex: new RegExp(`^${note}$`, "i"),
			};
		} else {
			arrayFilterElem["elem.note"] = { $exists: false };
		}

		const result = await collection.findOneAndUpdate(
			{ userId },
			{
				$set: {
					"items.$[elem].quantity": quantity,
					updatedAt: new Date(),
				},
			},
			{ 
				arrayFilters: [arrayFilterElem],
				returnDocument: "after" 
			},
		);
		return result;
	},

	/**
	 * Remove item from cart
	 */
	async removeItem(
		userId: string,
		menuItemId: ObjectId,
		variantName: string | undefined,
		note: string | undefined,
	): Promise<Cart | null> {
		const normalizedVariant = variantName?.toLowerCase();
		
		// Inside removeItem
		const pullFilter: Record<string, unknown> = { menuItemId };
		if (normalizedVariant) {
			pullFilter["variantName"] = {
				$regex: new RegExp(`^${normalizedVariant}$`, "i"),
			};
		} else {
			pullFilter["variantName"] = { $exists: false };
		}
		
		if (note) {
			pullFilter["note"] = { $regex: new RegExp(`^${note}$`, "i") };
		} else {
			pullFilter["note"] = { $exists: false };
		}

		const result = await collection.findOneAndUpdate(
			{ userId },
			{
				$pull: { items: pullFilter },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Clear all items from cart
	 */
	async clearCart(userId: string): Promise<Cart | null> {
		const result = await collection.findOneAndUpdate(
			{ userId },
			{
				$set: { items: [], updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Get cart item by menuItemId and variantName (case-insensitive variant matching)
	 */
	async getItem(
		userId: string,
		menuItemId: ObjectId | string,
		variantName?: string,
		note?: string,
		
	): Promise<CartItem | null> {
		const cart = await collection.findOne({ userId });
		if (!cart || !cart.items) return null;

		const targetMenuId = menuItemId.toString().trim();
		const targetVariant = variantName?.trim().toLowerCase();
		const targetNote = note?.trim().toLowerCase();

		return (
			cart.items.find((item) => {
				const dbMenuId = item.menuItemId.toString().trim();
				const dbVariant = item.variantName?.trim().toLowerCase();
				const dbNote = item.note?.trim().toLowerCase();

				const isMenuMatch = dbMenuId === targetMenuId;
				
				const isVariantMatch = targetVariant 
					? dbVariant === targetVariant 
					: !dbVariant;
					
				const isNoteMatch = targetNote 
					? dbNote === targetNote 
					: !dbNote;
				
				return isMenuMatch && isVariantMatch && isNoteMatch;
			}) || null
		);
	},

	/**
	 * Delete cart entirely (for testing or cleanup)
	 */
	async deleteCart(userId: string): Promise<boolean> {
		const result = await collection.deleteOne({ userId });
		return result.deletedCount > 0;
	},
};