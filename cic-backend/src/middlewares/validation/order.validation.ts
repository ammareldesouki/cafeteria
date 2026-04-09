/**
 * Validation Middleware - Order Input Validation
 * Validates request data before reaching controllers
 */
import { Request, Response, NextFunction } from "express";
import { OrderStatus, PaymentStatus } from "@/types/order.types";

/**
 * Validate create order request body
 * Note: Order is created from cart, so only deliveryLocation is validated (optional)
 */
export const validateCreateOrder = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const { deliveryLocation } = req.body;

	if (deliveryLocation !== undefined && typeof deliveryLocation !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "deliveryLocation must be a string if provided",
		});
	}

	next();
};

/**
 * Validate order status update
 */
export const validateOrderStatus = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const { status } = req.body;

	if (!status || !Object.values(OrderStatus).includes(status as OrderStatus)) {
		return res.status(400).json({
			message: `Invalid status. Must be one of: ${Object.values(OrderStatus).join(", ")}`,
		});
	}

	next();
};

/**
 * Validate payment status update
 */
export const validatePaymentStatus = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const { paymentStatus } = req.body;

	if (
		!paymentStatus ||
		!Object.values(PaymentStatus).includes(paymentStatus as PaymentStatus)
	) {
		return res.status(400).json({
			message: `Invalid paymentStatus. Must be one of: ${Object.values(PaymentStatus).join(", ")}`,
		});
	}

	next();
};

/**
 * Validate admin order update (status and/or paymentStatus)
 */
export const validateAdminOrderUpdate = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const { status, paymentStatus } = req.body;

	// At least one field must be provided
	if (status === undefined && paymentStatus === undefined) {
		return res.status(400).json({
			message: "At least one field (status or paymentStatus) must be provided",
		});
	}

	// Validate status if provided
	if (status !== undefined) {
		if (!Object.values(OrderStatus).includes(status as OrderStatus)) {
			return res.status(400).json({
				message: `Invalid status. Must be: ${Object.values(OrderStatus).join(", ")}`,
			});
		}
	}

	// Validate paymentStatus if provided
	if (paymentStatus !== undefined) {
		if (
			!Object.values(PaymentStatus).includes(paymentStatus as PaymentStatus)
		) {
			return res.status(400).json({
				message: `Invalid paymentStatus. Must be: ${Object.values(PaymentStatus).join(", ")}`,
			});
		}
	}

	next();
};

/**
 * Validate pagination parameters
 */
export const validatePagination = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const page = Number.parseInt(req.query.page as string) || 1;
	const limit = Number.parseInt(req.query.limit as string) || 10;

	if (page < 1 || limit < 1 || limit > 1000) {
		return res.status(400).json({
			message: "Invalid pagination. Page >= 1, Limit 1-1000",
		});
	}

	// Attach parsed values to request for controller to use
	(req as any).pagination = { page, limit };

	next();
};

/**
 * Validate and parse order filters
 */
export const validateOrderFilters = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const filters: any = {};

	if (req.query.userId) {
		filters.userId = req.query.userId as string;
	}

	if (req.query.search) {
		filters.search = req.query.search as string;
	}

	if (req.query.dateRange) {
		filters.dateRange = req.query.dateRange as string;
	}

	if (req.query.paymentStatus) {
		const paymentStatus = req.query.paymentStatus as string;
		if (
			!Object.values(PaymentStatus).includes(paymentStatus as PaymentStatus)
		) {
			return res.status(400).json({
				message: `Invalid paymentStatus. Must be: ${Object.values(PaymentStatus).join(", ")}`,
			});
		}
		filters.paymentStatus = paymentStatus as PaymentStatus;
	}

	if (req.query.status) {
		const status = req.query.status as string;
		if (!Object.values(OrderStatus).includes(status as OrderStatus)) {
			return res.status(400).json({
				message: `Invalid status. Must be: ${Object.values(OrderStatus).join(", ")}`,
			});
		}
		filters.status = status as OrderStatus;
	}

	// Attach parsed filters to request for controller to use
	(req as any).filters = filters;

	next();
};
