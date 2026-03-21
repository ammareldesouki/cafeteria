/**
 * Admin Routes
 * Combines all admin-only endpoints under /admin prefix
 */
import { Router } from "express";
import { requireAdmin } from "@/middlewares/auth/requireAdmin.middleware";
import {
  validatePagination,
  validateOrderFilters,
  validateAdminOrderUpdate,
} from "@/middlewares/validation";
import { getAllOrders, updateOrder } from "@/controllers/admin.controller";
import walletRoutes from "./wallet.routes";
import analyticsRoutes from "./analytics.routes";

const router = Router();

// Admin order management
router.get(
  "/orders",
  requireAdmin,
  validatePagination,
  validateOrderFilters,
  getAllOrders,
);
router.patch("/orders/:id", requireAdmin, validateAdminOrderUpdate, updateOrder);

// Mount sub-routes
router.use(walletRoutes);
router.use(analyticsRoutes);

export default router;
