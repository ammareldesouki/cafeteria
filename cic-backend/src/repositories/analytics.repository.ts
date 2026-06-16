/**
 * Repository Layer - Analytics Data Access
 * MongoDB aggregation queries for dashboard analytics
 */
import mongoose from "mongoose";
import { OrderStatus } from "@/types/order.types";
import { walletRepository } from "@/repositories/wallet.repository";
import { userWalletRepository } from "@/repositories/userWallet.repository";

const collection = mongoose.connection.collection("orders");

export const analyticsRepository = {
	/**
	 * Get count of active (pending) orders
	 */
	async getActiveOrdersCount(): Promise<number> {
		return collection.countDocuments({ status: OrderStatus.PENDING });
	},

	/**
	 * Get total count of all orders
	 */
	async getTotalOrdersCount(): Promise<number> {
		return collection.countDocuments({});
	},

	/**
	 * Realized revenue = the cafeteria wallet balance (cash actually received,
	 * via per-order payments and manual debt settlements). Wallet-derived so it
	 * stays consistent with partial payments.
	 */
	async getTotalRevenue(): Promise<number> {
		const wallet = await walletRepository.getWallet();
		return wallet?.balance ?? 0;
	},

	/**
	 * Pending revenue = total money still owed by customers, i.e. the sum of all
	 * negative user-wallet balances. Equals the total shown on the Pending
	 * Revenue screen and drops when a (partial) payment is recorded.
	 */
	async getPendingRevenue(): Promise<number> {
		return userWalletRepository.sumNegativeBalances();
	},
};
