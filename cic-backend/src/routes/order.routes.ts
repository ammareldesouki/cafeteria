/**
 * Orders Routes
 * Defines API endpoints for order operations
 */
import { Router } from "express";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";
import {
  validateCreateOrder,
  validateOrderStatus,
  validatePaymentStatus,
} from "@/middlewares/validation";
import {
  createOrder,
  getUserOrders,
  getOrderById,
  updateOrderStatus,
  updateOrderPayment,
} from "@/controllers/order.controller";

const router = Router();

// All routes require authentication
router.post("/orders", requireAuth, validateCreateOrder, createOrder);
router.get("/orders", requireAuth, getUserOrders);
router.get("/orders/:id", requireAuth, getOrderById);
router.patch(
  "/orders/:id/status",
  requireAuth,
  validateOrderStatus,
  updateOrderStatus,
);
router.patch(
  "/orders/:id/payment",
  requireAuth,
  validatePaymentStatus,
  updateOrderPayment,
);

export default router;
