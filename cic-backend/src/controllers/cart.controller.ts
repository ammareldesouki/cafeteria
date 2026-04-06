/**
 * Controller Layer - Cart HTTP Handler
 * Handles cart-related HTTP requests
 */
import { Request, Response, NextFunction } from "express";
import { cartService } from "@/services/cart.service";
import { logger } from "@/utils/logger";
export const getCart = async (
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
		const cart = await cartService.getOrCreateCart(userId);
		res.json({ data: cart, meta: { timestamp: new Date().toISOString() } });
	} catch (err) {
		logger.error(`[GET /cart] ${(err as Error).message}`);
		next(err);
	}
};
export const addCartItem = async (
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
		const { menuItemId, variantName, quantity, note } = req.body as {
			menuItemId: string;
			variantName?: string;
			quantity: number;
			note?: string;
		};
		const item = await cartService.addItem(
			userId,
			menuItemId,
			quantity,
			variantName,
			note,
		);
		res
			.status(201)
			.json({ data: item, meta: { timestamp: new Date().toISOString() } });
	} catch (err) {
		logger.error(`[POST /cart/items] ${(err as Error).message}`);
		next(err);
	}
};
export const updateCartItem = async (
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
		const itemId = req.params.itemId as string;
	
		const { variantName, quantity, note } = req.body as {
			variantName?: string;
			quantity: number;
			note?: string;
		};
		const item = await cartService.updateItemQuantity(
			userId,
			itemId,
			quantity,
			variantName,
			note,
		);
		res.json({ data: item, meta: { timestamp: new Date().toISOString() } });
	} catch (err) {
		logger.error(`[PUT /cart/items/:itemId] ${(err as Error).message}`);
		next(err);
	}
};
export const removeCartItem = async (
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
		const itemId = req.params.itemId as string;
const variantName = req.query.variantName as string | undefined;
		const note = req.query.note as string | undefined;

		await cartService.removeItem(userId, itemId, variantName, note);
		res.status(204).send();
	} catch (err) {
		logger.error(`[DELETE /cart/items/:itemId] ${(err as Error).message}`);
		next(err);
	}
};
export const clearCart = async (
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
		await cartService.clearCart(userId);
		res.status(204).send();
	} catch (err) {
		logger.error(`[DELETE /cart] ${(err as Error).message}`);
		next(err);
	}
};
