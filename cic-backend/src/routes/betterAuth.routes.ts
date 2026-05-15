import { Router, Request, Response, NextFunction } from "express";
import { toNodeHandler } from "better-auth/node";
import { auth } from "@/integration/better-auth/auth";
import { authNameFromEmailMiddleware } from "@/middlewares/auth/nonNameGuard.middleware";
import mongoose from "mongoose";

const router = Router();

router.use(
	"/auth",
	async (req: Request, res: Response, next: NextFunction) => {
		if (req.path === "/sign-up/email") {
			return authNameFromEmailMiddleware(req, res, next);
		}

		// Enabled: Allow using phone number as identifier for sign-in AND password reset
		if (req.path === "/sign-in/email" || req.path === "/forget-password") {
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

		// Pre-check: if user exists but has no password credential, better-auth crashes
		// with an empty 500. Catch it here and return a helpful error instead.
		if (req.path === "/sign-in/email") {
			const email = req.body?.email;
			if (email) {
				try {
					const db = mongoose.connection.db;
					const user = await db?.collection("user").findOne({ email });
					if (user) {
						// userId is stored as ObjectId — also check string form for legacy rows
						const credential = await db?.collection("account").findOne({
							userId: { $in: [user._id, user._id.toString()] },
							providerId: "credential",
						});
						if (!credential) {
							// User exists but has no password yet (e.g. signed up via Google).
							// Guide them to use Forgot Password to set one.
							res.status(400).json({
								success: false,
								error: {
									code: 400,
									message:
										"No password set for this account. Use 'Forgot Password' to set a password, then sign in with email.",
								},
							});
							return;
						}
					}
				} catch (err) {
					console.error("Pre-check failed, continuing to better-auth:", err);
				}
			}
		}

		next();
	},
	(req: Request, res: Response, next: NextFunction) => {
		// toNodeHandler bypasses Express error middleware — wrap it so crashes
		// produce a proper JSON 500 instead of an empty response.
		try {
			const handler = toNodeHandler(auth);
			Promise.resolve(handler(req, res, next)).catch((err: unknown) => {
				if (!res.headersSent) {
					res.status(500).json({
						success: false,
						error: {
							code: 500,
							message:
								err instanceof Error ? err.message : "Internal server error",
						},
					});
				}
				console.error("[BetterAuth] unhandled error:", err);
			});
		} catch (err: unknown) {
			next(err);
		}
	},
);

export default router;
