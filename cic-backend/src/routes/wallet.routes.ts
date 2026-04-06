/**
 * Wallet Routes (Admin Only)
 */
import { Router } from "express";
import { requireAdmin } from "@/middlewares/auth/requireAdmin.middleware";
import { validateWalletPagination } from "@/middlewares/validation";
import {
	getWalletBalance,
	getWalletDetails,
} from "@/controllers/wallet.controller";

const router = Router();

// All routes require admin authentication
router.get("/wallet", requireAdmin, getWalletBalance);
router.get(
	"/wallet/details",
	requireAdmin,
	validateWalletPagination,
	getWalletDetails,
);

export default router;
