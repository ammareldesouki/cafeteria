/**
 * Repository Layer - Wallet Data Access
 * Manages cafeteria wallet and transaction ledger
 */
import mongoose from "mongoose";
import {
	CafeteriaWallet,
	WalletTransaction,
	TransactionType,
} from "@/types/wallet.types";
import { ObjectId } from "mongodb";

const walletCollection =
	mongoose.connection.collection<CafeteriaWallet>("cafeteria_wallets");
const transactionCollection = mongoose.connection.collection<WalletTransaction>(
	"cafeteria_wallet_transactions",
);

export const walletRepository = {
	/**
	 * Get the cafeteria wallet (singleton)
	 */
	async getWallet(): Promise<CafeteriaWallet | null> {
		return walletCollection.findOne({});
	},

	/**
	 * Create wallet if not exists
	 */
	async createWallet(): Promise<CafeteriaWallet> {
		const wallet: CafeteriaWallet = {
			balance: 0,
			updatedAt: new Date(),
		};
		const result = await walletCollection.insertOne(wallet as any);
		return { ...wallet, _id: result.insertedId };
	},

	/**
	 * Update wallet balance
	 */
	async updateBalance(amount: number): Promise<CafeteriaWallet | null> {
		const result = await walletCollection.findOneAndUpdate(
			{},
			{
				$inc: { balance: amount },
				$set: { updatedAt: new Date() },
			},
			{ returnDocument: "after", upsert: true },
		);
		return result || null;
	},

	/**
	 * Create a transaction record
	 */
	async createTransaction(
		transaction: WalletTransaction,
	): Promise<WalletTransaction> {
		const result = await transactionCollection.insertOne(transaction as any);
		return { ...transaction, _id: result.insertedId };
	},

	/**
	 * Get transactions with pagination
	 */
	async getTransactions(
		page: number,
		limit: number,
	): Promise<WalletTransaction[]> {
		const skip = (page - 1) * limit;
		return transactionCollection
			.find({})
			.sort({ createdAt: -1 })
			.skip(skip)
			.limit(limit)
			.toArray();
	},

	/**
	 * Get total transaction count
	 */
	async getTotalTransactions(): Promise<number> {
		return transactionCollection.countDocuments({});
	},
};
