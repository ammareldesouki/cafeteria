/**
 * Favorites Routes
 * Defines API endpoints for favorite operations
 */
import { Router } from "express";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";
import {
	validateItemIdBody,
	validateItemIdParam,
} from "@/middlewares/validation";
import {
	addFavorite,
	getFavorites,
	removeFavorite,
} from "@/controllers/favorite.controller";

const router = Router();

// All routes require authentication
router.post("/favorites", requireAuth, validateItemIdBody, addFavorite);
router.get("/favorites", requireAuth, getFavorites);
router.delete(
	"/favorites/:itemId",
	requireAuth,
	validateItemIdParam,
	removeFavorite,
);

export default router;
