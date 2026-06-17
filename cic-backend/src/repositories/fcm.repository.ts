import mongoose from "mongoose";

export interface FcmTokenDoc {
	_id?: mongoose.Types.ObjectId;
	userId: string;
	token: string;
	createdAt: Date;
}

const collection = mongoose.connection.collection<FcmTokenDoc>("fcm_tokens");

export const fcmRepository = {
	/**
	 * Register (or re-register) an FCM token for a user.
	 * Removes any existing row for this token first (upsert pattern).
	 */
	async registerToken(userId: string, token: string): Promise<void> {
		await collection.deleteMany({ token });
		await collection.insertOne({ userId, token, createdAt: new Date() });
	},

	/**
	 * Remove a specific token (logout / token refresh).
	 */
	async unregisterToken(token: string): Promise<void> {
		await collection.deleteMany({ token });
	},

	/**
	 * Remove all tokens for a user (full logout).
	 */
	async unregisterAllForUser(userId: string): Promise<void> {
		await collection.deleteMany({ userId });
	},

	/**
	 * Get all FCM tokens for all admin users (called by the cron).
	 * In a more granular setup you'd filter by role; here we simply
	 * return every registered token.
	 */
	async getAllTokens(): Promise<string[]> {
		const docs = await collection.find({}).toArray();
		return docs.map((d) => d.token);
	},
};
