/**
 * Validation Middleware — Menu CRUD
 * Validates request body/params for admin menu management endpoints.
 */
import { Request, Response, NextFunction } from "express";

// ─── Create / Update Item ────────────────────────────────────────────────────

export function validateCreateMenuItem(
	req: Request,
	res: Response,
	next: NextFunction,
) {
	const { name, price, category, hasVariants, variants } = req.body;

	if (!name || typeof name !== "string" || !name.trim()) {
		res.status(400).json({ message: "name is required and must be a string" });
		return;
	}
	if (price === undefined || typeof price !== "number" || price < 0) {
		res
			.status(400)
			.json({ message: "price is required and must be a non-negative number" });
		return;
	}
	if (!category || typeof category !== "string") {
		res
			.status(400)
			.json({ message: "category is required and must be a string" });
		return;
	}
	if (hasVariants === true) {
		if (!Array.isArray(variants) || variants.length === 0) {
			res.status(400).json({
				message:
					"variants array is required and must be non-empty when hasVariants is true",
			});
			return;
		}
		for (const v of variants) {
			if (!v.name || typeof v.name !== "string") {
				res
					.status(400)
					.json({ message: "Each variant must have a string 'name'" });
				return;
			}
			if (v.stock !== undefined && (typeof v.stock !== "number" || v.stock < 0)) {
				res
					.status(400)
					.json({ message: "Variant stock must be a non-negative number" });
				return;
			}
		}
	}
	next();
}

export function validateUpdateMenuItem(
	req: Request,
	res: Response,
	next: NextFunction,
) {
	const { price, hasVariants, variants } = req.body;

	if (price !== undefined && (typeof price !== "number" || price < 0)) {
		res.status(400).json({ message: "price must be a non-negative number" });
		return;
	}
	if (hasVariants === true && variants !== undefined) {
		if (!Array.isArray(variants)) {
			res.status(400).json({ message: "variants must be an array" });
			return;
		}
		for (const v of variants) {
			if (!v.name || typeof v.name !== "string") {
				res
					.status(400)
					.json({ message: "Each variant must have a string 'name'" });
				return;
			}
		}
	}
	next();
}

// ─── Stock ───────────────────────────────────────────────────────────────────

export function validateSetStock(
	req: Request,
	res: Response,
	next: NextFunction,
) {
	const { stock } = req.body;
	if (stock === undefined || typeof stock !== "number" || stock < 0) {
		res
			.status(400)
			.json({ message: "stock is required and must be a non-negative number" });
		return;
	}
	next();
}

// ─── Variant management ──────────────────────────────────────────────────────

export function validateAddVariant(
	req: Request,
	res: Response,
	next: NextFunction,
) {
	const { name, stock } = req.body;
	if (!name || typeof name !== "string" || !name.trim()) {
		res
			.status(400)
			.json({ message: "variant name is required and must be a string" });
		return;
	}
	if (stock !== undefined && (typeof stock !== "number" || stock < 0)) {
		res
			.status(400)
			.json({ message: "variant stock must be a non-negative number" });
		return;
	}
	next();
}
