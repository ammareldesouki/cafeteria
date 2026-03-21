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
  async findByUserId(userId: string): Promise<Favorite[]> {
    return collection.find({ userId }).toArray();
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
