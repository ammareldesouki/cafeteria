/**
 * Controller Layer - User HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import { Request, Response, NextFunction } from "express";
import { userService } from "@/services/user.service";
import { balanceService } from "@/services/balance.service";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";
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

		const { balance } = await balanceService.getBalance();

		res.json({
			data: {
				id: userId,
				balance,
			},
			meta: { timestamp: new Date().toISOString() },
		});
	} catch (err) {
		logger.error(`[GET /users/me] ${(err as Error).message}`);
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
