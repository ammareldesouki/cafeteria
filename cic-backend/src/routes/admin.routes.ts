import { Router } from "express";
import { requireAdmin } from "@/middlewares/auth/requireAdmin.middleware";
import {
	adminGetMenu,
	adminCreateMenuItem,
	adminUpdateMenuItem,
	adminDeleteMenuItem,
	adminSetItemStock,
	adminSetVariantStock,
	adminAddVariant,
	adminRemoveVariant,
} from "@/controllers/menu.controller";
import {
	getAllOrders,
	updateOrder,
	getPendingUsers,
	settleUserDebt,
} from "@/controllers/admin.controller";
import {
	validateCreateMenuItem,
	validateUpdateMenuItem,
	validateSetStock,
	validateAddVariant,
	validatePagination,
	validateOrderFilters,
	validateAdminOrderUpdate,
} from "@/middlewares/validation";
import walletRoutes from "./wallet.routes";
import analyticsRoutes from "./analytics.routes";

const router = Router();

// Admin menu management
router.get("/menu", requireAdmin, adminGetMenu);
router.post("/menu", requireAdmin, validateCreateMenuItem, adminCreateMenuItem);
router.put(
	"/menu/:id",
	requireAdmin,
	validateUpdateMenuItem,
	adminUpdateMenuItem,
);
router.delete("/menu/:id", requireAdmin, adminDeleteMenuItem);
router.patch("/menu/:id/stock", requireAdmin, validateSetStock, adminSetItemStock);
router.patch(
	"/menu/:id/variants/:variantName/stock",
	requireAdmin,
	validateSetStock,
	adminSetVariantStock,
);
router.post(
	"/menu/:id/variants",
	requireAdmin,
	validateAddVariant,
	adminAddVariant,
);
router.delete(
	"/menu/:id/variants/:variantName",
	requireAdmin,
	adminRemoveVariant,
);

// Admin order management
router.get(
	"/orders",
	requireAdmin,
	validatePagination,
	validateOrderFilters,
	getAllOrders,
);
router.patch(
	"/orders/:id",
	requireAdmin,
	validateAdminOrderUpdate,
	updateOrder,
);

// Pending revenue (debt) management
router.get("/pending-users", requireAdmin, getPendingUsers);
router.post("/users/:userId/settle", requireAdmin, settleUserDebt);

// Mount sub-routes
router.use(walletRoutes);
router.use(analyticsRoutes);

export default router;
