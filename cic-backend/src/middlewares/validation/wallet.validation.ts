/**
 * Validation Middleware - Wallet Input Validation
 */
import { Request, Response, NextFunction } from "express";

/**
 * Validate pagination parameters for wallet details
 */
export const validateWalletPagination = (
  req: Request,
  res: Response,
  next: NextFunction,
) => {
  const page = Number.parseInt(req.query.page as string) || 1;
  const limit = Number.parseInt(req.query.limit as string) || 10;

  if (page < 1 || limit < 1 || limit > 1000) {
    return res.status(400).json({
      message: "Invalid pagination parameters. Page >= 1, Limit 1-1000",
    });
  }

  // Attach parsed values to request for controller to use
  (req as any).pagination = { page, limit };

  next();
};
