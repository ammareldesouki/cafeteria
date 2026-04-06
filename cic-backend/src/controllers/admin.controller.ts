/**
 * Controller Layer - Admin Order Management HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import type { Request, Response, NextFunction } from "express";
import { orderService } from "@/services/order.service";
import { OrderStatus, PaymentStatus } from "@/types/order.types";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";

interface Pagination {
	page: number;
	limit: number;
}

interface OrderFilters {
	userId?: string;
	paymentStatus?: PaymentStatus;
	status?: OrderStatus;
}

interface RequestWithPagination extends Request {
	pagination?: Pagination;
	filters?: OrderFilters;
}

/**
 * Get all orders with filters and pagination
 * GET /admin/orders?page=1&limit=10&userId=&paymentStatus=&status=
 */
export const getAllOrders = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const reqWithPagination = req as RequestWithPagination;
		if (!reqWithPagination.pagination || !reqWithPagination.filters) {
			res.status(400).json({ message: "Missing pagination or filters" });
			return;
		}
		const { page, limit } = reqWithPagination.pagination;
		const filters = reqWithPagination.filters;

		const result = await orderService.getAllOrders(filters, page, limit);

		res.json(result);
	} catch (err) {
		next(err);
	}
};

/**
 * Update order (admin can update any order)
 * PATCH /admin/orders/:id
 */
export const updateOrder = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const orderId = req.params.id as string;
		const { status, paymentStatus } = req.body;

		const updates: { status?: OrderStatus; paymentStatus?: PaymentStatus } = {};
		if (status !== undefined) {
			updates.status = status as OrderStatus;
		}
		if (paymentStatus !== undefined) {
			updates.paymentStatus = paymentStatus as PaymentStatus;
		}

		const order = await orderService.updateOrderByAdmin(orderId, updates);

		res.json(order);
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};
