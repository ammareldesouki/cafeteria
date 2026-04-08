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
	createdAt: Date;
	updatedAt: Date;
	image?: string;
}

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
