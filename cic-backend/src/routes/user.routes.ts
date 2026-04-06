/**
 * User Routes
 */
import { Router } from "express";
import { requireAuthNameMiddleware } from "@/middlewares/auth/updateUsername.middleware";
import { validateUpdateName } from "@/middlewares/validation";
import { updateName, getUserProfile } from "@/controllers/user.controller";
import { requireAuth } from "@/middlewares/auth/requireAuth.middleware";

const router = Router();

router.get("/me", requireAuth, getUserProfile);
router.post(
	"/user/name",
	requireAuthNameMiddleware,
	validateUpdateName,
	updateName,
);

export default router;
