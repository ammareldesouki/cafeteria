/**
 * Service Layer - Orders Business Logic
 * Orchestrates order operations. Validates items exist, manages order lifecycle.
 */

import { ObjectId } from "mongodb";
import { cartRepository } from "@/repositories/cart.repository";
import { fcmRepository } from "@/repositories/fcm.repository";
import { orderRepository } from "@/repositories/order.repository";
import { sendPushNotification } from "@/services/fcm.service";
import { stockService } from "@/services/stock.service";
import { userWalletService } from "@/services/userWallet.service";
import { walletService } from "@/services/wallet.service";
import {
	isValidStatusTransition,
	type Order,
	type OrderItem,
	OrderStatus,
	PaymentStatus,
} from "@/types/order.types";
import {
	EmptyCartError,
	InvalidStatusTransitionError,
	OrderNotCancellableError,
	UnauthorizedOrderAccessError,
} from "@/utils/errors";

/**
 * Wallet effect of an order state, expressed as signed balance contributions.
 * - User owes (negative balance) while an order is delivered but unpaid.
 * - Cafeteria realizes revenue (positive balance) once an order is paid.
 * Settlement is computed as the *delta* between the before/after states, so any
 * transition (deliver-unpaid, pay later, deliver+pay, reversal, cancel) is
 * handled uniformly and cancel always nets out whatever was applied.
 */
function userBalanceEffect(o: {
	status: OrderStatus;
	paymentStatus: PaymentStatus;
	totalPrice: number;
}): number {
	return o.status === OrderStatus.DELIVERED &&
		o.paymentStatus === PaymentStatus.UNPAID
		? -o.totalPrice
		: 0;
}

function cafeteriaRevenueEffect(o: {
	status: OrderStatus;
	paymentStatus: PaymentStatus;
	totalPrice: number;
}): number {
	return o.paymentStatus === PaymentStatus.PAID &&
		o.status !== OrderStatus.CANCELLED
		? o.totalPrice
		: 0;
}

/**
 * Apply the wallet changes needed to move an order from `before` to `after`.
 */
async function settleWallets(
	userId: string,
	orderId: string,
	before: {
		status: OrderStatus;
		paymentStatus: PaymentStatus;
		totalPrice: number;
	},
	after: {
		status: OrderStatus;
		paymentStatus: PaymentStatus;
		totalPrice: number;
	},
): Promise<void> {
	const userDelta = userBalanceEffect(after) - userBalanceEffect(before);
	const cafeteriaDelta =
		cafeteriaRevenueEffect(after) - cafeteriaRevenueEffect(before);

	if (userDelta > 0) {
		await userWalletService.credit(userId, orderId, userDelta);
	} else if (userDelta < 0) {
		await userWalletService.debit(userId, orderId, -userDelta);
	}

	if (cafeteriaDelta > 0) {
		await walletService.recordPayment(orderId, cafeteriaDelta);
	} else if (cafeteriaDelta < 0) {
		await walletService.recordReversal(orderId, -cafeteriaDelta);
	}
}

/**
 * Push a "new order" notification to every registered staff device.
 * Best-effort: any failure is logged and swallowed so checkout still succeeds.
 */
async function notifyStaffOfNewOrder(
	order: Order,
	scheduledFor?: Date,
): Promise<void> {
	try {
		const tokens = await fcmRepository.getAllTokens();
		if (tokens.length === 0) return;

		const itemCount = order.items.reduce((n, it) => n + it.quantity, 0);
		const who = order.username ?? "A customer";
		const when = scheduledFor
			? ` for ${scheduledFor.toLocaleTimeString("en-US", {
					hour: "2-digit",
					minute: "2-digit",
				})}`
			: "";

		await sendPushNotification(tokens, {
			title: "🛎️ New Order",
			body: `${who} placed an order${when} — ${itemCount} item(s), ${order.totalPrice} EGP.`,
			data: {
				orderId: order._id?.toString() ?? "",
				type: "new_order",
			},
		});
	} catch (err) {
		console.error("New-order push failed:", err);
	}
}

