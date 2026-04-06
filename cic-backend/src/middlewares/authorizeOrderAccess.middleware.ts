/**
 * Middleware - Order Access Authorization
 * Ensures users can only access their own orders
 */
import { Request, Response, NextFunction } from "express";
import { orderRepository } from "@/repositories/order.repository";
import { UnauthorizedOrderAccessError } from "@/utils/errors";

export const authorizeOrderAccess = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		const orderId = req.params.orderId as string;

		if (!userId) {
			res.status(401).json({ error: { code: 401, message: "Unauthorized" } });
			return;
		}

		if (!orderId) {
			next();
			return;
		}

		const order = await orderRepository.findById(orderId);

		if (!order) {
			next();
			return;
		}

		if (order.userId !== userId) {
			throw new UnauthorizedOrderAccessError(orderId);
		}

		next();
	} catch (err) {
		next(err);
	}
};
