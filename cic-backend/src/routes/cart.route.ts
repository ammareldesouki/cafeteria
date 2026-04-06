/**
 * Routes - Cart API
 * Handles cart-related HTTP routes
 */
import { Router } from "express";
import {
	getCart,
	addCartItem,
	updateCartItem,
	removeCartItem,
	clearCart,
} from "@/controllers/cart.controller";
import {
	validateAddCartItem,
	validateUpdateCartItem,
	validateRemoveCartItem,
} from "@/middlewares/validation";

import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";

const router = Router();

router.use(requireAuth);

router.get("/", getCart);
router.post("/items", validateAddCartItem, addCartItem);
router.put("/items/:itemId", validateUpdateCartItem, updateCartItem);
router.delete("/items/:itemId", validateRemoveCartItem, removeCartItem);
router.delete("/", clearCart);

export default router;
