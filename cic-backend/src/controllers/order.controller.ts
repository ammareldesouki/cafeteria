/**
 * Controller Layer - Orders HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import { Request, Response, NextFunction } from "express";
import { orderService } from "@/services/order.service";
import { OrderStatus, PaymentStatus } from "@/types/order.types";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";

/**
 * Create a new order from cart
 * POST /orders
 */
export const createOrder = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		console.log("Better-Auth User Data:", (req as any).user);
		const userId = (req as any).user.id;
		const userEmail = (req as any).user.email;
		const username = (req as any).user.name;
		const userPhone = (req as any).user.phoneNumber;

		const deliveryLocation = req.body.deliveryLocation as string | undefined;
		// Optional order-level note / special instructions.
		const note = req.body.note as string | undefined;
		// Optional scheduled time (ISO string). Absent/invalid = order now.
		const rawScheduled = req.body.scheduledFor as string | undefined;
		let scheduledFor: Date | undefined;
		if (rawScheduled) {
			const d = new Date(rawScheduled);
			if (!Number.isNaN(d.getTime())) scheduledFor = d;
		}

		const order = await orderService.createOrderFromCart(
			userId,
			userEmail,
			deliveryLocation,
			username,
			userPhone,
			scheduledFor,
			note,
		);

		res.status(201).json(order);
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};

/**
 * Get all orders for user
 * GET /orders
 */
export const getUserOrders = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		// Parse input
		const userId = (req as any).user.id;

		// Call service
		const orders = await orderService.getUserOrders(userId);

		// Return response
		res.json(orders);
	} catch (err) {
		next(err);
	}
};

/**
 * Get a single order by ID
 * GET /orders/:id
 */
export const getOrderById = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		// Parse input
		const userId = (req as any).user.id;
		const id = req.params.id as string;

		// Call service
		const order = await orderService.getOrderById(id, userId);

		// Return response
		res.json(order);
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};

/**
 * Update order status
 * PATCH /orders/:id/status
 */
export const updateOrderStatus = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		// Parse input
		const userId = (req as any).user.id;
		const id = req.params.id as string;
		const { status } = req.body;

		// Call service
		const order = await orderService.updateOrderStatus(
			id,
			userId,
			status as OrderStatus,
		);

		// Return response
		res.json(order);
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};

/**
 * Update payment status
 * PATCH /orders/:id/payment
 */
export const updateOrderPayment = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = (req as any).user.id;
		const id = req.params.id as string;
		const { paymentStatus } = req.body;

		const order = await orderService.updateOrderPayment(
			id,
			userId,
			paymentStatus as PaymentStatus,
		);

		res.json(order);
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};

/**
 * Cancel order
 * POST /orders/:id/cancel
 */
export const cancelOrder = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = (req as any).user.id;
		const id = req.params.id as string;

		const order = await orderService.cancelOrder(id, userId);

		res.json(order);
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};
