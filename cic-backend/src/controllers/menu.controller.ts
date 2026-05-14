/**
 * Controller Layer - HTTP Handler (Admin Menu Management)
 * Handles request/response only. Delegates to menuService.
 * No business logic, no direct DB access.
 */
import { Request, Response, NextFunction } from "express";
import { menuService } from "@/services/menu.service";
import { CreateMenuItemInput, UpdateMenuItemInput } from "@/repositories/menu.repository";

// ─── Public ──────────────────────────────────────────────────────────────────

export const getMenu = async (
	_req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const items = await menuService.getAllMenuItems();
		res.json(items);
	} catch (err) {
		next(err);
	}
};

export const updateMenuItemStock = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = req.params.id as string;
		const { in_stock } = req.body as { in_stock: boolean };

		const updated = await menuService.updateItemStock(id, in_stock);
		res.json(updated);
	} catch (err) {
		next(err);
	}
};

// ─── Admin CRUD ───────────────────────────────────────────────────────────────

/**
 * GET /admin/menu
 * List all menu items (same as public but admin-gated)
 */
export const adminGetMenu = async (
	_req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const items = await menuService.getAllMenuItems();
		res.json(items);
	} catch (err) {
		next(err);
	}
};

/**
 * POST /admin/menu
 * Create a new menu item
 */
export const adminCreateMenuItem = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const body = req.body as CreateMenuItemInput;
		const item = await menuService.createItem(body);
		res.status(201).json(item);
	} catch (err) {
		next(err);
	}
};

/**
 * PUT /admin/menu/:id
 * Update editable fields of a menu item
 */
export const adminUpdateMenuItem = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = String((req.params as any).id);
		const fields = req.body as UpdateMenuItemInput;
		const updated = await menuService.updateItem(id, fields);
		res.json(updated);
	} catch (err: any) {
		if (err.message === "Menu item not found") {
			res.status(404).json({ message: err.message });
			return;
		}
		next(err);
	}
};

/**
 * DELETE /admin/menu/:id
 * Delete a menu item
 */
export const adminDeleteMenuItem = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = String((req.params as any).id);
		const result = await menuService.deleteItem(id);
		res.json(result);
	} catch (err: any) {
		if (err.message === "Menu item not found") {
			res.status(404).json({ message: err.message });
			return;
		}
		next(err);
	}
};

// ─── Stock management ─────────────────────────────────────────────────────────

/**
 * PATCH /admin/menu/:id/stock
 * Set stock for a simple (no-variant) item
 */
export const adminSetItemStock = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = String((req.params as any).id);
		const { stock } = req.body as { stock: number };
		const updated = await menuService.setItemStock(id, stock);
		res.json(updated);
	} catch (err: any) {
		if (
			err.message === "Menu item not found" ||
			err.message?.includes("variants")
		) {
			res.status(400).json({ message: err.message });
			return;
		}
		next(err);
	}
};

/**
 * PATCH /admin/menu/:id/variants/:variantName/stock
 * Set stock for a specific variant
 */
export const adminSetVariantStock = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = String((req.params as any).id);
		const variantName = String((req.params as any).variantName);
		const { stock } = req.body as { stock: number };
		const updated = await menuService.setVariantStock(id, variantName, stock);
		res.json(updated);
	} catch (err: any) {
		if (
			err.message === "Menu item not found" ||
			err.message === "Variant not found or update failed" ||
			err.message?.includes("no variants")
		) {
			res.status(400).json({ message: err.message });
			return;
		}
		next(err);
	}
};

// ─── Variant management ───────────────────────────────────────────────────────

/**
 * POST /admin/menu/:id/variants
 * Add a variant to an existing item
 */
export const adminAddVariant = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = String((req.params as any).id);
		const { name, stock } = req.body as { name: string; stock?: number };
		const updated = await menuService.addVariant(id, { name, stock: stock ?? 0 });
		res.status(201).json(updated);
	} catch (err: any) {
		if (
			err.message === "Menu item not found" ||
			err.message?.includes("does not support") ||
			err.message?.includes("already exists")
		) {
			res.status(400).json({ message: err.message });
			return;
		}
		next(err);
	}
};

/**
 * DELETE /admin/menu/:id/variants/:variantName
 * Remove a variant from an item
 */
export const adminRemoveVariant = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const id = String((req.params as any).id);
		const variantName = String((req.params as any).variantName);
		const updated = await menuService.removeVariant(id, variantName);
		res.json(updated);
	} catch (err: any) {
		if (
			err.message === "Menu item not found" ||
			err.message === "Failed to remove variant"
		) {
			res.status(400).json({ message: err.message });
			return;
		}
		next(err);
	}
};
