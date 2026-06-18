import { Request, Response, NextFunction } from "express";
import { fcmRepository } from "@/repositories/fcm.repository";

/**
 * POST /admin/fcm-token
 * Register a device FCM token for the logged-in admin.
 */
export const registerFcmToken = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const userId = req.user?.id;
		if (!userId) {
			res.status(401).json({ message: "Unauthorized" });
			return;
		}
		const { token, lang } = req.body as { token: string; lang?: string };
		if (!token) {
			res.status(400).json({ message: "token is required" });
			return;
		}

		// Role comes from the authenticated session (not the client) so staff
		// alerts can't be spoofed.
		const role = (req as any).user?.role;
		await fcmRepository.registerToken(userId, token, lang, role);
		res.status(201).json({ success: true });
	} catch (err) {
		next(err);
	}
};

/**
 * DELETE /admin/fcm-token
 * Unregister a device FCM token (logout).
 */
export const unregisterFcmToken = async (
	req: Request,
	res: Response,
	next: NextFunction,
) => {
	try {
		const { token } = req.body as { token: string };
		if (!token) {
			res.status(400).json({ message: "token is required" });
			return;
		}

		await fcmRepository.unregisterToken(token);
		res.json({ success: true });
	} catch (err) {
		next(err);
	}
};
