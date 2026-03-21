/**
 * Analytics Routes (Admin Only)
 */
import { Router } from "express";
import { requireAdmin } from "@/middlewares/auth/requireAdmin.middleware";
import { getDashboardAnalytics } from "@/controllers/analytics.controller";

const router = Router();

// All routes require admin authentication
router.get("/analytics", requireAdmin, getDashboardAnalytics);

export default router;
