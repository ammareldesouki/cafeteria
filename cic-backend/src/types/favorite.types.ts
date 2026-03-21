/**
 * Type definitions for Favorites
 */
import { ObjectId } from "mongodb";

export interface Favorite {
  _id?: ObjectId;
  userId: string;
  itemId: string;
  createdAt: Date;
}
