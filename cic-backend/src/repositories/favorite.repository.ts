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
	 * Create a new favorite
	 */
	async create(userId: string, itemId: string): Promise<Favorite> {
		const favorite: Favorite = {
			userId,
			itemId,
			createdAt: new Date(),
		};
		const result = await collection.insertOne(favorite as any);
		return { ...favorite, _id: result.insertedId };
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
						"item.id": "$itemDetails._id",
						"item.name": "$itemDetails.name",
						"item.price": "$itemDetails.price",
						"item.image": "$itemDetails.image",
						"item.variants": "$itemDetails.variants",
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
