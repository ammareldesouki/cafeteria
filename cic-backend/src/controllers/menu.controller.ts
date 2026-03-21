/**
 * Controller Layer - HTTP Handler
 * Handles request/response only. Delegates to services.
 * No business logic, no direct DB access.
 */
import { Request, Response, NextFunction } from "express";
import { menuService } from "@/services/menu.service";

export const getMenu = async (
  _req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const items = await menuService.getAllMenuItems();
    res.json(items);
  } catch (err) {
    next(err);
  }
};

export const updateMenuItemStock = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    const { id } = req.params;
    const { in_stock } = req.body as { in_stock: boolean };

    const updated = await menuService.updateItemStock(id, in_stock);
    res.json(updated);
  } catch (err) {
    next(err);
  }
};
