/**
 * Service Layer - Orders Business Logic
 * Orchestrates order operations. Validates items exist, manages order lifecycle.
 */
import { orderRepository } from "@/repositories/order.repository";
import {
	Order,
	OrderItem,
	OrderStatus,
	PaymentStatus,
	isValidStatusTransition,
} from "@/types/order.types";
import { walletService } from "@/services/wallet.service";
import { stockService } from "@/services/stock.service";
import { balanceService } from "@/services/balance.service";
import { cartRepository } from "@/repositories/cart.repository";
import {
	UnauthorizedOrderAccessError,
	InvalidStatusTransitionError,
	OrderNotCancellableError,
	EmptyCartError,
} from "@/utils/errors";
import { ObjectId } from "mongodb";
import mongoose from "mongoose";

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
		username?: string,         // 4th
		userPhone?: string,
	): Promise<Order> {
		const cart = await cartRepository.findByUserId(userId);

		if (!cart || cart.items.length === 0) {
			throw new EmptyCartError();
		}

		const stockItems = cart.items.map((item) => ({
			menuItemId: item.menuItemId.toString(),
			variantName: item.variantName,
			quantity: item.quantity,
		}));

		const reservations = await stockService.reserveStockBatch(stockItems);

		// Build order items with names and notes from the cart
		const orderItems: OrderItem[] = [];
		for (let i = 0; i < reservations.length; i++) {
			const res = reservations[i];
			const cartItem = cart.items[i];

			// Look up item name from menu
			const { menuRepository } = await import(
				"@/repositories/menu.repository"
			);
			const menuItem = await menuRepository.findById(
				cartItem.menuItemId.toString(),
			);

			orderItems.push({
				menuItemId:
					typeof res.menuItemId === "string"
						? new ObjectId(res.menuItemId)
						: res.menuItemId,
				menuItemName: menuItem?.name,
				...(res.variantName && { variantName: res.variantName }),
				...(cartItem?.note && { note: cartItem.note }),
				quantity: res.quantity,
				unitPrice: res.unitPrice,
			});
		}

		const totalPrice = orderItems.reduce(
			(sum, item) => sum + item.unitPrice * item.quantity,
			0,
		);

		const userDoc = await mongoose.connection.collection("user").findOne({ id: userId });

		       console.log(userDoc);

		
		const order: Order = {
			userId,
			username,
			userPhone,
			userEmail,
			items: orderItems,
			totalPrice,
			...(deliveryLocation && { deliveryLocation }),
			status: OrderStatus.PENDING,
			paymentStatus: PaymentStatus.UNPAID,
			createdAt: new Date(),
			updatedAt: new Date(),
		};

		const createdOrder = await orderRepository.create(order);

		await balanceService.deductBalanceForOrder(
			createdOrder._id!.toString(),
			totalPrice,
		);

		await cartRepository.clearCart(userId);
       console.log(userDoc?.name);
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
		await walletService.recordRefund(orderId, order.totalPrice);

		const updated = await orderRepository.updateStatus(
			orderId,
			OrderStatus.CANCELLED,
		);
		if (!updated) {
			throw new Error("Failed to cancel order");
		}

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
	 * Update order by admin (no ownership check)
	 * Automatically updates wallet when payment status changes
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
		const originalPaymentStatus = order.paymentStatus;

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
			
			// Handle admin cancellation
			if (updates.status === OrderStatus.CANCELLED && originalStatus !== OrderStatus.CANCELLED) {
				const stockItems = order.items.map((item) => ({
					menuItemId: item.menuItemId.toString(),
					variantName: item.variantName,
					quantity: item.quantity,
				}));
				await stockService.restoreStockBatch(stockItems);
				await walletService.recordRefund(orderId, order.totalPrice);
			}

			Object.assign(order, updated);
		}

		if (updates.paymentStatus !== undefined) {
			const updated = await orderRepository.updatePaymentStatus(
				orderId,
				updates.paymentStatus,
			);
			if (!updated) {
				throw new Error("Failed to update order status");
			}
			Object.assign(order, updated);
		}

		const finalOrder = await orderRepository.findById(orderId);
		if (!finalOrder) {
			throw new Error("Order not found after update");
		}

		const paymentStatusChanged =
			updates.paymentStatus !== undefined &&
			originalPaymentStatus !== updates.paymentStatus;

		const statusChanged =
			updates.status !== undefined && originalStatus !== updates.status;

		if (
			paymentStatusChanged &&
			originalPaymentStatus === PaymentStatus.UNPAID &&
			updates.paymentStatus === PaymentStatus.PAID
		) {
			await walletService.recordPayment(orderId, finalOrder.totalPrice);
		} else if (
			paymentStatusChanged &&
			originalPaymentStatus === PaymentStatus.PAID &&
			updates.paymentStatus === PaymentStatus.UNPAID
		) {
			await walletService.recordDelivery(orderId, finalOrder.totalPrice);
		} else if (
			statusChanged &&
			updates.status === OrderStatus.COMPLETED &&
			finalOrder.paymentStatus === PaymentStatus.UNPAID &&
			originalPaymentStatus === PaymentStatus.UNPAID
		) {
			await walletService.recordDelivery(orderId, finalOrder.totalPrice);
		} else if (
			statusChanged &&
			paymentStatusChanged &&
			updates.status === OrderStatus.COMPLETED &&
			updates.paymentStatus === PaymentStatus.PAID
		) {
			await walletService.recordPayment(orderId, finalOrder.totalPrice);
		}
		
		// If order was cancelled and had payment, we already handled refund above based on the status change block.
		// However if they mark it PAID *and* CANCELLED at the same time, we might have conflicting logic.
		// The simplest approach is we assume cancel takes precedence for the refund logic embedded above.

		return finalOrder;
	},
};
