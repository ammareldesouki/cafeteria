/**
 * Service Layer - Per-User Wallet Business Logic
 *
 * A user's balance is a debt ledger: it goes negative when an order is delivered
 * unpaid (the user owes money) and returns toward 0 when that debt is settled.
 * Each balance change writes the cached balance and a ledger row atomically.
 */
import { userWalletRepository } from "@/repositories/userWallet.repository";
import type {
	UserWallet,
	UserWalletTransaction,
} from "@/types/userWallet.types";
import { type PaginatedResponse, TransactionType } from "@/types/wallet.types";
import { runWalletTransaction } from "@/utils/walletTransaction";

export const userWalletService = {
	/**
	 * Get a user's balance (creates an empty wallet on first access).
	 */
	async getBalance(userId: string): Promise<UserWallet> {
		return userWalletRepository.getOrCreate(userId);
	},

	/**
	 * Get a user's balance + paginated transaction history.
	 */
	async getDetails(
		userId: string,
		page: number = 1,
		limit: number = 10,
	): Promise<{
		balance: number;
		updatedAt: Date;
		transactions: PaginatedResponse<UserWalletTransaction>;
	}> {
		const wallet = await this.getBalance(userId);
		const [transactions, totalCount] = await Promise.all([
			userWalletRepository.getTransactions(userId, page, limit),
			userWalletRepository.getTotalTransactions(userId),
		]);

		return {
			balance: wallet.balance,
			updatedAt: wallet.updatedAt,
			transactions: {
				data: transactions,
				totalCount,
				page,
				limit,
				totalPages: Math.ceil(totalCount / limit),
			},
		};
	},

	/**
	 * Debit a user (order delivered unpaid). Balance decreases → user owes money.
	 */
	async debit(userId: string, orderId: string, amount: number): Promise<void> {
		await runWalletTransaction(async (session) => {
			await userWalletRepository.updateBalance(userId, -amount, session);
			await userWalletRepository.createTransaction(
				{
					userId,
					orderId,
					amount,
					type: TransactionType.DEBIT,
					description: `Order ${orderId} delivered unpaid (owed)`,
					createdAt: new Date(),
				},
				session,
			);
		});
	},

	/**
	 * Credit a user (debt settled / order paid). Balance increases toward 0.
	 */
	async credit(userId: string, orderId: string, amount: number): Promise<void> {
		await runWalletTransaction(async (session) => {
			await userWalletRepository.updateBalance(userId, amount, session);
			await userWalletRepository.createTransaction(
				{
					userId,
					orderId,
					amount,
					type: TransactionType.CREDIT,
					description: `Order ${orderId} debt settled`,
					createdAt: new Date(),
				},
				session,
			);
		});
	},
};
