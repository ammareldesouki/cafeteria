/**
 * Service Error Handler Middleware
 * Maps service-level errors to appropriate HTTP responses
 * This removes error-handling logic from controllers
 */
import { Request, Response, NextFunction } from "express";

/**
 * Known service errors and their HTTP status codes
 */
const ERROR_STATUS_MAP: Record<string, number> = {
	"Order not found": 404,
	"Menu item not found": 404,
	"One or more menu items not found": 404,
	"Favorite not found": 404,
	Unauthorized: 403,
	"Item already favorited": 409,
	"Name already taken": 409,
	"Call number is required": 400,
};

/**
 * Handle service errors and convert to HTTP responses
 * Use this as the last catch handler in controllers
 */
export const handleServiceError = (err: any, res: Response) => {
	// Check if error message maps to a known status code
	const statusCode = ERROR_STATUS_MAP[err.message];

	if (statusCode) {
		return res.status(statusCode).json({ message: err.message });
	}

	// Handle authentication errors
	if (err.status === 401 || err.status === 403) {
		return res.status(401).json({ message: "Unauthorized" });
	}

	// Unknown error - will be caught by global error handler
	throw err;
};

/**
 * Wrapper to automatically handle service errors
 * Use this to wrap async controller functions
 */
export const withServiceErrorHandler =
	(
		handler: (req: Request, res: Response, next: NextFunction) => Promise<any>,
	) =>
	async (req: Request, res: Response, next: NextFunction) => {
		try {
			await handler(req, res, next);
		} catch (err) {
			try {
				handleServiceError(err, res);
			} catch (unhandledErr) {
				next(unhandledErr);
			}
		}
	};
