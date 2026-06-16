/**
 * Repository Layer - Data Access
 * Abstracts database operations for menu items.
 * All Mongoose/DB queries live here. No business logic.
 */
import mongoose from "mongoose";
import { ObjectId } from "mongodb";

const collection = mongoose.connection.collection<MenuItem>("menu_items");

export interface MenuItemVariant {
	name: string;
	stock: number;
}

export interface MenuItem {
	_id?: ObjectId;
	id?: string;
	name: string;
	description?: string;
	price: number;
	stock: number;
	/**
	 * Whether this item's stock should be tracked/validated.
	 * - true (default): finite stock, validated on cart add/update and order creation
	 * - false: unlimited supply (hot drinks, made-to-order items)
	 */
	trackStock: boolean;
	hasVariants: boolean;
	variants?: MenuItemVariant[];
	/** When true, customers can pick a sugar amount when ordering. */
	hasSugar?: boolean;
	category?: string;
	image?: string;
	in_stock?: boolean;
	createdAt: Date;
	updatedAt: Date;
}

export type CreateMenuItemInput = {
	name: string;
	description?: string;
	price: number;
	stock: number;
	trackStock?: boolean;
	hasVariants: boolean;
	variants?: MenuItemVariant[];
	hasSugar?: boolean;
	category?: string;
	image?: string;
};

export type UpdateMenuItemInput = Partial<Omit<CreateMenuItemInput, "stock" | "hasVariants">> & {
	hasVariants?: boolean;
};

export const menuRepository = {
	/**
	 * Find all menu items
	 */
	async findAll(): Promise<MenuItem[]> {
		return collection.find({}).sort({ name: 1 }).toArray();
	},

	/**
	 * Find menu item by ID
	 */
	async findById(itemId: string): Promise<MenuItem | null> {
		return collection.findOne({ _id: new ObjectId(itemId) });
	},

	/**
	 * Create a new menu item
	 */
	async create(data: CreateMenuItemInput & { id: string }): Promise<MenuItem> {
		const now = new Date();
		const doc: MenuItem = {
			...data,
			id: data.id,
			stock: data.stock ?? 0,
			trackStock: data.trackStock ?? true,
			variants: data.hasVariants ? (data.variants ?? []) : undefined,
			hasSugar: data.hasSugar ?? false,
			in_stock: true,
			createdAt: now,
			updatedAt: now,
		};
		const result = await collection.insertOne(doc as any);
		return { ...doc, _id: result.insertedId };
	},

	/**
	 * Update editable fields of a menu item
	 */
	async update(
		itemId: string,
		fields: UpdateMenuItemInput,
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId) },
			{ $set: { ...fields, updatedAt: new Date() } },
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Delete a menu item
	 */
	async delete(itemId: string): Promise<boolean> {
		const result = await collection.deleteOne({ _id: new ObjectId(itemId) });
		return result.deletedCount === 1;
	},

	/**
	 * Set absolute stock for a simple (no-variant) item
	 */
	async setStock(itemId: string, stock: number): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId), hasVariants: false },
			{ $set: { stock, in_stock: stock > 0, updatedAt: new Date() } },
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Set absolute stock for a single variant
	 */
	async setVariantStock(
		itemId: string,
		variantName: string,
		stock: number,
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{
				_id: new ObjectId(itemId),
				"variants.name": { $regex: new RegExp(`^${variantName}$`, "i") },
			},
			{
				$set: { "variants.$.stock": stock, updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Add a variant to a variant item
	 */
	async addVariant(
		itemId: string,
		variant: MenuItemVariant,
	): Promise<MenuItem | null> {
		// Aggregation-pipeline update so we can coalesce a missing/null
		// `variants` field to an array before appending (older simple items
		// were stored with `variants: null`, which $push cannot target).
		// Adding a variant also promotes the item into a variant item.
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId) },
			[
				{
					$set: {
						variants: {
							$concatArrays: [
								{ $ifNull: ["$variants", []] },
								[variant],
							],
						},
						hasVariants: true,
						stock: 0,
						updatedAt: new Date(),
					},
				},
			] as any,
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Remove a variant from a variant item by name
	 */
	async removeVariant(
		itemId: string,
		variantName: string,
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId) },
			{
				$pull: { variants: { name: { $regex: new RegExp(`^${variantName}$`, "i") } } } as any,
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Get the highest numeric id value stored in the collection
	 * Used to generate a sequential id for new items.
	 */
	async getMaxId(): Promise<number> {
		const docs = await collection
			.find({}, { projection: { id: 1 } })
			.toArray();
		let max = 0;
		for (const doc of docs) {
			const n = parseInt((doc as any).id ?? "0", 10);
			if (!isNaN(n) && n > max) max = n;
		}
		return max;
	},

	// ─── Legacy/compat ─────────────────────────────────────────────────────

	/**
	 * Update item stock (numeric, atomic decrease)
	 * Returns the item after update or null if insufficient stock
	 */
	async decreaseStock(
		itemId: string,
		quantity: number,
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{
				_id: new ObjectId(itemId),
				stock: { $gte: quantity },
				hasVariants: false,
			},
			{
				$inc: { stock: -quantity },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Restore item stock (atomic increase) - for order cancellation
	 */
	async increaseStock(
		itemId: string,
		quantity: number,
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId) },
			{
				$inc: { stock: quantity },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Check if item has sufficient stock (for items without variants)
	 */
	async hasStock(itemId: string, quantity: number): Promise<boolean> {
		const item = await collection.findOne({
			_id: new ObjectId(itemId),
			stock: { $gte: quantity },
		});
		return item !== null;
	},

	/**
	 * Update item with variants array
	 */
	async updateWithVariants(
		itemId: string,
		variants: MenuItemVariant[],
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId) },
			{
				$set: { variants, updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result;
	},

	/**
	 * Legacy: updateItemStock (boolean) - kept for backward compatibility
	 * @deprecated Use decreaseStock/increaseStock for numeric stock
	 */
	async updateItemStock(
		itemId: string,
		inStock: boolean,
	): Promise<MenuItem | null> {
		const result = await collection.findOneAndUpdate(
			{ _id: new ObjectId(itemId) },
			{ $set: { isAvailable: inStock, updatedAt: new Date() } },
			{ returnDocument: "after" },
		);
		return result;
	},
};
