import { Router } from "express";
import { cartController } from "@/controllers/cart.controller";
import { cartValidation } from "@/middlewares/validation/cart.validation";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";

const router = Router();

router.use(requireAuth);

// GET    /api/cart                      → get full cart with totals
// POST   /api/cart/items                → add item (or increment if exists)
// PATCH  /api/cart/items/:menuItemId    → update quantity / notes
// DELETE /api/cart/items/:menuItemId    → remove one item
// DELETE /api/cart                      → clear entire cart

router.get("/", cartController.getCart);
router.post("/items", cartValidation.addItem, cartController.addItem);
router.patch("/items/:menuItemId", cartValidation.menuItemIdParam, cartValidation.updateItem, cartController.updateItem);
router.delete("/items/:menuItemId", cartValidation.menuItemIdParam, cartController.removeItem);
router.delete("/", cartController.clearCart);

export default router;
