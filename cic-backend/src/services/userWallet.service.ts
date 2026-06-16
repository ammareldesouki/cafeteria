/**
 * Service Layer - Per-User Wallet Business Logic
 *
 * A user's balance is a debt ledger: it goes negative when an order is delivered
 * unpaid (the user owes money) and returns toward 0 when that debt is settled.
 * Each balance change writes the cached balance and a ledger row atomically.
 */
import { orderRepository } from "@/repositories/order.repository";
import { userWalletRepository } from "@/repositories/userWallet.repository";
import { walletService } from "@/services/wallet.service";
import type {
	UserWallet,
	UserWalletTransaction,
} from "@/types/userWallet.types";
import { type PaginatedResponse, TransactionType } from "@/types/wallet.types";
import { runWalletTransaction } from "@/utils/walletTransaction";

export interface PendingUser {
	userId: string;
	username: string;
	pendingAmount: number;
	unpaidOrders: number;
}

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

	/**
	 * List every user who currently owes money, with how much and over how many
	 * delivered-unpaid orders. The wallet balance is the source of truth for the
	 * amount owed (so it reflects any partial payments already made).
	 */
	async getPendingUsers(): Promise<{
		totalPending: number;
		userCount: number;
		users: PendingUser[];
	}> {
		const [debts, orderGroups] = await Promise.all([
			userWalletRepository.getUsersWithDebt(),
			orderRepository.deliveredUnpaidByUser(),
		]);
		const orderMap = new Map(orderGroups.map((g) => [g.userId, g]));

		const users: PendingUser[] = debts
			.map((d) => ({
				userId: d.userId,
				username: orderMap.get(d.userId)?.username ?? "Unknown",
				pendingAmount: d.debt,
				unpaidOrders: orderMap.get(d.userId)?.count ?? 0,
			}))
			.sort((a, b) => b.pendingAmount - a.pendingAmount);

		return {
			totalPending: users.reduce((s, u) => s + u.pendingAmount, 0),
			userCount: users.length,
			users,
		};
	},

	/**
	 * Record a payment against a user's debt — the full amount or a partial
	 * `amount`. Credits the user wallet and the cafeteria's realized revenue
	 * atomically; a full settle also flips the user's delivered-unpaid orders to
	 * paid (directly, without re-running wallet settlement).
	 */
	async settleUserDebt(
		userId: string,
		amount?: number,
	): Promise<{ paid: number; balance: number }> {
		const wallet = await userWalletRepository.getOrCreate(userId);
		const debt = wallet.balance < 0 ? -wallet.balance : 0;
		if (debt <= 0) {
			throw new Error("User has no outstanding balance");
		}

		// Default to full debt; clamp partials to [0, debt] so the wallet can
		// never overshoot into a positive (credit) balance.
		let pay = amount === undefined ? debt : amount;
		if (!Number.isFinite(pay) || pay <= 0) {
			throw new Error("Payment amount must be greater than 0");
		}
		if (pay > debt) pay = debt;

		await runWalletTransaction(async (session) => {
			await userWalletRepository.updateBalance(userId, pay, session);
			await userWalletRepository.createTransaction(
				{
					userId,
					amount: pay,
					type: TransactionType.CREDIT,
					description: "Manual payment",
					createdAt: new Date(),
				},
				session,
			);
		});

		// Realize the cash on the cafeteria's wallet.
		await walletService.recordPayment(`manual:${userId}`, pay);

		// If the debt is now fully cleared, mark the orders paid too so the order
		// views stay consistent (no extra wallet movement here).
		if (pay >= debt) {
			await orderRepository.markUserDeliveredOrdersPaid(userId);
		}

		const updated = await userWalletRepository.getOrCreate(userId);
		return { paid: pay, balance: updated.balance };
	},
};
