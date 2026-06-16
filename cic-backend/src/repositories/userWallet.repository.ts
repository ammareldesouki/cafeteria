/**
 * Repository Layer - Per-User Wallet Data Access
 * Manages each user's wallet balance and transaction ledger.
 */
import mongoose, { type ClientSession } from "mongoose";
import type {
	UserWallet,
	UserWalletTransaction,
} from "@/types/userWallet.types";

const walletCollection =
	mongoose.connection.collection<UserWallet>("user_wallets");
const transactionCollection =
	mongoose.connection.collection<UserWalletTransaction>(
		"user_wallet_transactions",
	);

export const userWalletRepository = {
	/**
	 * Get a user's wallet, creating it (balance 0) if it does not exist.
	 */
	async getOrCreate(userId: string): Promise<UserWallet> {
		const existing = await walletCollection.findOne({ userId });
		if (existing) return existing;

		const wallet: UserWallet = { userId, balance: 0, updatedAt: new Date() };
		const result = await walletCollection.insertOne(wallet as any);
		return { ...wallet, _id: result.insertedId };
	},

	/**
	 * Atomically increment a user's balance (negative amount = debit).
	 */
	async updateBalance(
		userId: string,
		amount: number,
		session?: ClientSession | null,
	): Promise<UserWallet | null> {
		const result = await walletCollection.findOneAndUpdate(
			{ userId },
			{ $inc: { balance: amount }, $set: { updatedAt: new Date() } },
			{ returnDocument: "after", upsert: true, session: session ?? undefined },
		);
		return result || null;
	},

	/**
	 * Append a transaction to the ledger.
	 */
	async createTransaction(
		transaction: UserWalletTransaction,
		session?: ClientSession | null,
	): Promise<UserWalletTransaction> {
		const result = await transactionCollection.insertOne(transaction as any, {
			session: session ?? undefined,
		});
		return { ...transaction, _id: result.insertedId };
	},

	/**
	 * Get a user's transactions with pagination (newest first).
	 */
	async getTransactions(
		userId: string,
		page: number,
		limit: number,
	): Promise<UserWalletTransaction[]> {
		const skip = (page - 1) * limit;
		return transactionCollection
			.find({ userId })
			.sort({ createdAt: -1 })
			.skip(skip)
			.limit(limit)
			.toArray();
	},

	/**
	 * Count a user's transactions.
	 */
	async getTotalTransactions(userId: string): Promise<number> {
		return transactionCollection.countDocuments({ userId });
	},

	/**
	 * Sum of all debt across users (absolute value of negative balances).
	 * Used to derive the cafeteria's pending revenue.
	 */
	async sumNegativeBalances(): Promise<number> {
		const result = await walletCollection
			.aggregate([
				{ $match: { balance: { $lt: 0 } } },
				{ $group: { _id: null, total: { $sum: "$balance" } } },
			])
			.toArray();
		return result.length > 0 ? Math.abs(result[0].total) : 0;
	},

	/**
	 * All users who currently owe money (negative balance), with the amount owed.
	 */
	async getUsersWithDebt(): Promise<{ userId: string; debt: number }[]> {
		const rows = await walletCollection
			.find({ balance: { $lt: 0 } })
			.toArray();
		return rows.map((w) => ({ userId: w.userId, debt: -w.balance }));
	},
};
