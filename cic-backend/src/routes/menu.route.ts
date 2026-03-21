import { Router } from "express";
import { getMenu, updateMenuItemStock } from "@/controllers/menu.controller";

const router = Router();

router.get("/menu", getMenu);
router.patch("/menu/:id/in-stock", updateMenuItemStock);

export default router;