export const orderService = {
	/**
	 * Create a new order from the user's cart
	 * Reserves stock at order creation (not at processing)
	 * Deducts balance (credit system allows negative balance)
	 */
	async createOrderFromCart(
		userId: string,
		userEmail: string,
		deliveryLocation?: string,
		username?: string,
		userPhone?: string,
		scheduledFor?: Date,
		note?: string,
	): Promise<Order> {
		const cart = await cartRepository.findByUserId(userId);

		if (!cart || cart.items.length === 0) {
			throw new EmptyCartError();
		}

		// Drop cart lines whose menu item no longer exists (deleted items),
		// so a stale cart entry can't block checkout with a confusing
		// "insufficient stock" error.
		const { menuRepository } = await import("@/repositories/menu.repository");
		const validCartItems = [];
		for (const item of cart.items) {
			const exists = await menuRepository.findById(item.menuItemId.toString());
			if (exists) validCartItems.push(item);
		}

		if (validCartItems.length === 0) {
			throw new EmptyCartError();
		}

		const stockItems = validCartItems.map((item) => ({
			menuItemId: item.menuItemId.toString(),
			variantName: item.variantName,
			quantity: item.quantity,
		}));

		const reservations = await stockService.reserveStockBatch(stockItems);

		// Build order items with names and notes from the cart
		const orderItems: OrderItem[] = [];
		for (let i = 0; i < reservations.length; i++) {
			const res = reservations[i];
			const cartItem = validCartItems[i];

			// Look up item name from menu
			const menuItem = await menuRepository.findById(
				cartItem.menuItemId.toString(),
			);

			const extrasTotal =
				((cartItem as any).selectedExtras ?? []).reduce(
					(sum: number, e: any) => sum + e.price,
					0,
				);

			orderItems.push({
				menuItemId:
					typeof res.menuItemId === "string"
						? new ObjectId(res.menuItemId)
						: res.menuItemId,
				menuItemName: menuItem?.name,
				...(res.variantName && { variantName: res.variantName }),
				...(cartItem?.note && { note: cartItem.note }),
				...(typeof cartItem?.sugar === "number" && { sugar: cartItem.sugar }),
				quantity: res.quantity,
				unitPrice: res.unitPrice,
				...(extrasTotal > 0 && {
					selectedExtras: (cartItem as any).selectedExtras,
				}),
			});
		}

		const totalPrice = orderItems.reduce(
			(sum, item) => {
				const extrasSum =
					(item.selectedExtras ?? []).reduce(
						(s, e) => s + e.price,
						0,
					);
				return sum + (item.unitPrice + extrasSum) * item.quantity;
			},
			0,
		);

		const order: Order = {
			userId,
			username,
			userPhone,
			userEmail,
			items: orderItems,
			totalPrice,
			...(deliveryLocation && { deliveryLocation }),
			...(note && { note }),
			...(scheduledFor && { scheduledFor }),
			status: OrderStatus.PENDING,
			paymentStatus: PaymentStatus.UNPAID,
			createdAt: new Date(),
			updatedAt: new Date(),
		};

		// Order is placed unpaid; no wallet movement happens until the order is
		// delivered (settlement is handled in updateOrderByAdmin / cancelOrder).
		const createdOrder = await orderRepository.create(order);

		await cartRepository.clearCart(userId);

		// Notify staff that a new order arrived. Fire-and-forget: a push failure
		// must never break checkout.
		void notifyStaffOfNewOrder(createdOrder, scheduledFor);

		return createdOrder;
	},

	/**
	 * Get all orders for a user
	 */
	async getUserOrders(userId: string): Promise<Order[]> {
		return orderRepository.findByUserId(userId);
	},

	/**
	 * Get a single order by ID
	 * Includes user ownership check
	 */
	async getOrderById(orderId: string, userId: string): Promise<Order> {
		const order = await orderRepository.findById(orderId);

		if (!order) {
			throw new Error("Order not found");
		}

		if (order.userId !== userId) {
			throw new UnauthorizedOrderAccessError(orderId);
		}

		return order;
	},

	/**
	 * Update order status
	 * Includes user ownership check
	 */
	async updateOrderStatus(
		orderId: string,
		userId: string,
		status: OrderStatus,
	): Promise<Order> {
		const order = await orderRepository.findById(orderId);

		if (!order) {
			throw new Error("Order not found");
		}

		if (order.userId !== userId) {
			throw new UnauthorizedOrderAccessError(orderId);
		}

		if (!isValidStatusTransition(order.status, status)) {
			throw new InvalidStatusTransitionError(orderId, order.status, status);
		}

		const updated = await orderRepository.updateStatus(orderId, status);
		if (!updated) {
			throw new Error("Failed to update order status");
		}

		return updated;
	},

	/**
	 * Update payment status
	 * Includes user ownership check
	 */
	async updateOrderPayment(
		orderId: string,
		userId: string,
		paymentStatus: PaymentStatus,
	): Promise<Order> {
		const order = await orderRepository.findById(orderId);

		if (!order) {
			throw new Error("Order not found");
		}

		if (order.userId !== userId) {
			throw new UnauthorizedOrderAccessError(orderId);
		}

		const updated = await orderRepository.updatePaymentStatus(
			orderId,
			paymentStatus,
		);
		if (!updated) {
			throw new Error("Failed to update order status");
		}

		return updated;
	},

	/**
	 * Cancel an order
	 * Restores stock and updates status to cancelled
	 * Only pending orders can be cancelled by user; admin can cancel processing orders
	 */
	async cancelOrder(
		orderId: string,
		userId: string,
		isAdmin: boolean = false,
	): Promise<Order> {
		const order = await orderRepository.findById(orderId);

		if (!order) {
			throw new Error("Order not found");
		}

		if (order.userId !== userId && !isAdmin) {
			throw new UnauthorizedOrderAccessError(orderId);
		}

		if (
			order.status !== OrderStatus.PENDING &&
			order.status !== OrderStatus.PROCESSING
		) {
			throw new OrderNotCancellableError(orderId, order.status);
		}

		if (order.status === OrderStatus.PROCESSING && !isAdmin) {
			throw new OrderNotCancellableError(orderId, order.status);
		}

		const stockItems = order.items.map((item) => ({
			menuItemId: item.menuItemId.toString(),
			variantName: item.variantName,
			quantity: item.quantity,
		}));

		await stockService.restoreStockBatch(stockItems);

		const updated = await orderRepository.updateStatus(
			orderId,
			OrderStatus.CANCELLED,
		);
		if (!updated) {
			throw new Error("Failed to cancel order");
		}

		// Reverse only the wallet effects that were actually applied
		// (clears a user's debt for a delivered-unpaid order, or reverses
		// realized revenue for a paid order; no-op for a pending order).
		await settleWallets(order.userId, orderId, order, updated);

		return updated;
	},

	/**
	 * Get all orders with filters and pagination (admin only)
	 */
	async getAllOrders(
		filters: {
			userId?: string;
			paymentStatus?: PaymentStatus;
			status?: OrderStatus;
		},
		page: number = 1,
		limit: number = 10,
	): Promise<{
		data: Order[];
		totalCount: number;
		page: number;
		limit: number;
		totalPages: number;
	}> {
		const maxLimit = Math.min(limit, 1000);

		const [orders, totalCount] = await Promise.all([
			orderRepository.findAllPaginated(page, maxLimit, filters),
			orderRepository.countWithFilters(filters),
		]);

		return {
			data: orders,
			totalCount,
			page,
			limit: maxLimit,
			totalPages: Math.ceil(totalCount / maxLimit),
		};
	},

	/**
	 * Update order by admin (no ownership check).
	 * Settles the user wallet and cafeteria wallet based on the net change
	 * between the order's original and final (status, paymentStatus).
	 */
	async updateOrderByAdmin(
		orderId: string,
		updates: {
			status?: OrderStatus;
			paymentStatus?: PaymentStatus;
		},
	): Promise<Order> {
		const order = await orderRepository.findById(orderId);

		if (!order) {
			throw new Error("Order not found");
		}

		const originalStatus = order.status;

		if (updates.status !== undefined) {
			if (!isValidStatusTransition(originalStatus, updates.status)) {
				throw new InvalidStatusTransitionError(
					orderId,
					originalStatus,
					updates.status,
				);
			}

			const updated = await orderRepository.updateStatus(
				orderId,
				updates.status,
			);
			if (!updated) {
				throw new Error("Failed to update order status");
			}

			// Restore stock on cancellation
			if (
				updates.status === OrderStatus.CANCELLED &&
				originalStatus !== OrderStatus.CANCELLED
			) {
				const stockItems = order.items.map((item) => ({
					menuItemId: item.menuItemId.toString(),
					variantName: item.variantName,
					quantity: item.quantity,
				}));
				await stockService.restoreStockBatch(stockItems);
			}
		}

		if (updates.paymentStatus !== undefined) {
			const updated = await orderRepository.updatePaymentStatus(
				orderId,
				updates.paymentStatus,
			);
			if (!updated) {
				throw new Error("Failed to update payment status");
			}
		}

		const finalOrder = await orderRepository.findById(orderId);
		if (!finalOrder) {
			throw new Error("Order not found after update");
		}

		// Single source of truth for wallet movement: the delta between the
		// original and final order state. Handles deliver-unpaid (user debit),
		// pay-now/pay-later (user credit + cafeteria revenue), reversal, and
		// cancellation (nets out whatever was previously applied) uniformly.
		await settleWallets(finalOrder.userId, orderId, order, finalOrder);

		return finalOrder;
	},
};
