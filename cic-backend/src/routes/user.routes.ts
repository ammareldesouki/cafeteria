/**
 * User Routes
 */
import { Router } from "express";
import {
	getMyWallet,
	getMyWalletDetails,
	getUserProfile,
	updateName,
} from "@/controllers/user.controller";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";
import { requireAuthNameMiddleware } from "@/middlewares/auth/updateUsername.middleware";
import {
	validateUpdateName,
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

export default router;
