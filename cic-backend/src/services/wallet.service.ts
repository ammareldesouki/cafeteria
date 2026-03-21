/**
 * Service Layer - Wallet Business Logic
 * Manages wallet operations and transaction recording
 */
import { walletRepository } from "@/repositories/wallet.repository";
import {
  CafeteriaWallet,
  WalletTransaction,
  TransactionType,
  PaginatedResponse,
} from "@/types/wallet.types";

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
   * Record payment (credit to wallet)
   */
  async recordPayment(orderId: string, amount: number): Promise<void> {
    // Update wallet balance
    await walletRepository.updateBalance(amount);

    // Create transaction record
    const transaction: WalletTransaction = {
      orderId,
      amount,
      type: TransactionType.CREDIT,
      description: `Payment received for order ${orderId}`,
      createdAt: new Date(),
    };

    await walletRepository.createTransaction(transaction);
  },

  /**
   * Record delivery without payment (debit from wallet - credit owed)
   */
  async recordDelivery(orderId: string, amount: number): Promise<void> {
    // Deduct from wallet (can go negative)
    await walletRepository.updateBalance(-amount);

    // Create transaction record
    const transaction: WalletTransaction = {
      orderId,
      amount,
      type: TransactionType.DEBIT,
      description: `Order ${orderId} delivered unpaid (credit)`,
      createdAt: new Date(),
    };

    await walletRepository.createTransaction(transaction);
  },
};
