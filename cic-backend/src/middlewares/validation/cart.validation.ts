import { z } from "zod";
import type { Request, Response, NextFunction } from "express";

const mongoIdRegex = /^[a-f\d]{24}$/i;

const addItemSchema = z.object({
  menuItemId: z.string().regex(mongoIdRegex, "Invalid menuItemId"),
  quantity: z.coerce
    .number()
    .int("quantity must be an integer")
    .min(1, "quantity must be at least 1")
    .max(99, "quantity cannot exceed 99"),
  // Required only when the item hasVariants: true — enforced in the service layer
  // since we need to check the DB to know if variants are required
  variantName: z.string().min(1, "variantName cannot be empty").optional(),
  notes: z.string().max(200).optional(),
});

const updateItemSchema = z.object({
  quantity: z.coerce
    .number()
    .int("quantity must be an integer")
    .min(1, "quantity must be at least 1")
    .max(99, "quantity cannot exceed 99"),
  notes: z.string().max(200).optional(),
});

const menuItemIdParamSchema = z.object({
  menuItemId: z.string().regex(mongoIdRegex, "Invalid menuItemId"),
});

function validateBody<T extends z.ZodTypeAny>(schema: T) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.body);
    if (!result.success) {
      res.status(400).json({
        success: false,
        message: "Validation error",
        errors: result.error.flatten().fieldErrors,
      });
      return;
    }
    req.body = result.data;
    next();
  };
}

function validateParams<T extends z.ZodTypeAny>(schema: T) {
  return (req: Request, res: Response, next: NextFunction): void => {
    const result = schema.safeParse(req.params);
    if (!result.success) {
      res.status(400).json({
        success: false,
        message: "Invalid parameter",
        errors: result.error.flatten().fieldErrors,
      });
      return;
    }
    next();
  };
}

export const cartValidation = {
  addItem: validateBody(addItemSchema),
  updateItem: validateBody(updateItemSchema),
  menuItemIdParam: validateParams(menuItemIdParamSchema),
};