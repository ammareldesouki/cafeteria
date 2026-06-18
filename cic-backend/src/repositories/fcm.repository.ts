import mongoose from "mongoose";

export interface FcmTokenDoc {
	_id?: mongoose.Types.ObjectId;
	userId: string;
	token: string;
	/** Device UI language ("en" | "ar") — used to localize push copy. */
	lang?: string;
	/** Account role ("admin" | "user") — used to target staff-only alerts. */
	role?: string;
	createdAt: Date;
}

const collection = mongoose.connection.collection<FcmTokenDoc>("fcm_tokens");

export const fcmRepository = {
	/**
	 * Register (or re-register) an FCM token for a user.
	 * Removes any existing row for this token first (upsert pattern).
	 */
	async registerToken(
		userId: string,
		token: string,
		lang?: string,
		role?: string,
	): Promise<void> {
		await collection.deleteMany({ token });
		await collection.insertOne({
			userId,
			token,
			lang: lang === "ar" ? "ar" : "en",
			role: role === "admin" ? "admin" : "user",
			createdAt: new Date(),
		});
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

	/** Token docs for all cafeteria staff (admins) — staff broadcasts. */
	async getStaffTokenDocs(): Promise<FcmTokenDoc[]> {
		return collection.find({ role: "admin" }).toArray();
	},

	/** Token docs belonging to a single user — order-tracking notifications. */
	async getUserTokenDocs(userId: string): Promise<FcmTokenDoc[]> {
		return collection.find({ userId }).toArray();
	},
};
