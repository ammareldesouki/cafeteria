/**
 * Service Layer - Wallet Business Logic
 * Manages wallet operations and transaction recording
 */
import { walletRepository } from "@/repositories/wallet.repository";
import {
	type CafeteriaWallet,
	type PaginatedResponse,
	TransactionType,
	type WalletTransaction,
} from "@/types/wallet.types";
import { runWalletTransaction } from "@/utils/walletTransaction";

export const walletService = {
	/**
	 * Get wallet balance (creates wallet if not exists)
	 */
	async getWalletBalance(): Promise<CafeteriaWallet> {
		let wallet = await walletRepository.getWallet();

		if (!wallet) {
			wallet = await walletRepository.createWallet();
		}

		return wallet;
	},

	/**
	 * Get wallet details with transaction history
	 */
	async getWalletDetails(
		page: number = 1,
		limit: number = 10,
	): Promise<{
		balance: number;
		updatedAt: Date;
		transactions: PaginatedResponse<WalletTransaction>;
	}> {
		const wallet = await this.getWalletBalance();
		const transactions = await walletRepository.getTransactions(page, limit);
		const totalCount = await walletRepository.getTotalTransactions();

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
	 * Record realized revenue (credit) when an order is settled paid.
	 * Writes the balance and ledger row atomically.
	 */
	async recordPayment(orderId: string, amount: number): Promise<void> {
		await runWalletTransaction(async (session) => {
			await walletRepository.updateBalance(amount, session);
			await walletRepository.createTransaction(
				{
					orderId,
					amount,
					type: TransactionType.CREDIT,
					description: `Payment received for order ${orderId}`,
					createdAt: new Date(),
				},
				session,
			);
		});
	},

	/**
	 * Reverse realized revenue (debit) when a previously-paid order is
	 * refunded, cancelled, or its payment is reverted to unpaid.
	 */
	async recordReversal(orderId: string, amount: number): Promise<void> {
		await runWalletTransaction(async (session) => {
			await walletRepository.updateBalance(-amount, session);
			await walletRepository.createTransaction(
				{
					orderId,
					amount,
					type: TransactionType.DEBIT,
					description: `Revenue reversed for order ${orderId}`,
					createdAt: new Date(),
				},
				session,
			);
		});
	},
};
