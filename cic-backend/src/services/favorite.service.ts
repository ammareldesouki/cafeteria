/**
 * Service Layer - Favorites Business Logic
 * Orchestrates favorite operations. Validates items exist, calls repositories for data.
 */
import { favoriteRepository } from "@/repositories/favorite.repository";
import mongoose from "mongoose";
import { ObjectId } from "mongodb";

const menuCollection = mongoose.connection.collection("menu_items");

export const favoriteService = {
	/**
	 * Add a favorite
	 * Validates that the menu item exists before adding
	 */
	async addFavorite(userId: string, itemId: string) {
		// Validate menu item exists
		const item = await menuCollection.findOne({ _id: new ObjectId(itemId) });
		if (!item) {
			throw new Error("Menu item not found");
		}

		// Check if favorite already exists
		const exists = await favoriteRepository.exists(userId, itemId);
		if (exists) {
			throw new Error("Item already favorited");
		}

		return favoriteRepository.create(userId, itemId);
	},

	/**
	 * Get all favorites for a user
	 */
	async getUserFavorites(userId: string) {
		return favoriteRepository.findByUserId(userId);
	},

	/**
	 * Remove a favorite
	 */
	async removeFavorite(userId: string, itemId: string) {
		const deleted = await favoriteRepository.delete(userId, itemId);
		if (!deleted) {
			throw new Error("Favorite not found");
		}
		return { success: true };
	},
};
