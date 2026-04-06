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
	cancelOrder,
} from "@/controllers/order.controller";

const router = Router();

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
router.post("/orders/:id/cancel", requireAuth, cancelOrder);

export default router;
