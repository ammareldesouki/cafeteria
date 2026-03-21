/**
 * Repository Layer - Data Access
 * Abstracts database operations for menu items.
 * All Mongoose/DB queries live here. No business logic.
 */
import mongoose from "mongoose";
import { ObjectId } from "mongodb";

const collection = mongoose.connection.collection("menu_items");

export const menuRepository = {
  async findAll(): Promise<unknown[]> {
    return collection.find({}).sort({ id: 1 }).toArray();
  },

  async updateItemStock(
    itemId: string,
    inStock: boolean,
  ): Promise<Record<string, unknown> | null> {
    const result = await collection.findOneAndUpdate(
      { _id: new ObjectId(itemId) },
      { $set: { in_stock: inStock } },
      { returnDocument: "after" },
    );

    return result || null;
  },
};
