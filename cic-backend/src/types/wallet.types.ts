/**
 * Type definitions for Cafeteria Wallet System
 */
import { ObjectId } from "mongodb";

export interface CafeteriaWallet {
	_id?: ObjectId;
	balance: number;
	updatedAt: Date;
}

export enum TransactionType {
	CREDIT = "credit", // Money received
	DEBIT = "debit", // Money owed
}

export interface WalletTransaction {
	_id?: ObjectId;
	walletId?: string;
	orderId?: string;
	amount: number;
	type: TransactionType;
	description: string;
	createdAt: Date;
}

export interface PaginationParams {
	page: number;
	limit: number;
}

export interface PaginatedResponse<T> {
	data: T[];
	totalCount: number;
	page: number;
	limit: number;
	totalPages: number;
}
