import { Router, Request, Response, NextFunction } from "express";
import { toNodeHandler } from "better-auth/node";
import { auth } from "@/integration/better-auth/auth";
import { authNameFromEmailMiddleware } from "@/middlewares/auth/nonNameGuard.middleware";
import mongoose from "mongoose";

const router = Router();

router.use(
	"/auth",
	async (req: Request, res: Response, next: NextFunction) => {
		// Disabled for now: password reset endpoints
		// if (req.path === "/request-password-reset" || req.path === "/reset-password") {
		// 	res.status(404).json({ message: "Password reset is disabled" });
		// 	return;
		// }

		if (req.path === "/sign-up/email") {
			return authNameFromEmailMiddleware(req, res, next);
		}

		// Allow using phone number as identifier anywhere Better Auth expects "email"
		// (sign-in + password reset request).
		if (req.path === "/sign-in/email") {
			const identifier = req.body?.email;
			// If it doesn't contain an @, assume it is a phone number and look it up
			if (identifier && !identifier.includes("@")) {
				try {
					const user = await mongoose.connection.db
						?.collection("user")
						.findOne({ phoneNumber: identifier });

					if (user && user.email) {
						req.body.email = user.email; // Override to allow better-auth to use email
					}
				} catch (err) {
					console.error("Failed to lookup user by phone number", err);
				}
			}
		}

		next();
	},
	toNodeHandler(auth),
);

export default router;
