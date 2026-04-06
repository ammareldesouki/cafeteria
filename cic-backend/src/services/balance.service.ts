/**
 * Service Layer - Balance Business Logic
 * Handles user balance operations (read-only from client perspective)
 * Balance is automatically updated through order processing only
 */
import { walletService } from "@/services/wallet.service";

export const balanceService = {
	/**
	 * Get user balance (read-only)
	 */
	async getBalance(): Promise<{ balance: number }> {
		const wallet = await walletService.getWalletBalance();
		return { balance: wallet.balance };
	},

	/**
	 * Deduct balance when order is placed (called internally by order service)
	 * Balance can go negative (credit system)
	 */
	async deductBalanceForOrder(orderId: string, amount: number): Promise<void> {
		await walletService.recordDelivery(orderId, amount);
	},

	/**
	 * Add balance when payment is received (called internally by order service)
	 */
	async addBalanceForPayment(orderId: string, amount: number): Promise<void> {
		await walletService.recordPayment(orderId, amount);
	},
};
