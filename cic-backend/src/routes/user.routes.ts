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

export default router;
