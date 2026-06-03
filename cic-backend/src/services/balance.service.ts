/**
 * Service Layer - Balance Business Logic
 * Thin wrapper exposing the *user's own* wallet balance (read-only).
 * Balance is a debt ledger: negative = the user owes the cafeteria money.
 * It is mutated only through order settlement (see order.service.ts).
 */
import { userWalletService } from "@/services/userWallet.service";

export const balanceService = {
	/**
	 * Get a user's own balance (read-only). Negative = owes the cafeteria.
	 */
	async getBalance(userId: string): Promise<{ balance: number }> {
		const wallet = await userWalletService.getBalance(userId);
		return { balance: wallet.balance };
	},
};
