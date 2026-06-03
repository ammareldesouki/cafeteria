/**
 * Controller Layer - User HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import type { NextFunction, Request, Response } from "express";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";
import { orderRepository } from "@/repositories/order.repository";
import { balanceService } from "@/services/balance.service";
import { userService } from "@/services/user.service";
import { userWalletService } from "@/services/userWallet.service";
import { OrderStatus } from "@/types/order.types";
import { logger } from "@/utils/logger";

/**
 * Get current user profile including balance
 * GET /api/v1/users/me
 */
export const getUserProfile = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;

		if (!userId) {
			res.status(401).json({ error: { code: 401, message: "Unauthorized" } });
			return;
		}

		const { balance } = await balanceService.getBalance(userId);

		// Fetch order counts
		const [totalOrders, completedOrders] = await Promise.all([
			orderRepository.countWithFilters({ userId }),
			orderRepository.countWithFilters({
				userId,
				status: OrderStatus.DELIVERED, // Assuming DELIVERED is the final successful state as per screenshots
			}),
		]);

		res.json({
			data: {
				...req.user,
				balance,
				totalOrders,
				completedOrders,
			},
			meta: { timestamp: new Date().toISOString() },
		});
	} catch (err) {
		logger.error(`[GET /users/me] ${(err as Error).message}`);
		next(err);
	}
};

/**
 * Get current user's wallet balance
 * GET /api/v1/me/wallet
 */
export const getMyWallet = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			res.status(401).json({ error: { code: 401, message: "Unauthorized" } });
			return;
		}

		const wallet = await userWalletService.getBalance(userId);
		res.json({ balance: wallet.balance, updatedAt: wallet.updatedAt });
	} catch (err) {
		next(err);
	}
};

/**
 * Get current user's wallet balance + transaction history
 * GET /api/v1/me/wallet/details?page=1&limit=10
 */
export const getMyWalletDetails = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			res.status(401).json({ error: { code: 401, message: "Unauthorized" } });
			return;
		}

		const { page, limit } = (req as any).pagination;
		const details = await userWalletService.getDetails(userId, page, limit);
		res.json(details);
	} catch (err) {
		next(err);
	}
};

/**
 * Update user name
 * PATCH /user/name
 */
export const updateName = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { name } = req.body;

		const result = await userService.updateUserName(name, req.headers);

		res.json({ success: true, name: result.name });
	} catch (err) {
		try {
			handleServiceError(err, res);
		} catch (unhandledErr) {
			next(unhandledErr);
		}
	}
};
