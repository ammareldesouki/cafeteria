/**
 * Type definitions for Favorites
 */
import { ObjectId } from "mongodb";

export interface Favorite {
	_id?: ObjectId;
	userId: string;
	itemId: string;
	/** Remembered customization from the last time the item was favourited. */
	variantName?: string;
	sugar?: number;
	note?: string;
	createdAt: Date;
}
