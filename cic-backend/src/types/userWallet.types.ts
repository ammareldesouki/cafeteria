/**
 * Type definitions for the per-user wallet (debt ledger).
 *
 * A user's `balance` is negative when they owe the cafeteria money (an order was
 * delivered but not paid). It returns toward 0 as those debts are settled.
 */
import type { ObjectId } from "mongodb";
import type { TransactionType } from "@/types/wallet.types";

export interface UserWallet {
	_id?: ObjectId;
	userId: string;
	balance: number;
	updatedAt: Date;
}

export interface UserWalletTransaction {
	_id?: ObjectId;
	userId: string;
	orderId?: string;
	amount: number;
	type: TransactionType;
	description: string;
	createdAt: Date;
}
