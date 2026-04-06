import { Router } from "express";
import {
	getCafeteriaCallNumber,
	updateCafeteriaCallNumber,
} from "@/controllers/cafeteria.controller";

const router = Router();

router.get("/cafeteria/call-number", getCafeteriaCallNumber);
router.patch("/cafeteria/call-number", updateCafeteriaCallNumber);

export default router;
