/**
 * Controller Layer - Cart HTTP Handlers
 * Handles request/response only. Delegates logic to service.
 */
import type { Request, Response } from "express";
import { cartService } from "@/services/cart.service";

interface AddItemBody {
  menuItemId: string;
  quantity: number;
  variantName?: string;
  notes?: string;
}

interface UpdateItemBody {
  quantity: number;
  variantName?: string;
  notes?: string;
}

export const cartController = {
  /**
   * GET /api/v1/cart
   */
  async getCart(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user.id;
    const cart = await cartService.getCart(userId);
    res.status(200).json({ success: true, data: cart });
  },

  /**
   * POST /api/v1/cart/items
   * Body: { menuItemId, quantity, variantName?, notes? }
   */
  async addItem(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user.id;
    const { menuItemId, quantity, variantName, notes } = req.body as AddItemBody;
    const cart = await cartService.addItem(userId, menuItemId, quantity, variantName, notes);
    res.status(200).json({ success: true, data: cart });
  },

  /**
   * PATCH /api/v1/cart/items/:menuItemId
   * Body: { quantity, variantName?, notes? }
   */
  async updateItem(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user.id;
    const menuItemId  = req.params.menuItemId as string;
    const { quantity, variantName, notes } = req.body as UpdateItemBody;
    const cart = await cartService.updateItem(userId, menuItemId, quantity, variantName, notes);
    res.status(200).json({ success: true, data: cart });
  },

  /**
   * DELETE /api/v1/cart/items/:menuItemId
   * Body (optional): { variantName? } — needed if item has variants
   */
  async removeItem(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user.id;
    const menuItemId  = req.params.menuItemId as string;
    const variantName = req.body?.variantName as string | undefined;
    const cart = await cartService.removeItem(userId, menuItemId, variantName);
    res.status(200).json({ success: true, data: cart });
  },

  /**
   * DELETE /api/v1/cart
   */
  async clearCart(req: Request, res: Response): Promise<void> {
    const userId = (req as any).user.id;
    const result = await cartService.clearCart(userId);
    res.status(200).json({ success: true, ...result });
  },
};