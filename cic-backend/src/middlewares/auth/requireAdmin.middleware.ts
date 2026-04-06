/**
 * Admin Authorization Middleware
 * Verifies user is authenticated AND has admin role
 */
import { Request, Response, NextFunction } from "express";
import { auth } from "@/integration/better-auth/auth";
import { fromNodeHeaders } from "better-auth/node";

export async function requireAdmin(
	req: Request,
	res: Response,
	next: NextFunction,
) {
	try {
		// First authenticate user
		const session = await auth.api.getSession({
			headers: fromNodeHeaders(req.headers),
		});

		if (!session?.user) {
			return res.status(401).json({ message: "Unauthorized" });
		}

		// Check admin role
		if (session.user.role !== "admin") {
			return res.status(403).json({ message: "Admin access required" });
		}

		/* inject the user into the request */
		req.user = session.user;

		next();
	} catch (error) {
		console.error("Auth Error:", error);
		return res.status(401).json({ message: "Unauthorized" });
	}
}
