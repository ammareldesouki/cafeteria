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

export interface OrderItemExtra {
	name: string;
	price: number;
}

export interface OrderItem {
	menuItemId: ObjectId;
	menuItemName?: string;
	variantName?: string;
	note?: string;
	/** Selected sugar amount (spoons), copied from the cart item. */
	sugar?: number;
	quantity: number;
	unitPrice: number;
	/** Priced extras selected by the customer, copied from cart item. */
	selectedExtras?: OrderItemExtra[];
}

export interface Order {
	_id?: ObjectId;
	userId: string;
	username?: string;
	userPhone?: string;
	userEmail: string;
	items: OrderItem[];
	totalPrice: number;
	deliveryLocation?: string;
	/** Order-level note / special instructions from the customer. */
	note?: string;
	/** When the customer wants the order (same-day). Absent = as soon as possible. */
	scheduledFor?: Date;
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
