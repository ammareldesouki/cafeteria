/**
 * Custom Error Classes
 * Provides specific error types for domain-specific errors
 */

export class AppError extends Error {
	public readonly statusCode: number;
	public readonly code: string;
	public readonly details?: unknown;

	constructor(
		message: string,
		statusCode: number,
		code: string,
		details?: unknown,
	) {
		super(message);
		this.name = this.constructor.name;
		this.statusCode = statusCode;
		this.code = code;
		this.details = details;
		Error.captureStackTrace(this, this.constructor);
	}
}

export class InsufficientStockError extends AppError {
	constructor(itemId: string, requested: number, available: number) {
		super(
			`Insufficient stock for item ${itemId}: requested ${requested}, available ${available}`,
			400,
			"INSUFFICIENT_STOCK",
			{ itemId, requested, available },
		);
	}
}

export class InvalidQuantityError extends AppError {
	constructor(quantity: number, reason: string) {
		super(`Invalid quantity: ${reason}`, 400, "INVALID_QUANTITY", {
			quantity,
			reason,
		});
	}
}

export class VariantRequiredError extends AppError {
	constructor(itemId: string) {
		super(
			`Variant selection required for item ${itemId}`,
			400,
			"VARIANT_REQUIRED",
			{ itemId },
		);
	}
}

export class CartItemNotFoundError extends AppError {
	constructor(itemId: string) {
		super(`Cart item not found: ${itemId}`, 404, "CART_ITEM_NOT_FOUND", {
			itemId,
		});
	}
}

export class UnauthorizedOrderAccessError extends AppError {
	constructor(orderId: string) {
		super(
			`Unauthorized access to order ${orderId}`,
			403,
			"UNAUTHORIZED_ORDER_ACCESS",
			{ orderId },
		);
	}
}

export class OrderNotCancellableError extends AppError {
	constructor(orderId: string, currentStatus: string) {
		super(
			`Order ${orderId} cannot be cancelled in status: ${currentStatus}`,
			400,
			"ORDER_NOT_CANCELLABLE",
			{ orderId, currentStatus },
		);
	}
}

export class InvalidStatusTransitionError extends AppError {
	constructor(orderId: string, fromStatus: string, toStatus: string) {
		super(
			`Invalid status transition for order ${orderId}: ${fromStatus} → ${toStatus}`,
			400,
			"INVALID_STATUS_TRANSITION",
			{ orderId, fromStatus, toStatus },
		);
	}
}

export class ItemNotFoundError extends AppError {
	constructor(itemId: string) {
		super(`Menu item not found: ${itemId}`, 404, "ITEM_NOT_FOUND", { itemId });
	}
}

export class EmptyCartError extends AppError {
	constructor() {
		super("Cart is empty", 400, "EMPTY_CART");
	}
}
