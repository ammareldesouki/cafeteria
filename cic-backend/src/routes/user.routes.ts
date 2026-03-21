/**
 * User Routes
 */
import { Router } from "express";
import { requireAuthNameMiddleware } from "@/middlewares/auth/updateUsername.middleware";
import { validateUpdateName } from "@/middlewares/validation";
import { updateName } from "@/controllers/user.controller";

const router = Router();

router.post(
  "/user/name",
  requireAuthNameMiddleware,
  validateUpdateName,
  updateName,
);

export default router;
