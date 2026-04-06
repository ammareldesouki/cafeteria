import { Request, Response, NextFunction } from "express";
import { NODE_ENV } from "@config/env";
import { logger } from "@utils/logger";

type WithStack = { stack?: string };
type ErrorWithStatus = Error & {
	status?: number;
	statusCode?: number;
	data?: unknown;
};

interface ErrorDetails {
	code: number;
	message: string;
	data?: unknown;
	stack?: string;
}
interface ErrorResponseBody {
	success: false;
	error: ErrorDetails;
}

const toErrorWithStatus = (err: unknown): ErrorWithStatus => {
	if (err instanceof Error) {
		return err as ErrorWithStatus;
	}

	const e = err as Error | undefined;
	const error = new Error(
		e?.message || "Internal Server Error",
	) as ErrorWithStatus;
	error.status = 500;
	error.statusCode = 500;
	return error;
};

const extractStack = (err: unknown): string | undefined => {
	if (err && typeof err === "object" && "stack" in err) {
		const s = (err as WithStack).stack;
		return typeof s === "string" ? s : undefined;
	}
	return undefined;
};

export const ErrorMiddleware = (
	error: unknown,
	req: Request,
	res: Response,
	_next: NextFunction,
) => {
	const err = toErrorWithStatus(error);
	const status = err.status || err.statusCode || 500;
	const message = err.message || "Something went wrong";

	if (res.headersSent) return _next(err);

	const stack = extractStack(err);
	logger.error(
		`[${req.method}] ${req.originalUrl} | ${status} | ${message}${stack ? `\n${stack}` : ""}`,
	);

	const body: ErrorResponseBody = {
		success: false,
		error: { code: status, message },
	};

	if (typeof err.data !== "undefined") body.error.data = err.data;
	if (NODE_ENV === "development" && stack) body.error.stack = stack;

	res.status(status).json(body);
};
