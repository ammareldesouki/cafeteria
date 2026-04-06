import type { RequestHandler } from "express";

export const NotFoundMiddleware: RequestHandler = (_req, _res, next) => {
	const error = new Error("Not Found") as Error & { status: number };
	error.status = 404;
	next(error);
};
