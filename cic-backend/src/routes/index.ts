import { Router } from "express";
import healthRoute from "./health.route";
import menuRoute from "./menu.route";
import userRoutes from "./user.routes";
import betterAuthRoutes from "./betterAuth.routes";
import authCustomRoutes from "./auth.custom.routes";
import favoriteRoutes from "./favorite.routes";
import orderRoutes from "./order.routes";
import adminRoutes from "./admin.routes";
import cafeteriaRoutes from "./cafeteria.routes";
import cartRoute from "./cart.route";

const router = Router();

router.use(healthRoute);
router.use(menuRoute);
router.use(userRoutes);
router.use(authCustomRoutes);
router.use(betterAuthRoutes);
router.use(favoriteRoutes);
router.use(orderRoutes);
router.use("/admin", adminRoutes);
router.use(cafeteriaRoutes);
router.use("/cart", cartRoute);

export default router;
