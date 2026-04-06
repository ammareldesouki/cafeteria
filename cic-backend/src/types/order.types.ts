/**
 * Type definitions for Orders
 */
import { ObjectId } from "mongodb";

export enum OrderStatus {
	PENDING = "pending",
	PROCESSING = "processing",
	COMPLETED = "completed",
	DELIVERED = "delivered",
	CANCELLED = "cancelled",
}

export enum PaymentStatus {
	PAID = "paid",
	UNPAID = "unpaid",
}

export interface OrderItem {
	menuItemId: ObjectId;
	variantName?: string;
	quantity: number;
	unitPrice: number;
}

export interface Order {
	_id?: ObjectId;
	userId: string;
	userEmail: string;
	items: OrderItem[];
	totalPrice: number;
	deliveryLocation?: string;
	status: OrderStatus;
	paymentStatus: PaymentStatus;
	createdAt: Date;
	updatedAt: Date;
}

/**
 * Valid order status transitions
 * Key: current status
 * Value: array of allowed next statuses
 */
export const VALID_STATUS_TRANSITIONS: Record<OrderStatus, OrderStatus[]> = {
	[OrderStatus.PENDING]: [OrderStatus.PROCESSING, OrderStatus.CANCELLED],
	[OrderStatus.PROCESSING]: [OrderStatus.COMPLETED, OrderStatus.CANCELLED],
	[OrderStatus.COMPLETED]: [OrderStatus.DELIVERED],
	[OrderStatus.DELIVERED]: [],
	[OrderStatus.CANCELLED]: [],
};

/**
 * Check if a status transition is valid
 */
export function isValidStatusTransition(
	from: OrderStatus,
	to: OrderStatus,
): boolean {
	return VALID_STATUS_TRANSITIONS[from]?.includes(to) ?? false;
}
