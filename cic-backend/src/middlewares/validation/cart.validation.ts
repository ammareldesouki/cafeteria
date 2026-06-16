 /**
 * Validation Middleware - Cart Input Validation
 * Validates request data before reaching controllers
 */
import { Request, Response, NextFunction } from "express";

export const validateAddCartItem = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	let { menuItemId, variantName, quantity, note } = req.body || {};
	const { sugar } = req.body || {};

	if (variantName === null) {
		variantName = undefined;
		req.body.variantName = undefined;
	} else if (typeof variantName === "string") {
		variantName = variantName.trim() === "" ? undefined : variantName.trim();
		req.body.variantName = variantName;
	}

	if (note === null) {
		note = undefined;
		req.body.note = undefined;
	} else if (typeof note === "string") {
		note = note.trim() === "" ? undefined : note.trim();
		req.body.note = note;
	}

	if (!menuItemId || typeof menuItemId !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "menuItemId is required and must be a string",
		});
	}

	if (variantName !== undefined && typeof variantName !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "variantName must be a string if provided",
		});
	}

	if (note !== undefined && typeof note !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "note must be a string if provided",
		});
	}

	if (quantity === undefined || typeof quantity !== "number") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "quantity is required and must be a number",
		});
	}

	if (!Number.isInteger(quantity) || quantity <= 0) {
		return res.status(400).json({
			error: "INVALID_QUANTITY",
			message: "quantity must be a positive integer",
		});
	}

	if (
		sugar !== undefined &&
		(typeof sugar !== "number" || !Number.isInteger(sugar) || sugar < 0)
	) {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "sugar must be a non-negative integer if provided",
		});
	}

	next();
};

export const validateUpdateCartItem = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const { itemId } = req.params || {};
	let { variantName, quantity, note } = req.body || {};

	if (variantName === null) {
		variantName = undefined;
		req.body.variantName = undefined;
	} else if (typeof variantName === "string") {
		variantName = variantName.trim() === "" ? undefined : variantName.trim();
		req.body.variantName = variantName;
	}

	if (note === null) {
		note = undefined;
		req.body.note = undefined;
	} else if (typeof note === "string") {
		note = note.trim() === "" ? undefined : note.trim();
		req.body.note = note;
	}

	if (!itemId || typeof itemId !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "itemId parameter is required and must be a string",
		});
	}

	if (variantName !== undefined && typeof variantName !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "variantName must be a string if provided",
		});
	}

	if (note !== undefined && typeof note !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "note must be a string if provided",
		});
	}

	if (quantity === undefined || typeof quantity !== "number") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "quantity is required and must be a number",
		});
	}

	if (!Number.isInteger(quantity) || quantity <= 0) {
		return res.status(400).json({
			error: "INVALID_QUANTITY",
			message: "quantity must be a positive integer",
		});
	}

	next();
};

export const validateRemoveCartItem = (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	const { itemId } = req.params || {};
	let variantName = req.query.variantName as string | undefined;
	let note = req.query.note as string | undefined;

	if (typeof variantName === "string") {
		variantName = variantName.trim() === "" ? undefined : variantName.trim();
		req.query.variantName = variantName;
	}

	if (typeof note === "string") {
		note = note.trim() === "" ? undefined : note.trim();
		req.query.note = note;
	}

	if (!itemId || typeof itemId !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "itemId parameter is required and must be a string",
		});
	}

	if (variantName !== undefined && typeof variantName !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "variantName must be a string if provided",
		});
	}

	if (note !== undefined && typeof note !== "string") {
		return res.status(400).json({
			error: "INVALID_REQUEST",
			message: "note must be a string if provided",
		});
	}

	next();
};