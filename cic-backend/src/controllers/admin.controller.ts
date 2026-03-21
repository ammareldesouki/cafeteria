/**
 * Controller Layer - Admin Order Management HTTP Handler
 * Parse HTTP input → Call service → Return HTTP response
 */
import { Request, Response, NextFunction } from "express";
import { orderService } from "@/services/order.service";
import { OrderStatus, PaymentStatus } from "@/types/order.types";
import { handleServiceError } from "@/middlewares/serviceErrorHandler.middleware";

/**
 * Get all orders with filters and pagination
 * GET /admin/orders?page=1&limit=10&userId=&paymentStatus=&status=
 */
export const getAllOrders = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input (validated and parsed by middleware)
    const { page, limit } = (req as any).pagination;
    const filters = (req as any).filters;

    // Call service
    const result = await orderService.getAllOrders(filters, page, limit);

    // Return response
    res.json(result);
  } catch (err) {
    next(err);
  }
};

/**
 * Update order (admin can update any order)
 * PATCH /admin/orders/:id
 */
export const updateOrder = async (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  try {
    // Parse input
    const orderId = req.params.id as string;
    const { status, paymentStatus } = req.body;

    // Build updates object
    const updates: any = {};
    if (status !== undefined) {
      updates.status = status as OrderStatus;
    }
    if (paymentStatus !== undefined) {
      updates.paymentStatus = paymentStatus as PaymentStatus;
    }

    // Call service
    const order = await orderService.updateOrderByAdmin(orderId, updates);

    // Return response
    res.json(order);
  } catch (err) {
    try {
      handleServiceError(err, res);
    } catch (unhandledErr) {
      next(unhandledErr);
    }
  }
};
