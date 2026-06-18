/**
 * User Routes
 */
import { Router } from "express";
import {
	getMyWallet,
	getMyWalletDetails,
	getUserProfile,
	updateName,
	updatePhone,
} from "@/controllers/user.controller";
import {
	registerFcmToken,
	unregisterFcmToken,
} from "@/controllers/fcm.controller";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";
import { requireAuthNameMiddleware } from "@/middlewares/auth/updateUsername.middleware";
import {
	validateUpdateName,
	validateUpdatePhone,
	validateWalletPagination,
} from "@/middlewares/validation";

const router = Router();

router.get("/me", requireAuth, getUserProfile);
router.get("/me/wallet", requireAuth, getMyWallet);
router.get(
	"/me/wallet/details",
	requireAuth,
	validateWalletPagination,
	getMyWalletDetails,
);
router.post(
	"/user/name",
	requireAuthNameMiddleware,
	validateUpdateName,
	updateName,
);
router.post(
	"/user/phone",
	requireAuthNameMiddleware,
	validateUpdatePhone,
	updatePhone,
);

// FCM token registration for ANY authenticated user (customers + staff), so
// customers can receive order-tracking notifications.
router.post("/fcm-token", requireAuth, registerFcmToken);
router.delete("/fcm-token", requireAuth, unregisterFcmToken);

export default router;
