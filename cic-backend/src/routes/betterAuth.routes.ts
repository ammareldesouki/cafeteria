import { Router, Request, Response, NextFunction } from "express";
import { toNodeHandler } from "better-auth/node";
import { auth } from "@/integration/better-auth/auth";
import { authNameFromEmailMiddleware } from "@/middlewares/auth/nonNameGuard.middleware";

const router = Router();

router.use(
  "/auth",
  (req: Request, res: Response, next: NextFunction) => {
    if (req.path === "/sign-up/email") {
      return authNameFromEmailMiddleware(req, res, next);
    }
    next();
  },
  toNodeHandler(auth)
);

export default router;
