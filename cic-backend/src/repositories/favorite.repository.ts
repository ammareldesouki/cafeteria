/**
 * Repository Layer - Favorites Data Access
 * Abstracts database operations for favorites.
 * All MongoDB queries for favorites live here. No business logic.
 */
import mongoose from "mongoose";
import { Favorite } from "@/types/favorite.types";

const collection = mongoose.connection.collection<Favorite>("favourites");

export const favoriteRepository = {
	/**
	 * Create or update a favorite (one per user+item), remembering the
	 * customization (variant / sugar / note) chosen when favouriting.
	 */
	async upsert(
		userId: string,
		itemId: string,
		selection: { variantName?: string; sugar?: number; note?: string },
	): Promise<Favorite> {
		const set: Record<string, unknown> = {};
		const unset: Record<string, unknown> = {};
		// Store provided selection fields; clear omitted ones so the favourite
		// reflects the latest selection.
		if (selection.variantName !== undefined) set.variantName = selection.variantName;
		else unset.variantName = "";
		if (selection.sugar !== undefined) set.sugar = selection.sugar;
		else unset.sugar = "";
		if (selection.note !== undefined) set.note = selection.note;
		else unset.note = "";

		const update: Record<string, unknown> = {
			$setOnInsert: { userId, itemId, createdAt: new Date() },
		};
		if (Object.keys(set).length) update.$set = set;
		if (Object.keys(unset).length) update.$unset = unset;

		await collection.updateOne({ userId, itemId }, update as any, {
			upsert: true,
		});
		const doc = await collection.findOne({ userId, itemId });
		return doc as Favorite;
	},

	/**
	 * Find all favorites for a user
	 */
	async findByUserId(userId: string): Promise<any[]> {
		return collection
			.aggregate([
				{ $match: { userId } },
				{ $addFields: { itemObjId: { $toObjectId: "$itemId" } } },
				{
					$lookup: {
						from: "menu_items",
						localField: "itemObjId",
						foreignField: "_id",
						as: "itemDetails",
					},
				},
				{
					$unwind: {
						path: "$itemDetails",
						preserveNullAndEmptyArrays: true,
					},
				},
				{
					$project: {
						_id: 1,
						userId: 1,
						itemId: 1,
						createdAt: 1,
						// Remembered customization
						variantName: 1,
						sugar: 1,
						note: 1,
						// Full item details so the app can rebuild the menu item
						// and open the customize sheet pre-filled.
						"item.id": "$itemDetails._id",
						"item.name": "$itemDetails.name",
						"item.price": "$itemDetails.price",
						"item.image": "$itemDetails.image",
						"item.description": "$itemDetails.description",
						"item.category": "$itemDetails.category",
						"item.variants": "$itemDetails.variants",
						"item.hasVariants": "$itemDetails.hasVariants",
						"item.hasSugar": "$itemDetails.hasSugar",
						"item.stock": "$itemDetails.stock",
						"item.trackStock": "$itemDetails.trackStock",
					},
				},
			])
			.toArray();
	},

	/**
	 * Delete a favorite
	 */
	async delete(userId: string, itemId: string): Promise<boolean> {
		const result = await collection.deleteOne({ userId, itemId });
		return result.deletedCount > 0;
	},

	/**
	 * Check if a favorite exists
	 */
	async exists(userId: string, itemId: string): Promise<boolean> {
		const count = await collection.countDocuments({ userId, itemId });
		return count > 0;
	},
};
