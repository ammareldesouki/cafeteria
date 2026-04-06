/**
 * Repository Layer - Variants Data Access
 * Variants are embedded in menu_items collection as {name, stock} objects.
 * All variant operations query the menu_items collection.
 */
import mongoose from "mongoose";
import { ObjectId } from "mongodb";

const menuCollection = mongoose.connection.collection("menu_items");

export interface VariantInfo {
	name: string;
	stock: number;
}

export const variantRepository = {
	/**
	 * Find a variant by name within a menu item's variants array
	 */
	async findByName(
		menuItemId: string,
		variantName: string,
	): Promise<VariantInfo | null> {
		const menuItem = await menuCollection.findOne(
			{ _id: new ObjectId(menuItemId) },
			{ projection: { variants: 1 } },
		);
		if (!menuItem || !menuItem.variants) return null;

		return (
			menuItem.variants.find(
				(v: VariantInfo) => v.name.toLowerCase() === variantName.toLowerCase(),
			) || null
		);
	},

	/**
	 * Find a variant by index within a menu item's variants array
	 */
	async findByIndex(
		menuItemId: string,
		index: number,
	): Promise<VariantInfo | null> {
		const menuItem = await menuCollection.findOne(
			{ _id: new ObjectId(menuItemId) },
			{ projection: { variants: 1 } },
		);
		if (!menuItem || !menuItem.variants) return null;
		if (index < 0 || index >= menuItem.variants.length) return null;

		return menuItem.variants[index] || null;
	},

	/**
	 * Find variant within a menu item by name
	 */
	async findByMenuItemId(menuItemId: string): Promise<VariantInfo[]> {
		const menuItem = await menuCollection.findOne(
			{ _id: new ObjectId(menuItemId) },
			{ projection: { variants: 1 } },
		);
		if (!menuItem || !menuItem.variants) return [];
		return menuItem.variants;
	},

	/**
	 * Check if a variant has sufficient stock
	 */
	async hasStock(
		menuItemId: string,
		variantName: string,
		quantity: number,
	): Promise<boolean> {
		const variant = await this.findByName(menuItemId, variantName);
		if (!variant) return false;
		return variant.stock >= quantity;
	},

	/**
	 * Decrease variant stock atomically
	 */
	async decreaseStock(
		menuItemId: string,
		variantName: string,
		quantity: number,
	): Promise<boolean> {
		const result = await menuCollection.findOneAndUpdate(
			{
				_id: new ObjectId(menuItemId),
				"variants.name": { $regex: new RegExp(`^${variantName}$`, "i") },
				"variants.stock": { $gte: quantity },
			},
			{
				$inc: { "variants.$.stock": -quantity },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result !== null;
	},

	/**
	 * Increase variant stock atomically (for order cancellation)
	 */
	async increaseStock(
		menuItemId: string,
		variantName: string,
		quantity: number,
	): Promise<boolean> {
		const result = await menuCollection.findOneAndUpdate(
			{
				_id: new ObjectId(menuItemId),
				"variants.name": { $regex: new RegExp(`^${variantName}$`, "i") },
			},
			{
				$inc: { "variants.$.stock": quantity },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after" },
		);
		return result !== null;
	},
};
