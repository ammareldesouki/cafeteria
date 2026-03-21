/**
 * Validation Middleware - Favorite Input Validation
 */
import { Request, Response, NextFunction } from "express";

/**
 * Validate itemId in request body
 */
export const validateItemIdBody = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { itemId } = req.body;

  if (!itemId || typeof itemId !== "string") {
    return res.status(400).json({ message: "Invalid itemId" });
  }

  next();
};

/**
 * Validate itemId in request params
 */
export const validateItemIdParam = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const { itemId } = req.params;

  if (!itemId || typeof itemId !== "string") {
    return res.status(400).json({ message: "Invalid itemId" });
  }

  next();
};
